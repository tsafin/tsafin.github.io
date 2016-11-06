---
layout: article
title:  "Удаленное прокси может быть не (очень) больно"
date:   2016-11-11 00:00:00 +0300
categories: blog mapreduce
comments: true
blogger_orig_url: https://community.intersystems.com/post/remote-proxy-objects-dynamic-dispatch
---

# (Использование динамического диспетчирования на радость и во славу)

После нескольких статей про MapReduce нам показалось необходимым еще раз отойти в сторону и поговорить про инфраструктуру, которая поможет облегчить построение решения MapReduce. Мы, по-прежнему, говорим про Caché, и, по-прежнему, пытаемся построить MapReduce систему на базе имеющихся в системе подручных материалов. 

На попределенном этапе написания системы, типа MapReduce, встает задача удобного вызова удаленных методов и процедур (например, посылка управляющих сообщений с контроллера на сторону управляемых узлов). В среде Caché есть несколько простых, но не уочень удобных методов достичь этой цели, тогда как  хочется бы получить _удобный_. Чтобы последовательный код, вызывающий метода объекта/класса волшебным мановением руки превратить в код работающий уже с удаленными методами (степень "удаленности" может быть различной, может потребоваться вызывать и методы в другом процессе, того же самого узла, суть от этого не меняется - хочется получить удобный способ маршаллизации вызовов "на ту сторону")
После нескольких фальшстартов автору вдруг осознал, что в Caché ObjectScript есть очень простой механизм, который позволит скрыть все низкоуровневые детали под удобной, высокоуровнеевой оболочкой - это механизм динамической диспетчеризации методов и свойств.

Если оглянуться (далеко) назад, то можно увидеть, что начиная с Caché 5.2 (а это на минуточку с 2007 года) в базовом классе  [`%RegisteredObject`](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&amp;LIBRARY=ENSLIB&amp;CLASSNAME=%25RegisteredObject) есть несколько предопределенных методов, наследуемых каждым объектом в системе, которые вызывются при попытке вызова неизвестного во время компиляции метода или свойства (в настоящий момент эти методы переехали в интерфейс [`%Library.SystemBase`](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&amp;LIBRARY=ENSLIB&amp;CLASSNAME=%25Library.SystemBase) но это сильно не поменяло сути) .

| `Method %DispatchMethod (Method As %String, Args...)` | Вызов неисвестного метода или доступ к неизвестному многомерному свойству (их синтаксис идентичен) |
| `ClassMethod %DispatchClassMethod (Class As %String, Method As %String, Args...)` | Вызов неизветсного метода класса для заданного класса |
| `Method %DispatchGetProperty (Property As %String)` | Чтение неизвестного свойства |
| `Method %DispatchSetProperty (Property As %String, Val)` | Запись в неизвестное свойство |
| `Method %DispatchSetMultidimProperty (Property As %String, Val, Subs...)` | Запись в неизвестное многомерное свойство (_не используется в данном случае, будет частью другой истории_) |
| `Method %DispatchGetModified (Property As %String)` | Доступ к флагу "modified" ("изменен") для неизвестного совйства (_также, не используется в данной истории_) |
| `Method %DispatchSetModified (Property As %String, Val)` | Дополнение к методу выше - запись в флаг "modified" ("изменен") для неизветсного свойства (_не используется в данной истории_) |

Для простоты эксперимента, мы будем использовать только те функции. отчечающие за вызов неизвестных методов и скалярных свойств. В продуктовой среде вам на определенном этапе может понадобиться переопределить вс или большинство данных методов, т.ч. будьте бдительны.

## Простой пример - протоколирующий объект-прокси

Еще со времен "царя Гороха" в стандартной библиотеке CACHие методы и свойства для работы с проекцией JavaScript объектов в XEN -  [`%ZEN.proxyObject`](http://docs.intersystems.com/Caché20161/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&amp;LIBRARY=%25SYS&amp;CLASSNAME=%25ZEN.proxyObject), он позволял манипулировать динамичекими свойствами даже во времена, когда еще не было работ по документной базе DocumentDB (не спрашивайте) и еще не было нативной поддержки JSON объектов в ядре среды Caché.

Давайте, для затравки, попытаемся создать простой _протоколирующий все вызовы прокси_ объект? Где мы обернем все вызовы через динамическую диспетчеризацию с сохраненим протокола о каждом событии. [Очень похоже на технику mocking в других языковых средах.]
[[Как это переводить на русский? "мОкать"?]]

Для примера возьмем очень упрощенный класс `Sample.SimplePerson` (по странном сутечению осбстоятельств очень похожего на `Sample.Person` из SAMPLES в стандартной поставке :wink: ) 

```
DEVLATEST:15:23:32:MAPREDUCE>set p = ##class(Sample.SimplePerson).%OpenId(2)

DEVLATEST:15:23:34:MAPREDUCE>zw p

p=<OBJECT REFERENCE>[1@Sample.SimplePerson]
+----------------- general information ---------------
|      oref value: 1
|      class name: Sample.SimplePerson
|           %%OID: $lb("2","Sample.SimplePerson")
| reference count: 2
+----------------- attribute values ------------------
|       %Concurrency = 1  <Set>
|                Age = 9
|           Contacts = 23
|               Name = "Waal,Nataliya Q."
+-----------------------------------------------------
```

Т.е. класс - персистентный, с простыми 3 свойствами экземпляров класса: Age, Contacts, Name. Обернем доступ ко всем свойствам этого класса и вызов всех его методов в своем классе `Sample.LoggingProxy`, каждый вызов и доступ мы будем протоколировать ... куда-нибудь.

```
/// Простой протоколирующий прокси объект:
Class Sample.LoggingProxy Extends %RegisteredObject
{
/// Кладем лог доступа в глобал
Parameter LoggingGlobal As %String = "^Sample.LoggingProxy";
/// Храним ссылку на открытый объект 
Property OpenedObject As %RegisteredObject;

/// просто сохряняем строку как следующий узел в глобале
ClassMethod Log(Value As %String)
{
    #dim gloRef = ..#LoggingGlobal
    set @gloRef@($increment(@gloRef)) = Value
}

/// Более удобный метод с префиксом и аргументами
ClassMethod LogArgs(prefix As %String, args...)
{
    #dim S as %String = $get(prefix) _ ": " _ $get(args(1))
    #dim i as %Integer
    for i=2:1:$get(args) {
        set S = S_","_args(i)
    }
    do ..Log(S)
}

/// открыть экземпляр другого класса с заданным %ID
ClassMethod %CreateInstance(className As %String, %ID As %String) As Sample.LoggingProxy
{
    #dim wrapper = ..%New()
    set wrapper.OpenedObject = $classmethod(className, "%OpenId", %ID)
    return wrapper
}

/// запротоколировать переданные аргументы и передать управление через прокси ссылку
Method %DispatchMethod(methodName As %String, args...)
{
    do ..LogArgs(methodName, args...)
    return $method(..OpenedObject, methodName, args...)
}

/// запротоколировать переданные аргументы и прочитать свойство через прокси ссылку
Method %DispatchGetProperty(Property As %String)
{
    #dim Value as %String = $property(..OpenedObject, Property)
    do ..LogArgs(Property, Value)
    return Value
}

/// запротоколировать переданные аргументы и записать свойство через прокси ссылку
/// log arguments and then dispatch dynamically property access to the proxy object
Method %DispatchSetProperty(Property, Value As %String)
{
    do ..LogArgs(Property, Value)
    set $property(..OpenedObject, Property) = Value
}

}
```

1. Параметр класса `#LoggingGlobal` задаёт где хранить лог (в данном случа в глобале с именем `^Sample.LogginGlobal`);
2. Еть два простых метода `Log(Arg)` и `LogArgs(prefix, args...)` которые пишут протокол в глобал, заданый свойством выше;
3. `%DispatchMethod`, `%DispatchGetProperty` и `%DispatchSetProperty` обрабатывают соответствующие сценарии с вызовами неизвестного метода или обращения к свойству. Они протоколируют через `LogArgs` каждый случай обращения, а затем напрямую вызывают метод или свойство объекта из ссылки `..%OpenedObject`;
4. Также там задан метод "фабрики класса" `%CreateInstance`, который открывает экземпляр заданного класса по его идентификатору `%ID`. Созданный объект "оборачивается" в объект `Sample.LogginProxy` и ссылка на которого и возвращается из этого метода класса.

### picture of wrapped object

Никакого шайтанства, ничего особенного, но, если приглядеться, то в этих 70 строках Caché ObjectCript мы попытались показать шаблон вызова метода/свойства с _побочным эффектом_ (более полезный пример такого шаблона будет показан позже). И пока, давайте посмотрим как ведет себя наш "протоколирущий прокси объект":

```
DEVLATEST:15:25:11:MAPREDUCE>set w = ##class(Sample.LoggingProxy).%CreateInstance("Sample.SimplePerson", 2)

DEVLATEST:15:25:32:MAPREDUCE>zw w

w=<OBJECT REFERENCE>[1@Sample.LoggingProxy]
+----------------- general information ---------------
|      oref value: 1
|      class name: Sample.LoggingProxy
| reference count: 2
+----------------- attribute values ------------------
|           (none)
+----------------- swizzled references ---------------
|     i%OpenedObject = ""
|     r%OpenedObject = [2@Sample.SimplePerson](mailto:2@MR.Sample.AgeAverage.Person)
+-----------------------------------------------------

DEVLATEST:15:25:34:MAPREDUCE>w w.Age

9

DEVLATEST:15:25:41:MAPREDUCE>w w.Contacts

23

DEVLATEST:15:25:49:MAPREDUCE>w w.Name

Waal,Nataliya Q.

DEVLATEST:15:26:16:MAPREDUCE>zw ^Sample.LoggingProxy

^Sample.LoggingProxy=4
^Sample.LoggingProxy(1)="Age: 9"
^Sample.LoggingProxy(2)="Contacts: 23"
^Sample.LoggingProxy(3)="Name: Waal,Nataliya Q."
```

Мы видим состояние объекта `Sample.SimplePerson`, открытого напрямую, и результаты получаемые через прокси и записанные в лог. Все как и ожидалось

## Remote proxy

Внимательный читатель все еще должен помнить для чего мы тут собрались - все эти упражнения нужны нам для реализации простого прокси объекта, отображающего объект на удаленном узле кластера. На самом деле, класс с похожей функциональностью в Caché есть - это [`%Net.RemoteConnection`](http://docs.intersystems.com/latest/csp/docbook/%25CSP.Documatic.cls?PAGE=CLASS&amp;LIBRARY=%25sys&amp;CLASSNAME=%25Net.RemoteConnection)? Что с ним не так?

Многое (и то, что класс официально помечен как "deprecated" - не находится в этом списке наших претензий, у нас претензии другого рода).

Как многие знают, класс [`%Net.RemoteConnection`](http://docs.intersystems.com/latest/csp/docbook/%25CSP.Documatic.cls?PAGE=CLASS&amp;LIBRARY=%25sys&amp;CLASSNAME=%25Net.RemoteConnection) для вызова удаленных методов Caché использует c-binding службы (которые, кстати, являются оберткой над cpp-binding). Если вам известен адрес системы, область с которой вы хотите рабоать, и знаете логи и пароль, то у вас есть все для удаленного вызова метода в этой области этого узла. Проблема с данным API из `%Net.RemoteConnection` - оно очень громоздко и многословно:

```
Class MR.Sample.TestRemoteConnection Extends %RegisteredObject
{

ClassMethod TestMethod(Arg As %String) As %String
{
    quit $zu(5)_"^"_##class(%SYS.System).GetInstanceName()_"^"_
         $i(^MR.Sample.TestRemoteConnectionD)
}

ClassMethod TestLocal()
{
    #dim connection As %Net.RemoteConnection = ##class(%Net.RemoteConnection).%New()
    #dim status As %Status = connection.Connect("127.0.0.1",$zu(5),^%SYS("SSPort"),"_SYSTEM","SYS")
    set status = connection.ResetArguments()
    set status = connection.AddArgument("Hello", 0 /*by ref*/, $$$cbindStringId)
    #dim rVal As %String = ""
    set status = connection.InvokeClassMethod(..%ClassName(1), "TestMethod", .rVal, 1 /*has return*/, $$$cbindStringId)
    zw rVal
    do connection.Disconnect()
}

...

}
```

После создания соединения, и перед вызовом метода класса вы должны собственноручно озаботиться передачей списка аргументов, начиная с вызова ResetArguments, а потом передавая каждый следующий аргумент через вызов AddArgument с кучей параметров, описывающих аргумент, его тип (в номенклатуре cpp-binding), входной или выходной это аргумент, и многие другие (низкоуровневые) свойства.

Также, персонально, меня сильно растраивало, что нельзя было просто вернуть значение после вызова удаленного метода (т.к. возращаемое значение `InvokeClassMethod` является просто кодом состояния, и чтобы вернуть значение, ты собственноручно должен был сам позаботиться о соответствующем возвращаемом аргументе функции где-нибудь в глубинах формируемого спсика).

_Я слишком стар для таких многословных и долгих предварительных игр!_

Мне наоборот хотелось получить более короткий и простой метод передать аргументы в функцию на другом узле. 

Помните в Caché ObjectScript есть метод передачи перемнного числа параметров через массив `args...` в аргументах функции? Почему бы не поиспользовать такой механизм для скрытия всех этих грязных деталей низкоуровневого интерфейса, оставив нам просто название и список аргуметов? И чтобы движок все сделал сам (догадавшись о типе передаваемых данных, например)?

```
/// Пример прокси удаленного объекта посредством %Net.RemoteConnection
Class Sample.RemoteProxy Extends %RegisteredObject
{
Property RemoteConnection As %Net.RemoteConnection [Internal ];
Property LastStatus As %Status [InitialExpression = {$$$OK}];

Method %OnNew() As %Status
{
    set ..RemoteConnection = ##class(%Net.RemoteConnection).%New()

    return $$$OK
}

/// создать экземпляр указанного класса 
Method %CreateInstance(className As %String) As Sample.RemoteProxy.Object
{
    #dim instanceProxy As Sample.RemoteProxy.Object = ##class(Sample.RemoteProxy.Object).%New($this)
    return instanceProxy.%CreateInstance(className)
}

/// открыть экземпляр заданного класса по его %ID
Method %OpenObjectId(className As %String, Id As %String) As Sample.RemoteProxy.Object
{
    #dim instanceProxy As Sample.RemoteProxy.Object = ##class(Sample.RemoteProxy.Object).%New($this)
    return instanceProxy.%OpenObjectId(className, Id)
}

/// Соединение с системой посредством объекта конфигуратора 
/// { "IP": IP, "Namespace" : Namespace, ... }
Method %Connect(Config As %Object) As Sample.RemoteProxy
{
    #dim sIP As %String = Config.IP
    #dim sNamespace As %String = Config.Namespace
    #dim sPort As %String = Config.Port
    #dim sUsername As %String = Config.Username
    #dim sPassword As %String = Config.Password
    #dim sClientIP As %String = Config.ClientIP
    #dim sClientPort As %String = Config.ClientPort
    
    if sIP = "" { set sIP = "127.0.0.1" }
    if sPort = "" { set sPort = ^%SYS("SSPort") }
    set ..LastStatus = ..RemoteConnection.Connect(sIP, sNamespace, sPort, 
                                                  sUsername, sPassword, 
                                                  sClientIP, sClientPort)
    
    return $this
}

ClassMethod ApparentlyClassName(CompoundName As %String, Output ClassName As %String, Output MethodName As %String) As %Boolean [Internal ]
{
    #dim returnValue As %Boolean = 0
    
    if $length(CompoundName, "::") > 1 {
        set ClassName = $piece(CompoundName, "::", 1)
        set MethodName = $piece(CompoundName, "::", 2, *)

        return 1
    } elseif $length(CompoundName, "'") > 1 {
        set ClassName = $piece(CompoundName, "'", 1)
        set MethodName = $piece(CompoundName, "'", 2, *)

        return 1
    }

    return 0
}

/// Динамическая диспетчеризация метода (класса) удаленного объекта
Method %DispatchMethod(methodName As %String, args...)
{
    #dim className as %String = ""
    
    if ..ApparentlyClassName(methodName, .className, .methodName) {
        return ..InvokeClassMethod(className, methodName, args...)
    }
    return 1
}

/// собственно вызов метода класса со всеми инзкоуровневыми деталями
Method InvokeClassMethod(ClassName As %String, MethodName As %String, args...)
{
    #dim returnValue = ""
    #dim i as %Integer
    do ..RemoteConnection.ResetArguments()
    for i=1:1:$get(args) {
        set ..LastStatus = ..RemoteConnection.AddArgument(args(i), 0)
    }
    set ..LastStatus = ..RemoteConnection.InvokeClassMethod(ClassName, MethodName, .returnValue, $quit)
    return returnValue
}

}
```

### picture of wrapped object

Первое упрощение, которое я пытался внести в данный интерфейс - это использование объекта конфигуратора вместо длинного списка аргументов функции. В Caché ObjectScript нет встроеного способа передать [_именованные аргументы_](http://perldesignpatterns.com/?NamedArguments), если надо передать только последние два из списка параметров функции, то вам надо аккуратненько отсчитать запятые параметров которые вас не интересуют и передать в конце желаемое. Прмяо скажем, крайне хрупкая конструкция. 

С другой стороны, теперь в ObjectScript есть встроенная поддержка JSON объектов, которые можно создавать на лету, внутри выражения `{}`. Мы можем по примеру Perl, попытаться поиспользовать такие динамические объекты (в случае Perl Это был hash) для передачи именованных аргументов функции. Динамический объект конфигуратор будет содержать только те ключи-значения, что нас интересуют.

```
DEVLATEST:16:27:18:MAPREDUCE>set w = ##class(Sample.RemoteProxy).%New().%Connect({"Namespace":"SAMPLES", "Username":"_SYSTEM", "Password":"SYS"})
 
DEVLATEST:16:27:39:MAPREDUCE>zw w
w=<OBJECT REFERENCE>[1@Sample.RemoteProxy]
+----------------- general information ---------------
|      oref value: 1
|      class name: Sample.RemoteProxy
| reference count: 2
+----------------- attribute values ------------------
|         LastStatus = 1
+----------------- swizzled references ---------------
|           i%Config = ""
|           r%Config = ""
| i%RemoteConnection = ""
| r%RemoteConnection = 2@%Net.RemoteConnection
+-----------------------------------------------------
```

Вторая современная идиома, использованная в данном примере - каскадирование вызовов. Где это только возможно мы возвращаем из методов ссылку на текущий объект %this, что позволяет вызывать несколько методов этого же класса в виде каскада. Меньше кода пишем - лучше спим. 

### Проблема с вызовом методов класса

Корневой объект оболочка вокруг `%Net.RemoteConnection` не может сделать многого, чтобы мы хотели. Если в нем нет места хранить контекст создаваемых объектов (а в нем такого не было. Еще). [Мы решим данную проблему позже, в другом классе] Единственное, что мы можем попытаться сделать сейчас - это упростить сопосб вызова методов класса, вызываемых без ссылки на экземпляр объекта.
Мы можем попытаться переопределить `%DispatchClassMethod`, о это сильно не поможет в нашем случае, когда мы хотим написать _обобщенный_ прокси класс, который бы работал для любого удаленного класса. В случае отношения 1:1, когда некая специализированная оболочка на этой стороне соответствует определенному классу на той стороне, такой подход с переопределением %DispatchClassMethod вполне работает, но не в случае с обобщенным классом. 
В общем случае, нам надл придумать что-то другое, но по прежнему, простое, что работало бы с любым соединением и любым целеым классом. 

Наше, достаточно элегантное решение данной проблемы мы приведем ниже, а пока отйдем в сторону и посмотрим, что в Caché ObjectScript может использоваться в качестве дентификатора метода или свойства. Не все знают (я, по крайней мере, узнал об этом пару лет назад) что имена идентификаторов в ObjectScript могут состоять не только из латинских букв и цифр, но и любых "символов алфавита" заданных текущей локалью (например, не только латинские буквы A-Za-z и арабские цифры 0-9, но и кириллические буквы А-Яа-я при установленной Русской локали). [[эта проблема вскользь обсуждалось в данной дискуссии на StackOverflow](http://stackoverflow.com/questions/35452352/what-characters-are-usable-in-a-variable-name-in-objectscript-on-a-unicode-ins/35492721#35492721)] Более того, если продолжать извращаться, то вы можете вставить в имя идентификатора Эмодзи символы в качестве разделителя, если вы создадите и активируете такую локаль, где эмодзи будут считаться алфавитом текущего языка. В уелом, кажется, что любой, чувствительный к установленной локали трюк, не очень далеко взлетит как обобщенное решение, т.ч. давайте остановимся.

С другой стороны, идея использования некоего символа разделителя внутри имени метода (класса) кажется вполне разумной и многообщающей. Мы моли бы скрыть обработку разделителя внутри специальной реализации  `%DispatchMethod`, где мы бы отделяли название класса от имени метода, и соответственно диспетчировали бы как вызов вметода класса, скрывая все детали реализации. Так и сделаем, пожалуй.

Возвращаясь к синтаксису допустимых имен методов, еще менее известным фактом является факт, что вы можете записат в метод класса _вообще все что пожелаете_ если поместите такое имя внутри дфойных кавычек. Скомбинировав закавыченность имени и специальный разделитель для имени класса я мог бы вызывать метод класса `LogicalToDisplay` из класса `Cinema.Duration` пользуясь следующим непривычным на первый взгляд синтаксисом:

```
DEVLATEST:16:27:41:MAPREDUCE>set w = ##class(Sample.RemoteProxy).%New().%Connect({"Namespace":"SAMPLES", "Username":"_SYSTEM", "Password":"SYS"})

DEVLATEST:16:51:39:MAPREDUCE>write w."Cinema.Duration::LogicalToDisplay"(200)

3h20m
```


> _Мне кажется получилось достаточно просто и элегантно, не правда ли?_

> [Специальная обработка имени и распознавание разделителей происходит в функции `ApparentlyClassName`, где мы ищем в качестве разделителя между именем класса и навзанием метода класса - или "::" (двойное двоеточие как в Си++) или "'" (одинарная кавычка как в Ada или первоначальном Perl-е)]

Но тут же заметим, если вы попытаетесь что-то вывести на экран в таком удаленном методе класса, то вам не повезло, весь результат выдачи потеряется (проигнорируется), т.к. протокол cpp-binding не перехватывает выдачу на экран, и не передает это обратно. _Протокол cpp-binding возвращает данные, а не побочные эффекты_.

```
DEVLATEST:16:51:47:MAPREDUCE>do w."Sample.Person::PrintPersons"(1)

```

### Прокси удаленных объектов

Как мог заметить внимательный читатель - мы не делали много полезного в коде `Sample.RemoteProxy` приведенном выше: мы только создали соединение, и пробрасывали вызовы методов класса. 

Если же вам надо создавать удаленные экземпляры классов или, паче чаяния, открывать объекты по их %ID, то вы можете воспользоваться сервисами другого класса оболочки `%Sample.RemoteProxy.Object`.

```
Class Sample.RemoteProxy.Object Extends %RegisteredObject
{
/// хранит ссылку на открытый объект для последующих манипуляций
Property OpenedObject As %Binary;
Property Owner As Sample.RemoteProxy [ Internal ];
Property LastStatus As %Status [ InitialExpression = {$$$OK}, Internal ];

Method RemoteConnection() As %Net.RemoteConnection [ CodeMode = expression ]
{
..Owner.RemoteConnection
}

Method %OnNew(owner As Sample.RemoteProxy) As %Status
{
    set ..Owner = owner
    return $$$OK
}

/// создаём новый экземпляр определенного класса
Method %CreateInstance(className As %String) As Sample.RemoteProxy.Object
{
    #dim pObject As %RegisteredObject = ""
    set ..LastStatus = ..RemoteConnection().CreateInstance(className, .pObject)
    set ..OpenedObject = ""
    if $$$ISOK(..LastStatus) {
        set ..OpenedObject = pObject
    }
    return $this
}

/// создаём экземпляр определенного класса при заданном %ID
Method %OpenObjectId(className As %String, Id As %String) As Sample.RemoteProxy.Object
{
    #dim pObject As %RegisteredObject = ""
    set ..LastStatus = ..RemoteConnection().OpenObjectId(className, Id, .pObject)
    set ..OpenedObject = ""
    if $$$ISOK(..LastStatus) {
        set ..OpenedObject = pObject
    }
    return $this
}

/// исполнить метод открытого объекта с переданными аргументами
Method InvokeMethod(MethodName As %String, args...) [ Internal ]
{
    #dim returnValue = ""
    #dim i as %Integer
    #dim remoteConnection = ..RemoteConnection()
    do remoteConnection.ResetArguments()
    for i=1:1:$get(args) {
        set ..LastStatus = remoteConnection.AddArgument(args(i), 0)
    }
    set ..LastStatus = remoteConnection.InvokeInstanceMethod(..OpenedObject, MethodName, .returnValue, $quit)
    return returnValue
}

/// Динамическая диспетчеризация метода (класса) удаленного объекта
Method %DispatchMethod(methodName As %String, args...)
{
    //do ..LogArgs(methodName, args...)
    return ..InvokeMethod(methodName, args...)
}

/// Динамическая диспетчеризация чтения свойства удаленного объекта
Method %DispatchGetProperty(Property As %String)
{
    #dim value = ""
    set ..LastStatus = ..RemoteConnection().GetProperty(..OpenedObject, Property, .value)
    return value
}

/// Динамическая диспетчеризация записи в свойство удаленного объекта
Method %DispatchSetProperty(Property, Value As %String) As %Status
{
   set ..LastStatus = ..RemoteConnection().SetProperty(..OpenedObject, Property, Value)
    return ..LastStatus
}

}
```

Если приглядеться, то можно распознать что в коде оболочки объекта по прежнему используется общий класс `Sample.RemoteProxy`, используемый для оперирования низкоуровневыи примитивами cpp-binding (в данном случае `%Net.RemoteConnection`). Каждый создаваемый экземпляр удаленного объекта инстанцирует экземпляр класса `Sample.RemoteProxy.Object`, внутри которого хранится ссылка на свойство `..Owner` типа `Sample.RemoteProxy` которое и используется для всяких соединительных целей. Данное свойство инициализируется в момент создания объекта из конструктора (смотри `%OnNew`).

Мы также создали (относительно) удобный метод  There `InvokeMethod`, который может работать с любым количеством передаваемых аргументов, и который маршаллизует данные через `%Net.RemoteConnection` в вызовы удаленных методов (ну, т.е., как было в оригинальоном примере с `%Net.RemoteConnection` он вызывает `ResetArguments` перед началом наполнения списка аргументови и, в последующем, вызывает `AddArgument` для каждого следующего аргумента, и в финале, сформированный список передается  `%NetRemoteConnection::InvokeInstanceMethod` для исполнения на "той стороне")

```
DEVLATEST:19:23:54:MAPREDUCE>set w = ##class(Sample.RemoteProxy).%New().%Connect({"Namespace":"SAMPLES", "Username":"_SYSTEM", "Password":"SYS"})

…

DEVLATEST:19:23:56:MAPREDUCE>set p = w.%OpenObjectId("Sample.Person",1)

DEVLATEST:19:24:05:MAPREDUCE>write p.Name

Quince,Maria B.

DEVLATEST:19:24:11:MAPREDUCE>write p.SSN

369-27-1697

DEVLATEST:19:24:17:MAPREDUCE>write p.Addition(1,2)

3
```

В данном примере мы присоединяемся к локальной системе и её области "SAMPLES", открываем экземпляр класса `Sample.Person` по идентификатору 1, прочитываем его свойства (Name, SSN) и выполняем методы (Addition). 

> Получилось достаточно просто, не правда ли?

### Вместо заключения

Код, приведенный в наших примерах, не имеет еще продуктового качества (там нет правильной обработки ошибок, нет обработки разрывов соединения или удаления коллекции объектов, но, даже сейчас, такой маленький и простой набор классов позволит вам писать читабельный и поддерживаемый код, оперирующий удаленными объектами на узлах кластера. Малыми усилиями, и меньшим количеством строк.

Чем мы и воспользуемся при написании кода MapReduce в следующих частях саги...

Весь код, кпомянутый здесь, доступен через [gist](https://gist.github.com/tsafin/02bb6b5967cbdd1176618cb645445770).

{% gist tsafin/02bb6b5967cbdd1176618cb645445770 %}



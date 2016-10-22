---
layout: article
title:  "Еще раз про MapReduce. Часть 2 – базовые интерфейсы реализации"
date:   2016-10-04 13:24:00 +0300
categories: blog mapreduce
comments: true
thumbnail: https://habrastorage.org/files/e4c/cac/f03/e4ccacf0316840bca92ee668bfdb1f95.jpg
blogger_orig_url: https://habrahabr.ru/company/intersystems/blog/310196/
---

> <em><a href="http://fineartamerica.com/featured/take-it-like-a-man-joan-pollak.html"><img src="https://habrastorage.org/files/e4c/cac/f03/e4ccacf0316840bca92ee668bfdb1f95.jpg" align="left" width="288" height="240" alt="Take it like a man by Joan Pollak" /></a><a href="../mapreduce-russian-part-i/">В предыдущей части серии</a> мы (в 100500й раз) попытались рассказать про основные приемы и стадии подхода Google MapReduce, должен признаться, что первая часть была намерено "капитанской", чтобы дать знать о MapReduce целевой аудитории последующих статей. Мы не успели показать ни строчки того, как всё это мы собираемся реализовывать в Caché ObjectScript. И про это наша рассказ сегодня (и в последующие дни).</em>

Напомним первоначальный посыл нашего мини-проекта: вы всё еще планируем реализовать MapReduce алгоритм используя те подручные средства, что есть в Caché ObjectScript. При создании интерфейсов, мы попытаемся придерживаться того API, что мы описали в предыдущей статье про оригинальную реализацию Google MapReduce, любые девиации будут озвучены соответствующе.
<habracut/>
Начнем с реализации абстрактных интерфейсов Mapper и Reducer.

```CacheObjectScript

Class MR.Base.Mapper 
{
Method Map(MapInput As MR.Base.Iterator, MapOutput As MR.Base.Emitter) [ Abstract ] { }
}

Class MR.Base.Reducer
{
Method Reduce(ReduceInput As MR.Base.Iterator, ReduceOutput As MR.Base.Emitter) [ Abstract ] { }
}
```

Изначально, как и в канонической реализации, мы сделали 2 отдельных интерфейса MapInput и ReduceInput. Но сразу стало очевидным, что они служат одной и той же цели, и предоставляют одни и те же методы – их цель пройтись по потоку данных до конца, т.ч. они оба являются итераторами. Потому, в итоге, редуцируем их в общий интерфейс MR.Base.Iterator:

```CacheObjectScript

Class MR.Base.Iterator
{

Method GetNext() As %String [Abstract ] { }

Method IsAtEnd() As %Boolean [Abstract ] { }

}
```

## Использование глобалов в качестве каналов связи

Оригинальная реализация Google MapReduce использовала файловую систему Google GFS как транспорт между узлами и стадиями алгоритма. В Caché есть свой механизм распространения (когерентных) данных между узлами (если не пользоваться голым TCP/UDP) – это протокол ECP ([Enterprise Caсhe Protocol](http://docs.intersystems.com/documentation/cache/latest/pdfs/GDDM.pdf)). Обычно он используется серверами приложений для получения данных от удаленных серверов баз данных. Но ничего не останавливает нас от построения на базе таких peer-to-peer соединений ECP некоей виртуальной управляющей шины, куда мы будем складывать данные в виде пар &lt;ключ,значение&gt; или похожие данные. Эти данные будут будут пересылаться между акторами, участвующими в конвейерах алгоритма (т.е. emit, посылаемый объектом Mapper, будет писаться в шину ECP и читаться объектом Reducer). Если акторы будут работать в рамках одного узла, то они, например могут использовать быстрые глобалы, отображенные в CACHETEMP, или обычные глобалы, если реализуемый алгоритм многостадийный и нужна надежность и журналирование.

В любом случае, будь то локальные (для конфигурации на одном узле) глобалы, или глобалы удаленного узла, подключенного через ECP, глобалы являются удобным и хорошо зарекомендовавшим себя транспортом для передачи данных между узлами кластера Caché, в данном случае, между вовлеченными в MapReduce функциями и классами. 

> Посему, естественным решением, позволяющим упростить нашу систему будет использование в среде Caché для передачи данных между узлами кластера протокола ECP вместо файловых систем GFS или HDFS. Функциональные характеристики ECP позволят сделать и другие упрощения (но об этом несколько позже).

## Эмиттеры и черная магия

Как мы уже рассказывали [в предыдущей серии](https://habrahabr.ru/company/intersystems/blog/310180/), с момента когда данные уходят от объекта Mapper, и до момента как они поступают на вход Reducer, в классической реализации на мастере проходит тяжелая операция перемешения и сортировки. 

В окружении, использующем глобалы к качестве транспорта, в MUMPS/Caché ObjectScript среде, мы можем полностью избежать дополнительных расходов на такую сортировку, т.к. агрегация и сортировка будут сделаны нижележащим btree\* хранилищем.

Имея такие требования к дизайну, создадим базовый интерфейс эмиттера:

```CacheObjectScript

Class MR.Base.Emitter Extends MR.Base.Iterator
{

/// emit $listbuild(key,value(s))
Method Emit(EmitList... As %String) [Abstract ] { }

}
```

Эмиттер должен быть похож на интерфейс входного итератора, показанного выше (потому мы и пронаследовались от MR.Base.Iterator), но в дополнение к интерфейсу прохода по данным, эмиттер должен уметь еще и посылать данные в своё промежуточное хранилище (т.е. добавляем функцию Emit).

Первоначально, наша функция Emit была очень похожа на классическую реализацию и принимала только 2 аргумента как пару &lt;ключ,значение&gt;, но потом мы натолкнулись на (редкую) необходимость передавать что-то более многомерное, длиннее чем пара значений (например, кортеж любой арности), потому, в настоящий момент, Emit стал функцией принимающей переменное число аргументов. 

Заметим, что в большинстве случаев, на практике, сюда будет поступать только пара аргументов &lt;ключ,значение&gt; как мы и видели в классической реализации.

_Это всё ещё абстрактный интерфейс, больше мяса будет добавлено очень скоро._

Если бы нам, при обработке, надо было сохранять порядок поступивших элементов, то мы бы использовали реализацию ниже:

```CacheObjectScript

/// Emitter which maintains the order of (key,value(s))
Class MR.Emitter.Ordered Extends (%RegisteredObject, MR.Base.Emitter)
{
   /// global name serving as data channel
Property GlobalName As %String;
Method %OnNew(initval As %String) As %Status
{
    $$$ThrowOnError($length(initval)>0)
    set ..GlobalName = initval 
    quit $$$OK
}

Parameter AUTOCLEANUP = 1;
Method %OnClose() As %Status
{
    if ..#AUTOCLEANUP {
        if $data(@i%GlobalName) {
            kill @i%GlobalName
        }
    }
    Quit $$$OK
}
...
}
```

Заметим на полях, что в Caché глобалы – в общем-то, глобальны :) , и не будут очищены автоматически по завершении процессов их создавших. В отличие, например, от [PPG (process-private globals)](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GCOS_variables#GCOS_variables_procprivglbls). Но иногда все же хочется, чтобы наши промежуточные каналы, созданные для взаимодействия между стадиями конвейера MapReduce удалялись по завершении подпрограммы их создавшей. Поэтому и был добавлен режим "автоочистки" (параметр класса #AUTOCLEANUP) при котором глобал, имя которого хранится в свойстве GlobalName, будет удален при закрытии объекта (в момент вызова %OnClose).

Обратите внимание, что мы форсируем один обязательный параметр в метода %New (в %OnNew генерируем $$$ThrowOnError если имя в Initval не определено). Конструктор класса ожидает получить название глобала с которым он будет работать в качестве транспорта данных.

```

Class MR.Emitter.Ordered Extends MR.Base.Emitter
{
/// ... 
Method IsAtEnd() As %Boolean
{
    quit ($data(@i%GlobalName)\10)=0
}

/// emit $listbuild(key,value)
Method Emit(EmitList... As %String)
{
    #dim list As %String = ""
    for i=1:1:$get(EmitList) {
        set $li(list,i) = $get(EmitList(i))
    }
    #dim name As %String = ..GlobalName
    set @name@($seq(@name)) = list
}

/// returns emitted $lb(key,value)
Method GetNext() As %String
{
    #dim value As %String
    #dim index As %String = $order(@i%GlobalName@(""), 1, value)

    if index '= "" {
        kill @i%GlobalName@(index)
        quit value
    } else {
        kill @i%GlobalName
        quit ""
    }
}

Method Dump()
{
    zwrite @i%GlobalName
}

}
```

Надеемся, вы еще помните, что наш Emitter является наследником итератора Iterator? Посему ему нужно реализовать пару функций итератора – IsAtEnd и GetNext.

- IsAtEnd – простой: если наш служебный глобал не содержит данных (т.е. [$data(..GlobalName)](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RVBS_fdata) не возвращает 10 или 11, что означает что там в поддереве есть еще узлы с данными), то мы достигли конца потока данных;

- Emit создает узел с данными в конце текущего списка. Оформляя пару (или кортеж, при арности больше 2х) как элемент [$(listbuild(...))](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RSQL_d_listbuild) [listbuild].

Как известно, и как хорошо написал [Саша Коблов, $SEQUENCE](https://habrahabr.ru/company/intersystems/blog/263793/) может быть использована почти во всех местах, где использовался [$INCREMENT](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fincrement), обеспечивая при этом лучшие скорости при работе в многопроцессорном или многосерверном режиме (через ECP). В силу меньшего количества коллизий при обращении к одном узлу глобала. Потому в коде выше мы используем _$sequence_ для выделения индекса следующего элемента упорядоченного списка.

- На другой стороне алгоритма, в получателе GetNext() вытаскивает элементы из коллекции посредством простого [$ORDER(@i%GlobalName(""))](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_forder). Элемент, с полученным индексом будет удален из списка после обработки.

> _Обращаем внимание, что данный вариант удаления элемента из списка/глобала [не очень совместим с параллельным режимом](https://community.intersystems.com/post/cach%C3%A9-mapreduce-basic-interfaces-mapreduce-implementation-part-ii#comments), и нужно было бы добавить блокировки или сменить структуру данных. Но т.к. на ближайшие серии у нас будет только один Reducer, на всё множество Mapper ов, то мы отложим решение данной проблемы на будущее, когда приступим к много-серверной реализации._

> Заметим, что структура данных, реализованная MR.Emitter.Ordered по сути реализуют классическую коллекцию FIFO (&quot;FirstIn – FirstOut&quot;). Мы помещаем новый элемент в конец списка и вытаскиваем из головы списка.

### Специальный случай: эмиттер с автоагрегацией

Если вы посмотрите на те данные, что мы посылаем в между стадиями конвейера в примере word-count (ок, не сейчас, а когда мы вам покажем такую реализацию) то вы быстро осознаете, что:

- На самом деле нам не интересен порядок, в котором мы "эмиттим"  пары &lt;ключ, значение&gt;. Более того, нижележащее хранилище btree\* всегда держит список ключей отсортированным для быстрого поиска, избавляя нас от необходимости сортировки на мастере, как произошло бы в классической реализации;

- И в наших случаях, когда мы пишем пару &lt;key,1&gt; на стороне Mapper, мы предполагаем в Reducer их простую агрегацию в сумму единиц. Т.е. в случае Caché ObjectScript мы полагались бы на использование [$INCREMENT](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fincrement).

> _Так зачем посылать такой большой трафик ненужных данных, если мы можем их агрегировать еще в момент посылки?_

Именно так и работает MR.Emitter.Sorted, который является наследником MR.Emitter.Ordered (показанного выше):

```CacheObjectScript

/// Emitter which sorts by keys all emitted pairs or tuples (key, value(s))
Class MR.Emitter.Sorted Extends MR.Emitter.Ordered
{
Property AutoIncrement As %Boolean [ InitialExpression = 1 ];
/// emit $listbuild(key,value)
Method Emit(EmitList... As %String)
{
    #dim name As %String = ..GlobalName
    #dim key As %String
    #dim value As %String 

    if $get(EmitList)=1 {
        // special case - only key name given, no value
        set key = $get(EmitList(1))
        quit:key=""
        if ..AutoIncrement {
            #dim dummyX As %Integer = $increment(@name@(key)) ; $seq is non-deterministic
        } else {
            set @name@(key) = 1
        }
    } else {
        set value = $get(EmitList(EmitList))
        set EmitList = EmitList - 1
        for i=1:1:$get(EmitList) {
            #dim index As %String = $get(EmitList(i))
            quit:index=""
            set name = $name(@name@(index))
        }
        if ..AutoIncrement {
            #dim dummyY As %Integer = $increment(@name,value)
        } else {
            set @name = value
        }
    }
}
/// ...
}
```

Для самого простого случая, выдачи пары &lt;key,1&gt; или, когда значение опущено, и имеет один ключ &lt;key&gt; мы реализовали локальную оптимизацию, когда в режиме автоинкремента (AutoIncrement = 1) мы при вызове сразу инкрементируем соответствующий счетчик для ключа. Если же не включен автоинкремент, то мы просто (пере)определяем узел ключа в 1, фиксируя факт передачи ключа.

Для более общего случая, с двумя элементами, пары ключ-значение &lt;key,value&gt; или даже с большим количеством элементов &lt;key,key2,key3,…keyn,value&gt; (кортеж любой арности) у нас опять же реализовано 2 режима работы:

- при _автоинкременте_ мы сразу суммируем значение соответствующего узла, адресуемого ключом(ключами) с переданным значением;

- и _без автоинкремента_ – мы присваиваем соответствующему узлу, адресуемому данным списком ключей, переданное значение value.

Обращаем внимание, что кортеж мы передаем посредством массива, аккумулирующего переменное количество аргументов. Все элементы этого массива кроме последнего, пойдут как адреса [подындексов](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GGBL_structure#GGBL_structure_nodes_and_subscripts). Последний элемент кортежа будет считаться значением.

> _Такое необычное расширение пары «ключ-значение» в кортежи любой мощности, по нашим сведениям, является нетипичным или может быть уникальным. Нам не надо работать со строгим key-value хранилищем или bigtable хранилищем, и мы с легкостью можем работать с многомерными ключами в передаваемых элементах ("потому что можем"), что может сильно облегчить некоторые реализации алгоритмов, требующих дополнительной размерности данных, что сильно улучшает читабельность кода и упрощает понимание. В теории..._

Заметим, что мы не переопределили IsAtEnd и он пронаследовал реализацию из MR.Emitter.Ordered, таким образом он по-прежнему будет возвращать ненулевое значение по окончании данных в подузлах промежуточного хранилища.

Но GetNext нам надо переопределить, т.к. мы больше не пытаемся запомнить порядок посланных данных и формат его внутреннего хранилища поменялся:

```CacheObjectScript

Class MR.Emitter.Sorted Extends MR.Emitter.Ordered 
{
/// ...

/// returns emitted $lb(key,value)
Method GetNext() As %String
{
    #dim name As %String = ..GlobalName
    #dim value As %String
    #dim ref As %String = $query(@name,1,value)
    if ref'="" {
        zkill @ref
        #dim i As %Integer
        #dim refLen As %Integer = $qlength(ref)
        #dim baseLen As %Integer = $qlength(name)
        #dim listbuild = ""
        for i=baseLen+1:1:refLen {
            set $li(listbuild,i-baseLen)=$qs(ref,i)
        }
        set $li(listbuild,*+1)=value

        quit listbuild
    }

    quit ""
}

}

```

На выходе из GetNext() мы ожидаем [$LISTBUILD&lt;&gt;](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_flistbuild) список, но внутри хранилища данные пар/кортежей разбросаны по узлам иерархического хранилища. Функция [$QUERY](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fquery) позволяет обойти узлы с данными (значениями пар/кортежей) в массиве для последующей их перепаковки в $LISTBUILD формат, индексы из массива последовательно добавляются следующим элементом списка (посредством присваивания элементу через функцию [$LIST](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_flist). Само же значение узла хранилища (значение в паре «ключ-значение» или последний элемент кортежа) будет добавлено в конец сформированного списка через ту же функцию $LIST(listbuild,\*+1). В данном случае \*+1 как раз и обозначат номер элемента списка, следующий за текущим концом.

> _На этом неожиданном месте мы прервем наш рассказ про MapReduce в Caché. Во второй части данного повествования мы показали базовые интерфейсы инфраструктуры, которые будут использованы в дальнейшем при реализации конкретных примеров. Уже в следующей серии мы соберем это всё воедино и реализуем классический пример WordCount, но уже на ObjectScript. Не уходите далеко!_
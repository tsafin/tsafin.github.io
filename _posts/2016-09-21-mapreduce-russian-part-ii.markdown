---
layout: article
title:  "Еще раз про MapReduce. Часть 2 – базовые интерфейсы реализации"
date:   2016-09-21 00:00:00 +0300
categories: blog mapreduce
---

_В [предыдущей части серии][mapreduce-russian-part-i] мы (еще раз) попытались рассказать про Google MapReduce подход, но не показали ни строчки того, как это всё мы собираемся реализовывать в Caché ObjectScript. Время пришло – начнём рассказ сегодня._

Мы всё еще планируем сделать Caché ObjectScript реализацию максимально похожей с точки зрения интерфейсов на оригинальную Google MapReduce реализацию, показанную в предыдущей статье.

<habracut/>
Начнем с реализации абстрактных интерфейсов Mapper и Reducer.

{% highlight txt %}
/// Base class for MapReduce Mapper. 
Class MR.Base.Mapper 
{
Method Map(MapInput As MR.Base.Iterator, MapOutput As MR.Base.Emitter) [ Abstract ] { }
}

/// Base class for MapReduce Reducer. 
Class MR.Base.Reducer
{
Method Reduce(ReduceInput As MR.Base.Iterator, ReduceOutput As MR.Base.Emitter) [ Abstract ] { }
}
{% endhighlight %}

Изначально, как и в канонической реализации, мы сделали 2 отдельных интерфейса MapInput и ReduceInput. Но очень скоро осознали, что они служат одной и той же цели, и предоставляют одни и те же методы – их цель пройтись по потоку данных до конца, они оба являются итераторами. Потому, в итоге, мы имеем общий интерфейс MR.Base.Iterator:

{% highlight txt %}
Class MR.Base.Iterator
{

Method GetNext() As %String [Abstract ] { }

Method IsAtEnd() As %Boolean [Abstract ] { }

}
{% endhighlight %}

## Использование глобалов в качестве каналов связи

Оригинальная реализация GoogleMapReduce использовала файловую систему GoogleGFS как транспорт между узлами и стадиями алгоритма. В Caché у нас есть другой механизм для донесения данных между узлами (ну кроме просто TCP/UDP) – это ECP (EnterpriseCacheProtocol). Обычно он используется серверами приложений для получения данных от удаленных серверов баз данных. Но ничего не останавливает нас от построения на базе таких peer-to-peer соединений ECP некоей виртуальной управляющей шины, куда мы будем складывать данные в виде пар &lt;ключ,значение&gt; или похожие данные. Эти данные будут будут пересылаться между акторами, участвующими в конвейерах алгоритма (т.е. emit от Mapper, будет писаться в шину ECP и читаться в Reducer). Если акторы будут работать в рамках одного узла, то они, например могут использовать ультра-быстрые глобалы, отображенные в CACHETEMP, или обычные глобалы, если им нужна надежность и журналирование.

В любом случае, будь то локальные (для конфигурации на одном узле) глобалы, или глобалы удаленного узла, подключенного через ECP, глобалы являются удобным и хорошо зарекомендовавшим себя транспортом для передачи данных между вовлеченными в MapReduce функциями и классами. В таком качестве мы и станем их использовать, вместо файлов GFS или HDFS.

## Эмиттеры и черная магия

Как мы уже рассказывали в предыдущей серии, с момента когда данные выходят от Mapper, и до момента как они поступают на вход Reducer, в классической реализации на мастере проходит тяжелая операция перемешения и сортировки. В окружении, использующем глобалы к качестве транспорта, в MUMPS/Caché ObjectScript среде, мы можем полностью избежать дополнительных расходов на такую сортировку, т.к. агрегация и сортировка будут сделаны нижележащим btree\* хранилищем. (Скоро мы об этом расскажем)

Имея такие дизайн критерии, создадим для начала базовый интерфейс эмиттера:

{% highlight txt %}
Class MR.Base.Emitter Extends MR.Base.Iterator
{

/// emit $listbuild(key,value(s))
Method Emit(EmitList... As %String) [Abstract ] { }

}
{% endhighlight %}

Семантически эмиттер очень похож на интерфейс входного итератора (потому мы и пронаследовались от MR.Base.Iterator), но в дополнение к интерфейсу прохода по данным эмиттер должен уметь посылать данные в своё промежуточное хранилище (т.е. добавляем функцию Emit).

Первоначально, наша функоция Emit была очень похожа на классическую релизацию и принимала только 2 аргумента как пару &lt;ключ,значение&gt;. Но потом мы натолкнулись на периодическую необходимость передавать что-то более многомерное, длиннее чем пара (т.е. кортеж любой арности), потому в настоящий момент Emit стал функцией принимающей переменное число аргументов. Но в большинстве случаев, в жизни, там действительно поступает только пара аргументов &lt;ключ,значение&gt;

Это всё ещё абстрактный интерфейс, больше мяса будет добавлено очень скоро.

Если вам, при обработке, надо сохранять порядок поступивших элементов, то вы можете использовать реализацию ниже:

{% highlight txt %}
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
{% endhighlight %}

Заметим на полях, что в Caché глобалы – глобальны :) , и не будут очищены автоматически по завершении процессов их создавших. В отличие, например, от PPG (process-privateglobals). Но иногда все же хочется, чтобы наши промежуточные каналы, созданные для взаимодействия между стадиями конвейера MapReduce удалялись по завершении программы. Поэтому мы добавили режим автоочистки (параметр класса #AUTOCLEANUP) при котором глобал, имя которого хранится в свойстве GlobalName будет удален при закрытии объекта (в момент вызова %OnClose).

Обратите внимание, что мы форсируем один обязательный параметр в метода %New (в %OnNew генерируем $$$ThrowOnError если имя в Initval не определено). Конструктор класса ожидает получить название глобала с которым он будет работать в качестве транспорта данных.

{% highlight txt %}
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
    #dim index As %String = $order(@i%GlobalName@(""),1,value)
    if index'="" {
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
{% endhighlight %}

Надеемся, вы еще помните, что наш Emitter является наследником итератора Iterator? Посему ему нужно реализовать пару функций итератора – IsAtEnd и GetNext.

- IsAtEnd – простой: если наш служебный глобал не содержит данных (т.е. [$data(..GlobalName)](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RVBS_fdata) не возвращает 10 или 11, что означает что там в поддереве есть еще узлы с данными), то мы достигли конца потока данных;
- Emit создает узел с данными в конце текущего списка. Оформляя пару (ну или кортеж, если арность больше 2х) как элемент [$(listbuild(...))](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RSQL_d_listbuild) [listbuild].
Как известно, и как хорошо написал [Саша Коблов, $SEQUENCE](https://habrahabr.ru/company/intersystems/blog/263793/) может быть использована почти во всех местах, где использовался [$INCREMENT](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fincrement), обеспечивая при этом лучшие скорости при работе в многопроцессорном или многосерверном режиме (через ECP). В силу меньшего количества коллизий при обращении к одном узлу глобала. Потому в коде выше мы используем _$sequence_ для выделения индекса следующего элемента упорядоченного списка.
- Н другой стороне алгоритма, на стороне получателя GetNext() вытаскивает элементы из коллекции посредством простого [$ORDER(@i%GlobalName(""))](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_forder). Элемент, с полученным индексом будет удален из списка после обработки.

_Обращаем внимание, что данный вариант удаления элемента из списка/глобала не очень совместим с параллельным режимом, и нужно было бы добавить блокировки или сменить структуру данных. Но т.к. на ближайшие серии у нас будет только один Reducer, на всё множество Mapper ов, то мы отложим решение данной проблемы на будущее._

Заметим, что структура данных, реализованная MR.Emitter.Ordered по сути реализуют классическую коллекцию FIFO (&quot;FirstIn – FirstOut&quot;). Мы помещаем новый элемент в конец списка и вытаскиваем из головы списка.

### Специальный случай: эмиттер с автоагрегацией

Если вы посмотрите на те данные, что мы посылаем в между стадиями конвейера в примере word-count (ок, не сейчас, а когда мы вам покажем такую реализацию  ) то вы быстро осознаете, что:

- На самом деле нам не интересен порядок, в котором мы эмиттим пары &lt;ключ, значение&gt;. Более того, нижележащее хранилище btree\* всегда держит список ключей отсортированным для быстрого поиска, избавляя нас от необходимости сортировки на мастере, как было в классической реализации;
- И в большинстве случае, когда мы пишем пару &lt;key,1&gt; на стороне Mapper, мы предполагаем в Reducer их простую агрегацию в сумму единиц. Т.е. в случае Caché ObjectScript мы предполагаем использование [$INCREMENT](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fincrement).

_Так зачем посылать такой большой трафик ненужных данных, если мы можем их агрегировать еще в момент посылки?_

Именно так и работает MR.Emitter.Sorted, который является наследником MR.Emitter.Ordered (показанного выше):

{% highlight txt %}
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
...
{% endhighlight %}

Для самого простого случая, выдачи пары &lt;key,1&gt; или просто &lt;key&gt; мы реализовали локальную оптимизацию, когда в режиме автоинкремента (AutoIncrement = 1) мы в момент вызова сразу инкрементируем соответствующий счетчик для ключа. Без автоинкремента, мы просто (пере)определяем узел ключа в 1.

Для общего случая, с двумя элементами, пары &lt;key,value&gt; или с большим количеством элементов &lt;key,key2,key3,…keyn,value&gt; (кортеж любой мощности) у нас опять же есть 2 режима работы:

- при автоинкременте мы сразу суммируем значение соответствующего узла, адресуемого ключом(ключами) с переданным значением;

- и без автоинкремента – мы присваиваем соответствующему узлу переданное значение value.

Обращаем внимание, что кортеж мы передаем посредством массива, аккумулирующего переменное количество аргументов. Все элементы этого массива кроме последнего, пойдут как адреса subscript. А последний будет считаться значением.

_(Такое необычное расширение пары «ключ-значение» в кортежи любой мощности, по нашим сведениям, является нетипичным или может быть уникальным. Нам не надо работать со строгим key-value хранилищем или bigtable хранилищем, и мы с легкостью можем работать с многомерными ключами в передаваемых элементах, что может сильно облегчить некоторые реализации, улучшая читабельность кода и упрощая понимание)_

&lt;&lt;explaining picture&gt;&gt;

Заметим, что мы не переопределили IsAtEnd и он пронаследовал реализацию из MR.Emitter.Ordered, таким образом он по-прежнему будет возвращать ненулевое значение по истечению данных в подузлах промежуточного хранилища.

Но GetNext нам надо переопределить, т.к. мы больше не пытаемся запомнить порядок и формат внутреннего хранилища поменялся:

{% highlight txt %}
...

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

{% endhighlight %}

На выходе из GetNext() мы ожидаем $LISTBUILD&lt;&gt; список, но внутри хранилища данные пар или кортежей разбросаны по соответствующим узлам иерархического хранилища. И функция [$QUERY](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fquery) позволяет обойти узлы с данными (значениями пар/кортежей) для перепаковки их в $LISTBUILD, индексы из массива последовательно добавляются следующим элементом списка (посредством присваивания элементу через функцию [$LIST](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_flist). Само же значение узла хранилища (значение в паре «ключ-значение» или последний элемент кортежа) будет добавлено в конец сформированного списка через ту же функцию $LIST(listbuild,\*+1). В данном случае \*+1 как раз и обозначат номер элемента списка, следующий за текущим концом.

_Во второй части нашего повествования про реализацию MapReduce в Caché мы показали базовые интерфейсы инфраструктуры, которые будут использованы в дальнейшем при реализации примеров. В следующей серии мы наконец-то попытаемся собрать это все воедино и реализовать WordCount пример, но уже на ObjectScript. Не уходите далеко!_
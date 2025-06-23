---
title: "Московская встреча пользователей Си++ - часть 3"
date: 2014-02-20T02:40:00+04:00
author: Timur Safin
categories: [blog, blogger]
modified_time: 2014-04-19T16:09:53.503+04:00
image:
  feature: landscapes/feature16.jpg
  credits:
thumbnail: http://4.bp.blogspot.com/-gYnHGyGcTK0/UwKGPK64GII/AAAAAAAAQa4/B9cl6Xp2bDc/s72-c/andrew_ivanitsky_linkedin.png
blogger_id: tag:blogger.com,1999:blog-1111089994103028505.post-2562753037865060012
blogger_orig_url: http://tsafin.blogspot.com/2014/02/moscow-c-users-group-3.html
---

### Андрей Иванитский — [C++ Memory model](http://www.meetingcpp.ru/cpp/cpp-moscow-2014/2%20Memory-Model.pdf)

> Перед тем как говорить про собственно презентацию, немного о фирме Андрея Иванитского. Как мы потом узнали эта таинственная, неназванная фирма была спонсором Московского мероприятия. Но по каким-то причинам они предпочли не называть своего имени. Но мы не привыкли играть по таким правилам, потому я попытался найти того "Андрея Иванитского", который мог бы показаться релевантным здесь. Имея достаточно обширную сеть в Linkedin я попытался найти Андрея Иванитского там, и после нескольких фальстартов увидел 2 возможных кандидата. [Про размер сети сейчас сказать точно невозможно, т.к. linkedin некоторое время назад убил страницу статистики сети, но когда то они утверждали что круги 3-го порядка достигают у меня пару миллион контактов, что я расцениваю это как сеть, покрывающую большую часть российского программирования. За исключением самой дремучей его части, которые не завели себе профиля в LinkedIn.]
>
> ![andrew_ivanitsky_linkedin](http://4.bp.blogspot.com/-gYnHGyGcTK0/UwKGPK64GII/AAAAAAAAQa4/B9cl6Xp2bDc/s1600/andrew_ivanitsky_linkedin.png)
>
> Второй Андрей Иванитский работает в IT подразделении Тандем, фармацевтической фирмы. Кажется не очень релевантным. Первый же является главой тренинг центра Naumen, и занимается XP, Agile и всем таким. Все кажется вполне релевантным, посему я предлагаю считать что это тренинг центр Naumen спонсировал данное собрание. **За что ему отдельное большое спасибо!**

Но вернемся к материалам доклада. C++ memory model — не легкая тема. Не легкая и противоречивая. Мне кажется в этом отчасти виноват и сам Бьерн, т.к. он не лез в соответсвующие части и отдал на откуп Ханс Боэму ([С/C++ garbage collector](http://en.wikipedia.org/wiki/Boehm_garbage_collector) помните?). Мне всегда казалось, что Ханс очень не любит простых путей, часто запутывая остальных. Понятно, что работа с памятью в многопроцессорной среде не может быть простой. Понятно, что работа с памятью в таком множестве различных архитектур, в каком поддерживается Си++, не может быть унифицировнным. Понятно, что в стандарте придется допускать расхождения в любую сторону. Но не [до такой же степени должно быть заморочено!](http://stackoverflow.com/search?q=c%2B%2B11+%22memory+model%22)

> Now we are moving to the 2nd slides by Andrey Ivanitsky on C++ model memory #cpp #Moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434616959435419648)
> synchronize-with and happens-before as order relationships in #cpp memory model — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434619929107509248)
> memory orderings: sequenciallly consustent, acquire-release, and relaxed orderings #cpp #Moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434620352732221440)

(Часто перечисление записанного мной в Твитере будет малосвязанным, т.к. полной ясности до сих пор нет. Уж извините!) Было рассказано про отношения порядка: synchronize-with и happens-before. При рассмотрении порядка доступа к памяти (memory ordering) были введены различные типы синхронизаций: sequenciallly consistent (консистентно для следующих друг за другом), acquire-release (захват, освобождение), и relaxed orderings ("расслабленное" упорядочивание).

> why there is no copy constructor for std::atomic<>? #cpp #MOSCOW — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434621636302475264)
> Because they are sync primitives and copying such primitive is an indication you are doing something wrong #cpp — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434621751893323776)
> Totall: Do not use relaxed memory ordering ! #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434625084431413248)
> Total: recommended to use hihger level promitives (std::future, packaged_tasks) and not low level primitives std::mutex/atomic — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434625522123816960)

Были даны обобщённые советы, чтобы аудитория никогда не использовала relaxed ordering, и вообще не заморачивалась про memory ordering и блокировки, а лучше использовала высокоуровневые примитивы типа std::future или packaged_tasks. На что Григорий Демченко (предыдущий докладчик про synca библиотеку) разумно возразил, что ему не заморачиваться не удаётся, и в жизни такое часто.

> Немножко запутал, конечно, аудиторию докладчик про memory ordering #cpp #moscow #usergroup — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434627215758618624)

Подводя итог, могу заметить, что Андрей Иванитский затронул важную, мало освещённую, мало понимаемую часть стандарта Си++. Но проблема в том, что, очевидно, эта часть ещё им самим не хорошо была изучена, и как результат ясности понимания у аудитории не возникло. С другой стороны, важная часть эффекта всё же была достигнута — меня и многих других этот доклад заставил заглянуть в стандарт и соответствующие материалы группы WG21. Надеюсь, в будущем это позволит вновь вернуться к данному вопросу и рассказать о нём уже с практической точки зрения, но уже на новом уровне понимания.

*_[Продолжение следует...](../../2014/02/moscow-c-users-group-4.html)_*

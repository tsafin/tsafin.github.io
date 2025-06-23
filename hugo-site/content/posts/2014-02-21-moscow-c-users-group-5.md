---
title: "Московская группа пользователей C++ - часть 5"
date: 2014-02-21T03:57:00+04:00
author: Timur Safin
categories: [blog, blogger]
modified_time: 2014-04-19T16:08:25.214+04:00
image:
  feature: landscapes/feature15.jpg
  credits:
thumbnail: http://4.bp.blogspot.com/-qGBLUShYrJI/UwZ0UhYzrtI/AAAAAAAAQck/dKtYYssBtIA/s72-c/nesteruk_pluralsight.png
blogger_id: tag:blogger.com,1999:blog-1111089994103028505.post-4868841638276037377
blogger_orig_url: http://tsafin.blogspot.com/2014/02/moscow-c-users-group-5.html
---

### Дмитрий Нестерук — [Высокопроизводительные вычисления на С/С++](http://www.meetingcpp.ru/cpp/cpp-moscow-2014/4%20%D0%92%D1%8B%D1%81%D0%BE%D0%BA%D0%BE%D0%BF%D1%80%D0%BE%D0%B8%D0%B7%D0%B2%D0%BE%D0%B4%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B5%20%D0%B2%D1%8B%D1%87%D0%B8%D1%81%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%BD%D0%B0%20%D0%A1++.pdf)

Многие из нас знают про питерский [JetBrains](http://www.jetbrains.com/), и если хоть раз сталкивались с программированием для Android или .NET, скорее всего любят за IntelliJ IDEA/Android Studio, ReSharper и многие другие средства разработки. И если на собрание Си++ разработчиков приходит "технический евангелист" из такой уважаемой фирмы, то он сразу получает большой кредит доверия.

![nesteruk_pluralsight](http://4.bp.blogspot.com/-qGBLUShYrJI/UwZ0UhYzrtI/AAAAAAAAQck/dKtYYssBtIA/s1600/nesteruk_pluralsight.png)

Кроме всего прочего Дмитрий Нестерук является MVP (Most-valuable Professional) по Visual C# с 2009 года. Он разработчик курсов на PluralSight по Matlab и CUDA, любит заниматься финансовой математикой (чтобы это ни значило), закончил британский университет в Саутгемптоне, и живёт в Швеции. Всё говорило за то, что его длинная, полуторачасовая презентация должна быть очень интересна и полезна аудитории ("она же про HPC/высокопроизводительные вычисления!"), но...

> Dmitry Nesteruk on HPC - is the next #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434642468856791040)
> Dmitry Nesteruk is the technical evangelist in JetBrains #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434646379122540544)

Начал Дмитрий с рассказа про управляемый (managed) и нативный код. И перешёл сразу же к управляемому коду. Что, конечно, слегка напрягало, т.к. аудитории это было в-общем-то чуждо.

> Смешно он переносимость на русском называет — "портативность" #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434647397285650433)

> Не знаю почему, может в силу больших ожиданий от "евангелиста", мне периодически казалось что Дмитрию непривычно и некомфортно выступать на русском. Например, иногда смешили переводы на русский некоторых терминов, так он применял "портативный" вместо "переносимый" для "portable". Кажется, просто не хватило адекватного review данной презентации.

> He has an impression that Microsoft JIT-compiler does not use SSE* at all (worth to check) #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434648151123697666)

Как и в каждой презентации про HPC было рассказано про disk-bound vs cpu-bound, параллелизм, SIMD/SSE* (и не сказано про AVX).

> Shows Incredibuild demo which uses cloud for remote concurrent compilation #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434650127009996801)

JetBrains пытается ускорить все стадии циклов разработки, начиная от редактирования и заканчивая параллельной сборкой. На этом месте Дмитрий показал Incredibuild как средство параллелизации построения большого проекта (привет [DISTCC](http://ru.wikipedia.org/wiki/Distcc)).

> Dmitry is a big fan for hw solution for parallelism extensions: gpgpu, fpga, xeon phi, etc #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434654302049538048)
> He thinks tha CUDA is wider and better used than OpenCL #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434655998741995521)
> CUDA is really flavour of managed code #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434656305760841729)

Далее он перешёл к рассказу про высокоуровневые технологии параллелизации/векторизации вычислений: CUDA (сказал много) vs OpenCL (сказал почти ничего). Когда надо больше параллелизма (но нет ещё достаточно мотивации и денег на реальный кластер), то технологии FPGA и Xeon Phi могут помочь как ускорители вычислений, работающих на desktop компьютерах.

> А ещё он смешно AMD всегда ATI зовёт. Где он был последние несколько лет? #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434655285710295040)
> Some attendees think we are getting far, far away from C++ here. CUDA is not very much ontopic here indeed. #cpp #moscow still hope — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434657454421323776)

В этом месте некоторая часть аудитории достигла точки кипения и всё же спросила: "Когда же про Си++ то начнём?". Резонный вопрос.

> He is good proponent of easiness of porting to Xeon Phi/MIC because of software stack elegance #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434663766848856065)

Интеловские технологии Xeon Phi aka MIC, большим фанатом которых с недавних пор Дмитрий является, стали пожалуй спасителями презентации и впервые он говорил собственно о Си++ (Intel C++ compiler) и как его применять для компиляции MIC кода.

> and as the bonus he showed their C++ IDE. Still barebones enough. #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434664404542447616)

Ну и чтобы Си++ разработчики не чувствовали себя совсем обманутыми, нам под конец ещё раз показали текущее состояние дел их (JetBrains) кросс-платформенной среды разработки Си++ со всеми, свойственными JetBrains пирогами и плюшками (удобные средства рефакторинга и кодогенерации). Но вы скорее всего это уже видели [на Хабре месяц назад](http://habrahabr.ru/company/JetBrains/blog/212115/). И должен признаться, что визуально это пока не очень впечатляет, выглядит не сильно лучше чем KDE редактор Kate, к которому приделали меню рефакторинга. Впрочем, на таком раннем этапе развития продукта никто большего и не ожидал.

В целом, выступление Дмитрия оставило двойственное впечатление: с одной стороны рассказ про технологии, скорее всего был многим полезен, но всё же его надо читать в другое место и другое время, это был очень сильный оффтопик для группы пользователей Си++. Персонально я не узнал ничего нового, и лучше бы ещё какой материал про Си++11/14 послушал. Слишком много интересного происходит последние пару лет собственно в языке Си++, чтобы тратить время на такие общеобразовательные лекции. Извините.

*_[Читайте заключение в следующей статье...](../../2014/03/moscow-c-users-group-final.html)_*

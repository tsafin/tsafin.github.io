---
title: "Московская встреча пользователей Си++ - часть 4"
date: 2014-02-19T03:27:00+04:00
author: Timur Safin
categories: [blog, blogger]
modified_time: 2014-03-18T19:20:13.817+04:00
image:
  feature: landscapes/feature17.jpg
  credits:
thumbnail: http://2.bp.blogspot.com/-HLnFMmdIbok/UwPqWu8jUeI/AAAAAAAAQcQ/PvcV3bI0oR4/s72-c/boost_cookbook.png
blogger_id: tag:blogger.com,1999:blog-1111089994103028505.post-5371809379345555161
blogger_orig_url: http://tsafin.blogspot.com/2014/02/moscow-c-users-group-4.html
---

### Антоний Полухин — [Boost и C++11/C++14: Новости с фронта, или обо всём понемногу](http://www.meetingcpp.ru/cpp/cpp-moscow-2014/3%20C++andBoost4.pdf)

Доклад Антона Полухина, одного из контрибьюторов Boost-а ("В свободное от работы время"), не был посвящен какой-то определенной теме, а рассказывал о многом, что было недавно (за прошлый год) сделано в Boost. Больше всего такой рассказ был похож на, скажем, квартальный "Status Update" доклад о достижениях команды, часто делаемый в больших корпорациях. К нему ты не сильно обычно готовишься (15 минут — час), в него ты быстро набрасываешь все основные пункты из отчетов за период, и большую часть информации доносишь уже на презентации. Обычно аудитория в контексте (они читали твои регулярные отчеты), ты знаешь все ответы на вопросы (потому что ты собственно все это и делал), и такой доклад не сильно отвлекает от дел. Ты ведь программист, а не менеджер, тебе надо кодить, а не языком молотить?

Именно такая легкость и некоторая часть импровизации импонировала в докладе Антона. Даже несмотря на малую связанность экранов между собой :) Нам всем был интересен прогресс в библиотеке Boost, т.к. большинство аудитории являлось, надеюсь, этой библиотеки пользователями.

> Next preseter: Anton Polukhin about Boost and C++11/14 #cpp — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434633715684089856)
> __PRETTY_FUNCTION__ and variadic templates (reduced executablel code size) #cpp11 — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434636188553453568)

Антон рассказал как введение в Си++ шаблонов с переменным количеством аргументов (variadic templates) счастливым образом отразилось на простоте кода библиотеки, уменьшении размера кода и отладочной информации.

> Boost for Android is being developed for a couple of years already #cpp #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434637493430800386)
> Next release of Boost will have Android changes #cpp #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434637629020053504)
> github:regression_android project for Boost/Android regression testing — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434637724981530625)

Было упомянуто, что была активность по адаптации Boost к Android NDK, и все внесённые модификации должны быть доступны к следующему релизу. Соответствующие билд-боты будут поддерживать состояние Android порта через запуск набора регрессионных тестов.

> Since new year Boost has moved from SVN to GIT — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434637892648828928)
> So far Boost developers annoyed with Git #cpp11 #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434638159553380353)

Как-то так получилось, что Антон пропустил дискуссию, где решалось на какую DVCS переходить, и не понял почему была выбрана Git, а не скажем Mercurial. Но уж что случилось, то случилось. С начала года Boost теперь хостится на Github, и разработчики, вне зависимости как они относятся к Git (плохо относятся, чего уж) обязаны его использовать. Может привыкнут когда, так везде. В любом случае, побочным эффектом перехода на GitHub был значительный рост внешних патчей. Очевидно, что популярность GitHub тут сыграла определённую роль.

> Next Boost will support VS2013 #cpp11 #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434638647208321025)
> Appeared that VS2013 was not correntlly handling variadic templates with Boost #cpp11 #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434639006022660096)

При недавнем выпуске Visual Studio 2013 разработчики и пользователи Boost обнаружили, что новый VS2013 несовместим с последним Boost в С++11 режиме. Хотя ничего не предвещало, и бета версия компилятора была вполне в рабочем состоянии. Пришлось править Boost и большей частью выпиливать variadic-template в некоторых частях проекта.

> At the end he has requestsed help for boost ticket #8555. Commits welcome #cpp11 #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434640265219805184)

Не знаю из каких соображений, но Антон упомянул об одном странном баге, который никто не знает как лечить — [ticket #8555](https://svn.boost.org/trac/boost/ticket/8555). Если Вы знаете в чём закавыка — все будут премного благодарны.

> There is project which tries to migrate from bjam to cmake, but it has problems #cpp11 #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434640418823622656)
> Anton explains why bost.coroutines were postponed for reworking (to get rid of mem allocations) #cpp11 #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434641828403363840)
> Apparentlly Anton Polukhin still has not hard-copy of his own Boost book. Oops! #cpp11 #boost #moscow — Timur Safin (40+) [15 февраля 2014](https://twitter.com/tsafin/statuses/434641642830561280)

И, кстати, вы, наверное, знаете, что Антон является автором книги про Boost — ["Boost C++ Application Development Cookbook"](http://www.packtpub.com/boost-cplusplus-application-development-cookbook/book)?

Так вот, оказывается у него до сих пор нет ни одной копии этой книги. Издательство уже несколько раз пыталось прислать книгу автору, но каждый раз что-то не срасталось, и она возвращалась. Российская таможня — твёрдый орешек!

![boost_cookbook](http://2.bp.blogspot.com/-HLnFMmdIbok/UwPqWu8jUeI/AAAAAAAAQcQ/PvcV3bI0oR4/s1600/boost_cookbook.png)

Даже с учётом таких проблем с таможней, я думаю, имеет смысл (хотя бы некоторым из нас) пойти на сайт издательства и купить электронную и/или твёрдую копию этой полезной книги. Поддержим копеечкой отечественного автора!

*_[Продолжение следует...](../../2014/02/moscow-c-users-group-5.html)_*

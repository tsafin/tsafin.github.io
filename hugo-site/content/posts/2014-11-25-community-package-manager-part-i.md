---
title: "Intersystems Caché - Approaching Community Package Manager - Part I"
date: 2014-11-25T17:06:00.002+03:00
author: Timur Safin
tags:
  - package manager
  - Intersystems
  - Caché
categories: [blog, blogger]
modified_time: 2014-11-25T17:29:32.777+03:00
image:
  feature: landscapes/feature12.jpg
  credits:
thumbnail: http://4.bp.blogspot.com/-c7mRsvva_ko/VHRyY4wI7VI/AAAAAAAAbL0/2cxELKiyLaM/s72-c/timeline.png
blogger_id: tag:blogger.com,1999:blog-1111089994103028505.post-2325275840240469991
blogger_orig_url: http://tsafin.blogspot.com/2014/11/community-package-manager-part-i.html
---

> Here is the problem as I see in the Caché developers community - if you are newbie COS/Ensemble/DeepSee developer then it's very hard to find any suitable 3rd party component, library or utility. They are spread over the Internet, some of them are in the GitHub, some of them in SourceForce, rare ones are on their own sites, etc. Yes, there are many useful components or tools (there are even standalone debugger or VCS) but it takes *some time* to discover all the useful location, and get to used to this situation.
>
> **There is no single location and there is no convenient way to find and install extension or utility.**
>
> Which is not very competitive comparing to other languages and development environment. In these articles I will try to investigate this problem further (this part I), and will propose some simple decision ([part II](/2014/11/community-package-manager-part-ii.html))

Что вы думаете о "package manager" и его важности для успеха сообщества? Для меня package manager — это абсолютно необходимый и важнейший ингредиент для успеха языка и зрелости экосистемы. Нет ни одного языка, где не было бы удобного package manager с огромной коллекцией сторонних пакетов. После всех этих лет с Perl, Python, JavaScript, Ruby, Haskell, Java (и другими) вы привыкаете, что когда начинаете новый проект, у вас есть масса внешних компонентов, которые помогают быстро и удобно собрать рабочий продукт. `PM install this`, `PM install that` — и вы быстро получаете что-то работающее. Сообщество работает на вас.

Эти слова о [CPAN](http://en.wikipedia.org/wiki/CPAN) и его опыте хорошо иллюстрируют важность этого прецедента и его влияние на другие языки и среды:

> "Experienced Perl programmers often comment that half of Perl's power is in the CPAN. It has been called Perl's killer app. Though the [TeX](http://en.wikipedia.org/wiki/TeX) typesetting language has an equivalent, the [CTAN](http://en.wikipedia.org/wiki/CTAN) (and in fact the CPAN's name is based on the CTAN), few languages have an exhaustive central repository for libraries. The [PHP](http://en.wikipedia.org/wiki/PHP) language has [PECL](http://en.wikipedia.org/wiki/PHP_Extension_Community_Library) and [PEAR](http://en.wikipedia.org/wiki/PHP_Extension_and_Application_Repository), [Python](http://en.wikipedia.org/wiki/Python_(programming_language)) has a [PyPI](http://en.wikipedia.org/wiki/PyPI) (Python Package Index) repository, [Ruby](http://en.wikipedia.org/wiki/Ruby_(programming_language)) has [RubyGems](http://en.wikipedia.org/wiki/RubyGems), [R](http://en.wikipedia.org/wiki/R_(programming_language)) has [CRAN](http://en.wikipedia.org/wiki/CRAN_(R_programming_language)), [Node.js](http://en.wikipedia.org/wiki/Node.js) has [npm](http://en.wikipedia.org/wiki/Npm_(software)), [Lua](http://en.wikipedia.org/wiki/Lua_(programming_language)) has [LuaRocks](http://en.wikipedia.org/wiki/LuaRocks), [Haskell](http://en.wikipedia.org/wiki/Haskell_(programming_language)) has [Hackage](http://en.wikipedia.org/wiki/Hackage) and an associated installer/make clone [cabal](http://en.wikipedia.org/wiki/Cabal_(software)), but none of these are as large as the CPAN. Recently, [Common Lisp](http://en.wikipedia.org/wiki/Common_Lisp) has a de facto CPAN-like system - the Quicklisp repositories. Other major languages, such as [Java](http://en.wikipedia.org/wiki/Java_(programming_language)) and [C++](http://en.wikipedia.org/wiki/C++), have nothing similar to the CPAN (though for Java there is central [Maven](http://en.wikipedia.org/wiki/Apache_Maven))."

> The CPAN has grown so large and comprehensive over the years that Perl users are known to express surprise when they start to encounter topics for which a CPAN module doesn't exist already.

## Таблица: Системы управления пакетами

| Операционная система / Тип | Системы управления пакетами |
|---------------------------|-----------------------------|
| **Linux (dpkg)**          | APT, aptitude, dselect, Ubuntu Software Center |
| **Linux (RPM)**           | YUM, APT-RPM, poldek, up2date, urpmi, ZYpp, dnf |
| **Linux (tar-ball)**      | slapt-get, slackpkg, zendo, netpkg, swaret |
| **Linux (Other)**         | appbrowser, Conary, Equo, pkgutils, pacman, PETget, PISI, Portage, Smart Package Manager, Steam, Tazpkg, Upkg |
| **OS X (pkg)**            | Mac App Store, rudix, Steam |
| **Windows**               | Windows installer, Windows Store, Allmyapps, Cygwin, Npackd, Windows Package Manager, Steam, NuGet, Chocolatey, NSIS, wpkg |
| **Solaris**               | SysV (pkgadd), Image Packaging System, OpenCSW |
| **Embedded system**       | см. ниже |
| **Mobile OS (iOS)**       | App Store |
| **Mobile OS (Android)**   | Google Play, GetJar, Amazon Appstore, SlideME, F-Droid |
| **Mobile OS (Windows Phone)** | Windows Phone Store |
| **Windows 8.x/RT**        | Windows Store |
| **Digital distribution / Application Extensions** | Chrome Web Store, Mozilla Add-ons |
| **Cross-platform**        | dpkg, Image Packaging System, OpenPKG, pkgsrc, Zero Install (0install), TWW Tools, IBM SmartCloud Enterprise, Nix package manager, wpkg |
| **Sourcecode-based (Linux)** | Portage, emerge, Compile, apt-build, Sorcery, Spike, ABS |
| **Sourcecode-based (OS X)** | fink, MacPorts, Homebrew, pkgsrc |
| **Hybrid systems**        | FreeBSD Ports, MacPorts, pkgsrc, ports collection |

_Источник: https://en.wikipedia.org/wiki/Package_manager (редакция и упрощение)_

Здесь приведена сокращённая и упрощённая схема из статьи WikiPedia о менеджерах пакетов. Их очень много — как основанных на исходниках, так и бинарных, специфичных для архитектуры, ОС или кроссплатформенных. Далее я попробую рассмотреть их подробнее. Также я добавлю к картине языковые менеджеры пакетов, иначе она будет мало полезна. Ведь мы говорим о менеджерах пакетов для языков/платформ разработки!

> Важное наблюдение: чем популярнее ОС или экосистема API, тем больше шансов, что для неё появится несколько конкурирующих менеджеров пакетов. Посмотрите на ситуацию в Linux, Windows или Mac OS X. Чем больше менеджеров пакетов используется, тем быстрее развивается экосистема. Наличие нескольких менеджеров — не обязательное условие быстрого развития, но скорее его побочный эффект. Если у нас когда-нибудь появится несколько менеджеров пакетов с разными репозиториями — это будет скорее признак здоровой экосистемы, а не проблемы.

## Упрощённая временная шкала

Далее я рассмотрю основные ОС и языковые менеджеры пакетов, размещу их на временной шкале, объясню их особенности и интерес для нас, а затем сделаю выводы для Caché как платформы.

Как известно, "лучше один раз увидеть, чем сто раз услышать", поэтому для наглядности я нарисовал простую временную шкалу, где отмечены все "важные" (на мой взгляд) менеджеры пакетов, существовавшие к настоящему моменту. Верхняя часть — языковые менеджеры, нижняя — ОС/дистрибутивные. Ось X — шаг 2 года (с января 1992 по сегодня).

![timeline](http://4.bp.blogspot.com/-c7mRsvva_ko/VHRyY4wI7VI/AAAAAAAAbL0/2cxELKiyLaM/s640/timeline.png)

*Package managers: Timeline from 1992 till 2014*

### CTAN, CPAN & CRAN

90-е годы — эпоха source-based менеджеров пакетов. Интернет уже работал как канал распространения, но все менеджеры работали по одному сценарию:

- По имени пакета менеджер скачивал tar-архив;
- Распаковывал его в пользовательскую/системную область;
- Запускал скрипт сборки и установки в локальную дистрибуцию.

CTAN был первым языковым репозиторием, где появилась удобная практика установки расширений из центрального хранилища. Но настоящий взрыв произошёл, когда Perl-сообщество внедрило эту модель — с момента появления CPAN в 1995 году он собрал "140,712 Perl modules in 30,670 distributions, written by 11,811 authors, mirrored on 251 servers."

Работать в такой среде очень удобно: для любой задачи первым делом спрашиваешь — "а нет ли уже модуля для XXX?" — и через пару секунд (ну, минут, учитывая интернет 90-х) после одной команды, например:

```bash
cpan install HTTP::Proxy
```

у тебя уже скачан модуль, распакован исходник, сгенерирован makefile, всё собрано, протестировано и установлено в локальную дистрибуцию. Можно сразу писать `use HTTP::Proxy;`!

Большинство модулей CPAN — чисто Perl, но Makefile.pl достаточно гибок, чтобы собирать и бинарные компоненты (например, C-программы, которые скачиваются и компилируются под нужный ABI).

Ту же модель использовали Tex/CTAN и R/CRAN. Проблема CRAN — язык R не так популярен, но даже он собрал 6000+ расширений.

### Мир BSD: FreeBSD Ports, NetBSD pkgsrc, и Darwin Ports

В то же время, в середине 90-х, FreeBSD представила свой способ распространения открытого ПО через свою "коллекцию портов". Различные производные от BSD (такие как OpenBSD и NetBSD) поддерживали свои собственные коллекции портов, с незначительными изменениями в процедурах сборки или поддерживаемых интерфейсах. Но в любом случае базовый механизм оставался прежним после вызова `cd /port/location; make install`:

- Исходники устанавливались с соответствующих носителей (будь то CD-ROM, DVD или интернет-сайт);
- Продукт собирался с использованием данного Makefile и доступных компиляторов;
- А цели сборки устанавливали согласно правилам, записанным в Makefile или другом файле определения пакета.

Существовала возможность обрабатывать все зависимости данного порта, если была такая просьба, так что полная установка для большего пакета всё ещё могла быть инициирована через *одну команду*, и менеджер пакетов *адекватно обрабатывал все рекурсивные зависимости*.

С точки зрения лицензий и их предшественников, я рассматриваю Darwin Ports/MacPorts как производную идею этой коллекции портов BSD — у нас по-прежнему есть коллекция открытого программного обеспечения, которая удобно обрабатывается одной командой, т.е.:

```bash
$ sudo port install apache2
```

> Стоит подчеркнуть — до сих пор как языковые репозитории (CTAN/CPAN/CRAN), так и коллекции портов BSD все представляли собой 1-й класс менеджеров пакетов — *sourcecode-based* менеджеры пакетов.

### Linux: Debian и Red Hat

Модель управления пакетами на основе исходного кода работала хорошо (до некоторой степени) и создавала впечатление полной прозрачности и контроля. Но существовало несколько "небольших" проблем:

- Не всё ПО можно было развернуть в виде исходников, ведь есть ещё и проприетарное ПО, которое тоже нужно удобно развёртывать;
- А сборка большого проекта могла занимать *огромное количество времени* (часы).

Очевидно, что возникла необходимость установить способ распространения пакетов (и всех зависимостей) в бинарной форме, уже скомпилированных для данной архитектуры и готовых к использованию. Так появились бинарные форматы пакетов, и первым, представляющим интерес для нас, стал формат .deb, используемый менеджером пакетов Debian (dpkg). Исходный формат, представленный в Debian 0.93 в марте 1993 года, был просто обёрткой tar.gz с некоторыми магическими ASCII-префиксами. В настоящее время пакет .deb одновременно и проще, и сложнее — это просто архив AR, состоящий из 3 файлов (debian-binary с версией, control.tar.gz с метаданными и data.tar.* с установленными файлами). На практике вы редко используете dpkg — большинство современных дистрибутивов на базе Debian используют [APT](https://en.wikipedia.org/wiki/Advanced_Packaging_Tool) (расширенный инструмент упаковки). Удивительно (по крайней мере, для меня, когда я начал писать этот обзор), что APT вышел за пределы дистрибутивов Debian и был портирован на дистрибутивы на базе Red Hat (APT-RPM), Mac OS X (Fink) и даже Solaris.

> "Apt can be considered a [front-end](https://en.wikipedia.org/wiki/Advanced_Packaging_Tool) to [dpkg](https://en.wikipedia.org/wiki/Dpkg), friendlier than the older [dselect](https://en.wikipedia.org/wiki/Dselect) front-end. While dpkg performs actions on individual packages, apt tools manage relations (especially dependencies) between them, as well as sourcing and management of higher-level versioning decisions (release tracking and version pinning)."

Функциональность и простота использования apt-get оказали влияние на все последующие менеджеры пакетов.

Другим хорошим примером бинарных систем упаковки является RPM (Red Hat Package Manager). RPM был представлен с Red Hat V2.0 в конце 1995 года. Red Hat быстро стал самым популярным дистрибутивом Linux (и надёжные функции RPM были одними из факторов, выигравших конкуренцию здесь, по крайней мере, до некоторого момента). Поэтому не удивительно, что RPM начал использоваться всеми дистрибутивами на базе RedHat (например, Mandriva, ASPLinux, SUSE, Fedora или CentOS), но даже дальше, за пределами Linux, он также использовался в Novell Netware или IBM AIX.

Аналогично APT/dpkg существует обёртка Yum для RPM-пакетов, которая часто используется конечными пользователями и предоставляет аналогичные высокоуровневые услуги, такие как отслеживание зависимостей или управление сборками/версиями.

### Магазины мобильного ПО: iOS App Store, Android Market/Google Play

С момента появления App Store для iOS от Apple, а затем и Google Android Market, у нас появились, вероятно, самые популярные программные репозитории на сегодняшний день. Это, по сути, специфичные для ОС менеджеры пакетов с дополнительным API для онлайн-покупок. Это ещё не проблема для App Store, но является таковой для Android Market / Google Play — существует множество аппаратных архитектур, используемых устройствами Android (ARM, X86 и MIPS на данный момент), поэтому перед тем, как клиент сможет скачать и установить бинарный пакет с исполняемым кодом для какого-либо приложения, необходимо предпринять дополнительные меры.

В любом случае, независимо от того, где и как такая оптимизация выполняется, эта часть процесса установки считается основной частью услуг упаковки программного обеспечения, предоставляемых операционной системой. Если программное обеспечение должно работать на многих аппаратных архитектурах, и если мы не разворачиваем его в виде исходного кода (как в случае с BSD или Linux), то репозиторий и менеджер пакетов должны обрабатывать эту проблему прозрачно и эффективно.

> На данный момент я не рассматриваю кроссплатформенные вопросы и в первой реализации буду иметь в виду только полностью открытые пакеты. Возможно, мы вернёмся к этому вопросу позже, чтобы решить проблемы как кросс-версийности, так и кросс-архитектурности одновременно.

### Приложения для Windows: Chocolatey Nuget

Это была давно назревшая недостающая функция — несмотря на популярность Windows на рынке, у нас не было центрального репозитория, такого же удобного, как apt-get для Debian, где мы могли бы найти и установить любые (многие/большинство) доступные приложения. Ранее существовал [Windows Store](http://windows.microsoft.com/en-us/windows-8/apps#Cat=t0) для приложений Windows Metro (но никто не хотел их использовать :) ), даже до этого существовал удобный [NuGet package manager](https://www.nuget.org/packages), устанавливаемый как плагин для Visual Studio, но (по впечатлениям) он обслуживал только .NET-пакеты и не был нацелен на "обычные приложения для рабочего стола Windows". Ещё дальше находился [Cygwin repository](https://cygwin.com/index.html), где вы могли скачать (довольно удобно) все приложения Cygwin (от bash до gcc, git или X-Window). Но это, опять же, не касалось "любого обычного приложения для Windows", а только портированных приложений POSIX (Linux, BSD и других совместимых с UNIX API), которые могли быть перекомпилированы с использованием Cygwin API.

Поэтому разработка [Chocolatey Nuget](https://chocolatey.org/) в 2012 году стала для меня приятным сюрпризом: имея NuGet в качестве основы для менеджера пакетов, с добавленным волшебством PowerShell при установке и с добавленным центральным репозиторием [здесь](https://chocolatey.org/packages), вы могли бы получить тот же уровень удобства, что и с apt-get в Linux. Всё могло быть развернуто/упаковано как какой-то пакет Chocolatey, от [Office 365](https://chocolatey.org/packages/Office365HomePremium) до [Atom editor](https://chocolatey.org/packages/Atom) или [Tortoise Git](https://chocolatey.org/packages/TortoiseGit), или даже [Visual Studio 2013 Ultimate](https://chocolatey.org/packages/VisualStudio2013Ultimate)! Это быстро стало лучшим другом администраторов Windows, и многие дополнительные инструменты, использующие Chocolatey в качестве своей низкоуровневой основы, были разработаны, лучший пример такого — [BoxStarter](https://boxstarter.org/), самый простой и быстрый способ установить программное обеспечение для Windows на свежие установки Windows.

Chocolatey не показывает ничего нового, чего мы не видели раньше в других операционных системах, он просто демонстрирует, что имея надёжную основу (NuGet в качестве менеджера пакетов, PowerShell для пост-обработки и способный центральный репозиторий), можно построить универсальный менеджер пакетов, который быстро привлечёт внимание, даже для операционной системы, где это было необычно. Кстати, стоит упомянуть, что Microsoft решила присоединиться к этому направлению и теперь использует Chocolatey в качестве одного из репозиториев, который будет доступен в их собственном [OneGet package manager](http://blogs.msdn.com/b/garretts/archive/2014/04/01/my-little-secret-windows-powershell-oneget.aspx), который будет доступен начиная с Windows 10.

> Личное замечание: я должен признаться, мне не нравится OneGet так же, как и Chocolatey — там слишком много скриптинга на PowerShell, который мне нужно будет настраивать для OneGet. А с точки зрения удобства использования Chocolatey скрывает все эти детали и выглядит гораздо проще.

### Node.js NPM

Существует множество факторов, которые привели к недавнему драматическому успеху JavaScript в качестве серверного языка. И одним из самых важных факторов этого успеха (по крайней мере, на мой взгляд) является наличие центрального репозитория модулей для Node.js — [NPM (Node Package Manager)](https://www.npmjs.org/). NPM поставляется в комплекте с дистрибутивом Node.js, начиная с версии 0.6.3 (ноябрь 2011).

NPM смоделирован аналогично CPAN: у вас есть обёртка, которая из командной строки подключается к центральному репозиторию, ищет запрашиваемый модуль, скачивает его, парсит метаинформацию пакета, и если есть внешние зависимости, то обрабатывает их рекурсивно. Через несколько мгновений у вас есть рабочие бинарные файлы и исходники, доступные для локального использования:

```bash
C:\Users\Timur\Downloads>npm install -g less
npm http GET https://registry.npmjs.org/less
npm http 304 https://registry.npmjs.org/less
npm http GET https://registry.npmjs.org/graceful-fs
npm http GET https://registry.npmjs.org/mime
npm http GET https://registry.npmjs.org/request
…
npm http GET https://registry.npmjs.org/isarray/-/isarray-0.0.1.tgz
npm http 200 https://registry.npmjs.org/isarray/-/isarray-0.0.1.tgz
npm http 200 https://registry.npmjs.org/asn1
npm http GET https://registry.npmjs.org/asn1/-/asn1-0.1.11.tgz
npm http 200 https://registry.npmjs.org/asn1/-/asn1-0.1.11.tgz
C:\Users\Timur\AppData\Roaming\npm\lessc -> C:\Users\Timur\AppData\Roaming\npm\node_modules\less\bin\lessc
less@2.0.0 C:\Users\Timur\AppData\Roaming\npm\node_modules\less
├── mime@1.2.11
├── graceful-fs@3.0.4
├── promise@6.0.1 (asap@1.0.0)
├── source-map@0.1.40 (amdefine@0.1.0)
├── mkdirp@0.5.0 (minimist@0.0.8)
└── request@2.47.0 (caseless@0.6.0, forever-agent@0.5.2, aws-sign2@0.5.0, json-stringify-safe@5.0.0, tunnel-agent@0.4.0, stringstream@0.0.4, oauth-sign@0.4.0, node-uuid@1.4.1, mime-types@1.0.2, qs@2.3.2, form-data @0.1.4, tough-cookie@0.12.1, hawk@1.1.1, combined-stream@0.0.7, bl@0.9.3, http-signature@0.10.0)
```

Стоит отметить, что изменения, которые авторы NPM внесли в практику менеджеров пакетов — они используют формат JSON для метаинформации пакета, вместо основанных на Perl, используемых в CPAN.

---

_Продолжение следует..._

**Ок, достаточно о текущей практике в других экосистемах. Во [второй части этой статьи](/2014/11/community-package-manager-part-ii.html) мы подробнее поговорим о простом предложении по менеджеру пакетов для Caché. Stay tuned!**

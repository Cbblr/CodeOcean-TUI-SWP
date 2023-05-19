## reguläre Ausdrücke des pyunit adapters

### Erläuterung und Beispiele für bestehende reguläre Ausdrücke

Die folgenden RegEx enthalten alle mindestens eine “capturing group”. Die Muster, die in diesen Gruppen (innerhalb des Regex) definiert sind, können später als konkreter Wert extrahiert und somit weiterverwendet werden. "(\d+)" im COUNT_REGEXP definiert bspw. ein Muster, das eine oder mehrere Zahlen enthält. der konkrete Zahlenwert kann dann später für jeden gefunden match ausgelesen werden. 
Dazu wird in unserem Fall nach der Deklaration die _scan Methode_ verwendet. Diese filtert (im Gegensatz zur match Methode) für _jedes_ match die konkreten Werte der entsprechenden Capturing Group heraus und schreibt diese in ein Array. 

#### RegEx: COUNT_REGEXP (1)
```ruby
COUNT_REGEXP = /Ran (\d+) test/
```
* filtert nach Textabschnitten, die das Muster "Ran " gefolgt von einer oder mehr Ziffern und dann " test" enthalten.
* (Die Klammern um \d+ legen eine sogenannte "capturing group" fest, die das Muster von min. einer oder mehr Ziffern enthält. Diese Gruppe kann später in der Verarbeitung des Treffers verwendet werden, um den genauen Wert der Ziffern zu extrahieren.
* Durch die folgende Scan Methode wird hier also die Anzahl der durchlaufenen Test gefiltert

**--> Anzahl der durchgeführten Test**

#### RegEx: FAILURES_REGEXP (2)

```ruby
FAILURES_REGEXP =/FAILED \(.*failures=(\d+).*\)/
```
* filtert Zeichenfolge, die das Muster "FAILED (_irgendwelcher Text_ failures=_irgendeine Zahl_ _irgendwelcher Text_)" enthält, wobei die Zahl in der Mitte erfasst wird, damit sie später verwendet werden kann.
* Bei _irgendeine Zahl_ ist mindestens eine Ziffer gefordert. _irgendwelcher Text_ kann auch nicht vorhanden sein.
* FAILED muss dabei durch Leerzeichen getrennt alleine stehen --> nicht irgendwo im Text vorkommen
* daher: Die Anzahl der failures bzw. der fehlgeschlagenen Tests wird erfasst

**--> Anzahl der fehlgeschlagenen Tests**

#### RegEx: ERRORS_REGEXP (3)
```ruby
ERRORS_REGEXP = /FAILED \(.*errors=(\d+).*\)/
```
* identisch mit vorhergehenden aber errors= anstelle von failures= 
* daher: Anzahl der aufgetretenen Errors wird erfasst

**--> Anzahl der aufgetretenen Errors**

#### RegEx: ASSERTION_ERROR_REGEXP (4)
```ruby
ASSERTION_ERROR_REGEXP = /^(ERROR|FAIL):\ (.*?)\ .*?^[^.\n]*?(Error|Exception):\s((\s|\S)*?)(>>>[^>]*?)*\s\s(-|=){70}/m
```
* filtert Zeichenketten, nach folgenden Mustern (chronologisch gelistet):
    *   Startet mit "ERROR:" oder "FAIL:". Bei einem match wird die jeweils auftretende Alternative in Form einer Capturing Group erfasst
    *   Ein Leerzeichen nach dem Doppelpunkt und dann ein beliebiger Text (0 oder mehr Zeichen), der durch die  Capturing Group "(.*?)" erfasst wird. Bei dieser Erfassung ist gesondert die Kennzeichnung als "non-greedy" (Das Fragezeichen ist hier also kein klassischer Modifikator sondern spezifiziert den Stern Modifikator genauer) zu beachten. Demzufolge wird der Ausdruck so wenig Zeichen wie möglich erfassen, um trotzdem noch dem Muster zu entsprechen. 
    *   "\ .*?" sucht nach einem Leerzeichen gefolgt von null oder mehr beliebigen Zeichen ("non-greedy") (wie voher nur keine capturing group)
    *   "^ [^.\n]*?"" - sucht nach dem Anfang einer Zeile, die keine Punkte oder Zeilenumbrüche enthält, und erfasst null oder mehr Zeichen ("non-greedy")
    *   (Error|Exception):\s - sucht entweder nach dem Wort "Error" oder dem Wort "Exception", gefolgt von einem Doppelpunkt und einem Leerzeichen (zu beachten ist, dass \s mehr umfasst als einfache Lehrzeichen z.B. Leerzeichen, Tabulatoren, Zeilenumbrüche)
    *   \S umfasst alles was kein Leerzeichen im Sinne von \s ist. "((\s|\S)*?)" sucht folglich nach null oder mehr beliebigen Zeichen ("non-greedy"), wobei sowohl Leerzeichen als auch Nicht-Leerzeichen erfasst werden können
    *   "(>>>[^>]*?)*" sucht nach ">>>" und erfasst dieses und 0 bis beliebig viele folgende Zeichen, die nicht ">" sind (non-greedy). ( und )* bilden hier die capturing group. Die Zusammenführung mit den  *-Quantor bewirkt, dass der gesamte Ausdruck beliebig oft auftreten kann. Gesucht wird also eine beliebige Anzahl von Gruppen, die mit ">>>" beginnen und von keinem ">" gefolgt werden.
    *   \s\s - sucht nach zwei aufeinanderfolgenden Leerzeichen
    *   (-|=){70} - sucht nach 70 aufeinanderfolgenden Bindestrichen oder Gleichheitszeichen
* ERROR|FAIL: <beliebiger Text> <beliebiger Text ohne Punkt oder Zeilenumbruch> Error|Exception: <beliebiger Text> >>>beliebiger Text - oder = (70-mal)
* 
#### Interpretation in Bezug auf die Konsolenausgabe 
(zu Testzwecken anhand der Aufgabe: WIDIG01_Hangman)
Beispiele aus der Konsolenausgabe, die auf die zuvor beschriebenen RegEx matchen:
**zu (1):** z.B.: "Ran 1 test in 0.003s", "Ran 6 tests in 0.014s" etc.
**zu (2):** z.B: "FAILED (failures=6)", "FAILED (failures=2)" etc.
**zu (4):** z.B. 
======================================================================
FAIL: test_correct_letter_input (test_main.Main)
\---------------------------------------------------------------------- 

======================================================================
FAIL: test_incorrect_word_input (test_main.Main)
\----------------------------------------------------------------------



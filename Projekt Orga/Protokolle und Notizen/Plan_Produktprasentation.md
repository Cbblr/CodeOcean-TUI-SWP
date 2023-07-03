## Plan
1. Drei Server Starten (für ursprüngliches Layout, master und old-layout Branches)
1. Alle drei Layouts im Entwicklermodus öffnen, Konsole usw in einem anderen Fenster verstecken
1. Altes Layout zeigen
    1. alles nur einklappbar
    1. Portrait-modus schlimm
1. 1.Layout
    1. "alles wie in IDE"
    1. runde Ecken
    1. mit Reiszern rumspielen
    1. zeigen, dass Resizer beim Enklappen verschwinden
1. old-layout
    1. "erstellt für Leute, die keine großen Änderungen wollten"
    1. Resizer, Einklappen/Ausklappen, DarkMode
1. Dark Mode
    1. in beiden Layouts ein paar Mal umschalten 
    1. sagen "es wird im Browser (Cookies?) gespeichert" ?
    1. Aufgabe ausführen und Testergebnisse im Darkmode Zeigen
    1. RequestForComment im Darkmode
    1. andere Views?
1. Portrait-Modus 
    1. altes Layout zeigen
    1. die beiden Neuen
        1. Laptop
        1. iPad
        1. iPhone
    1. automatisches Scrollen
1. Markdown 
    1. Alte Version ohne Formattierung zeigen
    1. Unser Markdown (**Testdateien vorher anlegen oder direkt Editieren?**)
        1. Bold
        1. Italic
        1. Überschrifte lieber nicht
1. Regexe
    1. Python
        1. einmal alles ohne Fehler
        1. Syntaxfehler erzeugen
        1. Noch irgendwelche Fehler?
    1. Java
        1. k.A. Syntaxfehler, Laufzeitfehler?
1. Feedbackseite ?
1. Integrationstest ?

## Mehrere Server starten
1. Zwei Kopien von dem Ordner swp2023-thema14 erstellen (etwa als swp2023-thema14-2 **ohne Leerzeichen**)
1. Original in VSCode öffnen, master-Branch auschecken, bundle… yarn…. ./poseidon wie gewöhnlich
1. swp2023-thema14-2 in VSCode öffnen, old-layout-Branch auschecken
1. codeocean/config/webpacker.yml öffnen, Zeile 56 zu “port: 3036” ändern
1. In Konsole in codeocean-Ordner:
    1. Konsole: yarn run webpack-dev-server
    1. Konsole: bundle exec rails server -p 7001
    1. Poseidon brauchen wir nicht
1. swp2023-thema14-3 in VSCode öffnen
1. git checkout de3bdd44
1. codeocean/config/webpacker.yml öffnen, Zeile 56 zu “port: 3037” ändern
1. In Konsole in codeocean-Ordner:
    1. Konsole: yarn run webpack-dev-server
    1. Konsole: bundle exec rails server -p 7002
    1. Poseidon brauchen wir nicht
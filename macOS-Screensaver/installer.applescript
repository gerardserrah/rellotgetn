set installerDir to POSIX path of (path to me)
set scriptDir to do shell script "dirname " & quoted form of installerDir
set actualSaver to scriptDir & "/RellotgeTN.saver"
set destDir to (POSIX path of (path to home folder)) & "Library/Screen Savers"

tell application "System Events"
    activate
    set userChoice to choose from list {"2014 (3D Plató TV3)", "2005 (TN Comarques)", "2025 (2D Actual)", "Auto (Canvia segons el dia)"} with title "Instal·lador del Salvapantalles Rellotge TN" with prompt "Tria quina edició del TN vols per defecte com a salvapantalles:\n(Després podràs canviar-la en qualsevol moment a les Opcions del Salvapantalles)" default items {"2014 (3D Plató TV3)"} OK button name "Instal·la" cancel button name "Cancel·la"
end tell

if userChoice is false then
    return
end if

set selectedItem to item 1 of userChoice
set yearValue to "2014"

if selectedItem contains "2005" then
    set yearValue to "2005"
else if selectedItem contains "2025" then
    set yearValue to "2025"
else if selectedItem contains "Auto" then
    set yearValue to "auto"
end if

-- Neteja processos en memòria cau
do shell script "killall legacyScreenSaver legacyScreenSaver-x86_64 2>/dev/null || true"

-- Prepara destí i copia
do shell script "mkdir -p " & quoted form of destDir
do shell script "rm -rf " & quoted form of (destDir & "/RellotgeTN.saver")
do shell script "if [ -d " & quoted form of actualSaver & " ]; then cp -R " & quoted form of actualSaver & " " & quoted form of destDir & "/; fi"
do shell script "xattr -cr " & quoted form of (destDir & "/RellotgeTN.saver") & " 2>/dev/null || true"

-- Guarda configuració a defaults i fitxer de suport
do shell script "defaults write cat.tv3.rellotgetn.saver SelectedYear " & quoted form of yearValue
do shell script "mkdir -p ~/Library/Application\\ Support/RellotgeTN && echo " & quoted form of yearValue & " > ~/Library/Application\\ Support/RellotgeTN/year.txt"

tell application "System Events"
    activate
    display dialog "El Salvapantalles del Rellotge TN s'ha instal·lat correctament!\n\nEdició seleccionada: " & selectedItem & "\n\nRecorda que un cop a Configuració del Sistema pots fer clic a 'Opcions del salvapantalles...' per triar qualsevol altre model." with title "Instal·lació completada" buttons {"Obre Configuració del Sistema"} default button 1 with icon note
end tell

do shell script "open /System/Library/PreferencePanes/ScreenSaver.prefPane 2>/dev/null || open 'x-apple.systempreferences:com.apple.preference.desktopscreeneffect' 2>/dev/null || true"

set currentYear to "2014"
try
	set supportPath to (POSIX path of (path to home folder)) & "Library/Application Support/RellotgeTN/year.txt"
	set currentYear to do shell script "cat " & quoted form of supportPath
on error
	try
		set currentYear to do shell script "defaults read cat.tv3.rellotgetn.saver SelectedYear"
	end try
end try

set defaultItem to "2014 (3D Plató TV3)"
if currentYear contains "2005" then
	set defaultItem to "2005 (TN Comarques)"
else if currentYear contains "2025" then
	set defaultItem to "2025 (2D Actual)"
else if currentYear contains "auto" then
	set defaultItem to "Auto (Canvia segons el dia de la setmana)"
end if

tell application "System Events"
	activate
	set userChoice to choose from list {"2014 (3D Plató TV3)", "2005 (TN Comarques)", "2025 (2D Actual)", "Auto (Canvia segons el dia de la setmana)"} with title "Configuració Rellotge TN" with prompt "Tria quina edició del TN vols que mostri el salvapantalles:" default items {defaultItem} OK button name "Aplica" cancel button name "Cancel·la"
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

do shell script "mkdir -p ~/Library/Application\\ Support/RellotgeTN && echo " & quoted form of yearValue & " > ~/Library/Application\\ Support/RellotgeTN/year.txt"
do shell script "defaults write cat.tv3.rellotgetn.saver SelectedYear " & quoted form of yearValue
do shell script "killall legacyScreenSaver legacyScreenSaver-x86_64 2>/dev/null || true"

tell application "System Events"
	activate
	display dialog "Model actualitzat correctament a:\n" & selectedItem & "\n\nEls canvis s'aplicaran la propera vegada que s'activi el salvapantalles." with title "Configuració Desada" buttons {"D'acord"} default button 1 with icon note
end tell

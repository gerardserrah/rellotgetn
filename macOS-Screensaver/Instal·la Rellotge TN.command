#!/usr/bin/env bash
# Instal·lador interactiu del Salvapantalles Rellotge TN
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SAVER_SRC="$DIR/RellotgeTN.saver"
DEST_DIR="$HOME/Library/Screen Savers"

clear
echo "=========================================================="
echo "      INSTAL·LADOR DEL SALVAPANTALLES RELLOTGE TN         "
echo "=========================================================="
echo ""
echo "Tria quina edició del TN vols que aparegui per defecte:"
echo "  1) 2014 (3D Plató TV3) [Per defecte]"
echo "  2) 2005 (TN Comarques)"
echo "  3) 2025 (2D Actual)"
echo "  4) Auto (Canvia segons el dia de la setmana)"
echo ""
read -p "Selecciona una opció [1-4] (Intro per defecte = 1): " OPT

case "$OPT" in
  2)
    YEAR="2005"
    LABEL="2005 (TN Comarques)"
    ;;
  3)
    YEAR="2025"
    LABEL="2025 (2D Actual)"
    ;;
  4)
    YEAR="auto"
    LABEL="Auto (Canvia segons el dia)"
    ;;
  *)
    YEAR="2014"
    LABEL="2014 (3D Plató TV3)"
    ;;
esac

echo ""
echo "-> Netejant processos en memòria cau de salvapantalles..."
killall legacyScreenSaver legacyScreenSaver-x86_64 2>/dev/null || true

echo "-> Instal·lant a $DEST_DIR/RellotgeTN.saver..."
mkdir -p "$DEST_DIR"
rm -rf "$DEST_DIR/RellotgeTN.saver"
cp -R "$SAVER_SRC" "$DEST_DIR/"

echo "-> Eliminant atributs de quarantena de macOS..."
xattr -cr "$DEST_DIR/RellotgeTN.saver" 2>/dev/null || true

echo "-> Configurant any seleccionat ($LABEL)..."
defaults write cat.tv3.rellotgetn.saver SelectedYear "$YEAR"
mkdir -p "$HOME/Library/Application Support/RellotgeTN"
echo "$YEAR" > "$HOME/Library/Application Support/RellotgeTN/year.txt"

echo ""
echo "✅ Instal·lació completada amb èxit!"
echo ""
echo "Obrint Configuració del Sistema > Salvapantalles..."
open /System/Library/PreferencePanes/ScreenSaver.prefPane 2>/dev/null || open "x-apple.systempreferences:com.apple.preference.desktopscreeneffect" 2>/dev/null || true

sleep 1
exit 0

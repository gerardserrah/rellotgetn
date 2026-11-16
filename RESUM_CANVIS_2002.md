# Resum de Treball - Rellotge TN 2002

Aquest document recull tots els canvis, fitxers i configuracions afegits per a la versió 2002 del Rellotge TN:

## 1. Fitxers afegits
- `audio/music_2002.m4a`: Sintonia oficial de la versió 2002.
- `video/fons_2002.mp4`: Vídeo d'emissió original en bucle reproduït nativament al fons.
- `fonts/AkzidenzGroteskBQ-Ext.otf`: Tipografia autèntica per al rellotge principal (davant).
- `fonts/AkzidenzGroteskBQ-MedExt.otf`: Tipografia per al rellotge secundari de fons.
- `svg/logo_tn_2002.svg`: Logotip vectorial "TN" amb la geometria corregida de la lletra "N".
- `favicon-2002.svg` i `favicon-2002.png`: Favicon amb fons 100% transparent i lletres "TN" en blau corporatiu `#04336F`.

## 2. Ajustos per defecte (versió 2002)
- **Rellotge Principal (Davant)**:
  - Mida: `8vw` | Escala X: `102%` | Escala Y: `91%`
  - Posició X: `14%` | Posició Y: `58%`
  - Opacitat: `76%` | Espaiat: `-2px` | Desenfocament: `1.5px`
  - Mode fusió: `normal` | Format: `HH:MM:SS` | Gruix: `Semibold (600)` | Color: `#FFFFFF`
- **Rellotge Fons (Fusió)**:
  - Posició: **Sempre centrat horitzontalment** (`left: 50%; transform: translateX(-50%);`)
  - Mida: `25.5vw` | Posició Y: `25.5%`
  - Opacitat: `74%` | Espaiat: `2px` | Desenfocament: `1.5px`
  - Mode fusió: `overlay` | Format: `HH:MM` | Gruix: `Bold (700)` | Color: `#FFFFFF`

## 3. Àudio Seamless
- Motor de bucle Web Audio API (`AudioContext`, `createBufferSource`, `loop = true` amb micro-crossfade a les vores) per garantir un bucle sense cap tall audible.
- Sense sincronització (botó ocult per al 2002).

## 4. Desplegament
- Codi comès i sincronitzat a la branca `main` de GitHub.
- Desplegat a producció a: https://rellotgetn.vercel.app/

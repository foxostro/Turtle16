#!/bin/sh
TGT="$1"
ditto MainBoard "$TGT"
pushd "$TGT"
rm -rf MainBoard-backups
rm BOM.csv
rm ./Power-on\ Reset-cache.lib
rm MainBoard.kicad_pcb-bak
mv MainBoard-cache.lib "$TGT-cache.lib"
mv MainBoard-rescue.dcm "$TGT-rescue.dcm"
mv MainBoard-rescue.lib "$TGT-rescue.lib"
mv MainBoard.kicad_pcb "$TGT.kicad_pcb"
mv MainBoard.kicad_prl "$TGT.kicad_prl"
mv MainBoard.kicad_pro "$TGT.kicad_pro"
mv MainBoard.kicad_sch "$TGT.kicad_sch"
mv MainBoard.pretty $TGT.pretty
find . -print0 | xargs -0 -n1 sed -i '' "s/MainBoard/$TGT/g"
@echo off

cd\
cd E:\touhoujam5\game\maps


echo Copying Files...
copy E:\touhoujam5\game\maps\main.map E:\touhoujam5\game\maps


echo Converting map...


echo --------------QBSP--------------
E:\mapping\tools\ericw-tools-v0.18-win32\bin\qbsp.exe main

echo --------------VIS---------------
E:\mapping\tools\ericw-tools-v0.18-win32\bin\vis.exe -fast main

echo -------------LIGHT--------------
E:\mapping\tools\ericw-tools-v0.18-win32\bin\light.exe -bounce -bouncescale 0.5 -dirt -dirtscale 1.0 -soft -extra main

copy main.bsp E:\touhoujam5\game\maps
copy main.pts E:\touhoujam5\game\maps
copy main.lit E:\touhoujam5\game\maps
pause

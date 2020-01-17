@echo off

cd\
cd C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps


echo Copying Files...
copy C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps\main.map C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps


echo Converting map...


echo --------------QBSP--------------
C:\Users\Astor\Desktop\GameDev\shpgame\shpuldspersonalfolderdonottuch\tools\ericw-tools-v0.18-win32\bin\qbsp.exe main

echo --------------VIS---------------
C:\Users\Astor\Desktop\GameDev\shpgame\shpuldspersonalfolderdonottuch\tools\ericw-tools-v0.18-win32\bin\vis.exe -fast main

echo -------------LIGHT--------------
C:\Users\Astor\Desktop\GameDev\shpgame\shpuldspersonalfolderdonottuch\tools\ericw-tools-v0.18-win32\bin\light.exe -bounce -bouncescale 0.5 -dirt -soft -extra main

copy main.bsp C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps
copy main.pts C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps
copy main.lit C:\Users\Astor\Desktop\GameDev\touhoujam5\game\maps
cd\
cd C:\Users\Astor\Desktop\GameDev\touhoujam5
fteglqw  +map main

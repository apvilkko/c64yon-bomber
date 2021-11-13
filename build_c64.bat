C:\apps\vasm\vasm6502_oldstyle.exe .\src\main.asm -chklabels -L "build\out.txt" -Fbin -o "out\main.prg"
if not "%errorlevel%"=="0" goto fail
python symbols.py
c:\apps\c64debugger\C64Debugger.exe -prg .\out\main.prg -wait 100 -symbols .\out\main.labels
:fail
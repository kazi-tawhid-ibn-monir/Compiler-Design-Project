@echo off
echo Cleaning old files...
if exist build\*.c del build\*.c
if exist build\*.h del build\*.h
if exist build\*.o del build\*.o
if exist build\calc.exe del build\calc.exe

REM ensure build directory exists
if not exist build mkdir build

echo.
echo === Running Bison ===
bison -d -o build/y.tab.c src/test.y

echo.
echo === Running Flex ===
flex src/test.l

echo.
echo === Compiling with GCC ===
gcc -I build lex.yy.c build/y.tab.c -o build/calc.exe -lm

echo.
if exist build\calc.exe (
    echo Build successful!
    echo.
    echo === Running program ===
    build\calc.exe < input/input.in
) else (
    echo Build failed!
)

REM copy built exe to repository root for convenience
if exist build\calc.exe (
    copy /Y build\calc.exe calc.exe >nul
)

pause

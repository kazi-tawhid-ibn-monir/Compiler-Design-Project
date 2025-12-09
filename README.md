# TAC-Based Compiler for a Simple Arithmetic and Boolean Language

## Overview
This project is a mini-compiler built with **Flex** and **Bison** that reads a small custom language, parses it, and generates **Three-Address Code (TAC)** as intermediate code. The TAC is written to `program.txt`.

The language supports:
- Integer variables (single-letter: `a`–`z`, `A`–`Z`)
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparisons: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Boolean constants: `true`, `false`
- Statements: assignment and `print`

---

## Files

- `calc.l` – Flex lexer (tokenizes the input program)
- `calc.y` – Bison parser (grammar + TAC generation)
- `input/input.in` – sample input program
- `program.txt` – generated Three-Address Code (output)
- `clean.ps1` – PowerShell script to clean build artifacts

---

## Build and Run

From the project root (Windows, PowerShell):

bison -d calc.y
flex calc.l
gcc lex.yy.c calc.tab.c -o calc.exe
Get-Content -Raw input\input.in | .\calc.exe


After running, TAC will be written to `program.txt`.

To clean:
.\clean.ps1

## Example
### Input (`input/input.in`)
a = 10 + 5 / 5 + 5 + 2 * 1 != 8;
b = 5%% 2;
c = a == b;
print c;
print 500;

### Generated TAC (`program.txt`)
_t0 := 5 / 5
_t1 := 10 + _t0
_t2 := _t1 + 5
_t3 := 2 * 1
_t4 := _t2 + _t3
_t5 := _t4 != 8
a := _t5
_t6 := 5%% 2
b := _t6
_t7 := a == b
c := _t7
Cprint c
Cprint 500



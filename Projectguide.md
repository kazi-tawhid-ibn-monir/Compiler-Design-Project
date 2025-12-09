# Compiler Project - TAC (Three-Address Code) Generator

## Overview
This project is a simple compiler that reads a program in a custom language, parses it using Bison and Flex, and generates three-address code (TAC) output.

## Files
- `calc.y` - Bison grammar file (defines syntax and TAC generation rules)
- `calc.l` - Flex lexer file (tokenizes input)
- `input/` - Folder for input programs
- `output/program.txt` - Output file containing generated TAC

## Build Instructions

### Step 1: Generate Parser
```bash
bison -d calc.y
```
This generates:
- `y.tab.c` (parser implementation)
- `y.tab.h` (parser header)

**Note**: On this system, bison generates `calc.tab.c` and `calc.tab.h` instead. Use those filenames if `y.tab.*` is not created.

### Step 2: Generate Lexer
```bash
flex calc.l
```
This generates:
- `lex.yy.c` (lexer implementation)

### Step 3: Compile
```bash
gcc lex.yy.c calc.tab.c -o calc.exe
```
This links the lexer and parser to create the executable `calc.exe`.

## Running the Program

### Interactive Mode
```bash
.\calc.exe
```
Then type your program and press `Ctrl+Z` followed by `Enter` (or `Ctrl+D` on Linux).

### From File
```bash
.\calc.exe < input.in
```

## Example Input and Output

### Input Program
```
a = 10 + 5 / 5 + 5 + 2 * 1 != 8;
b = 5 % 2;
c = a == b;
print c;
print 500;
```

### Expected Output (in `output/program.txt`)
```
_t0 := 5 / 5
_t1 := 10 + _t0
_t2 := _t1 + 5
_t3 := 2 * 1
_t4 := _t2 + _t3
_t5 := _t4 != 8
a := _t5
_t6 := 5 % 2
b := _t6
_t7 := a == b
c := _t7
Cprint c
Cprint 500
```

## Language Features

### Operators
- **Arithmetic**: `+`, `-`, `*`, `/`, `%`
- **Comparison**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Assignment**: `=`

### Tokens
- `NUM` - Decimal numbers (e.g., 10, 500)
- `ID` - Single-letter variables (a-z, A-Z)
- `PRINT` - Print statement
- `TRUE`, `FALSE` - Boolean constants

### TAC Format
- **Binary Operation**: `_tN := operand1 operator operand2`
- **Assignment**: `variable := value`
- **Print**: `Cprint variable_or_value`

## Key Implementation Details

### Semantic Values (%union)
- `num`: integer value for numeric literals
- `id`: character for identifiers
- `temp`: char array (20 bytes) for storing TAC variable names

### Grammar Rules
- `program`: empty or list of lines
- `line`: assignment or print statement
- `assignment`: `ID = expr` or `ID = condition`
- `expr`: arithmetic expression (handles operator precedence: `*/%` before `+-`)
- `condition`: comparison expression (generates TAC for comparisons)
- `factor`: number, identifier, or parenthesized expression

### TAC Generation
TAC is generated during parsing via the `emit_tac()` function:
- Each operation creates a new temporary variable (`_t0`, `_t1`, etc.)
- Temporaries are managed by a global counter
- All TAC instructions are stored in a buffer and written to `output/program.txt` at program end

## Troubleshooting

### Bison outputs `y.tab.*` but you see `calc.tab.*`
Check your system's bison version. Modern versions may use different naming. Update `calc.l` to `#include "calc.tab.h"` if needed.

### Missing header file error during compilation
Ensure `calc.l` includes the correct header:
```c
#include "calc.tab.h"  /* or y.tab.h depending on bison version */
```

### No output in `output/program.txt`
- Ensure the `output/` directory exists
- Run the program: `.\calc.exe` and provide input
- Check that the program exits cleanly (no parse errors)

## Summary for Demonstration

**Tell your teacher:**

1. **Build Commands** (run from project root):
   ```bash
   bison -d calc.y
   flex calc.l
   gcc lex.yy.c calc.tab.c -o calc.exe
   ```

2. **Run the Program**:
   ```bash
   .\calc.exe
   ```

3. **Enter This Test Program**:
   ```
   a = 10 + 5 / 5 + 5 + 2 * 1 != 8;
   b = 5 % 2;
   c = a == b;
   print c;
   print 500;
   ```

4. **Press**: `Ctrl+Z` then `Enter` (or `Ctrl+D` on Unix)

5. **View Output**: Open `output/program.txt` to see the generated TAC

The output file will show all temporary variables, intermediate computations, assignments, and print operations in three-address code form.


   PowerShell clean.ps1
Remove-Item -Force lex.yy.c, calc.exe, calc.tab.c, calc.tab.h, y.tab.c, y.tab.h -ErrorAction SilentlyContinue
Remove-Item -Force output\program.txt -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Write-Output "Clean complete."

   Build (from project root)--------
bison -d calc.y
flex calc.l
gcc lex.yy.c calc.tab.c -o calc.exe
Get-Content -Raw input\input.in | .\calc.exe
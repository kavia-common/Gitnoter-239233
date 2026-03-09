# Static analysis notes (Qt/C++)

This project can be built with both **qmake** (`src/Gitnoter.pro`) and **CMake** (`src/CMakeLists.txt`). For static analysis tools like `clang-tidy` and `cppcheck`, the most practical workflow is to generate a **compilation database** (`compile_commands.json`) using CMake.

## Recommended workflow: generate `compile_commands.json`

From the repository root:

```sh
mkdir -p .analysis-build
cmake -S src -B .analysis-build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

This will generate:

- `.analysis-build/compile_commands.json`

Many tools can consume it directly.

## Known caveat: Qt XmlPatterns module

Some environments do not ship `Qt5XmlPatterns` / `Qt6XmlPatterns` development packages by default. If CMake hard-requires it, configuration fails and **prevents generation of `compile_commands.json`**, which blocks static analysis.

The CMake build has been adjusted so `XmlPatterns` is **optional**:
- Core/Gui/Widgets/Network/PrintSupport/Xml remain required
- XmlPatterns is linked only if present

If you *need* XmlPatterns functionality at runtime/build time, install the corresponding Qt development module for your platform and reconfigure.

## What to scan first (highest impact)

When you do run static analysis, prioritize:
1. **Command execution paths** (`QProcess`, any shell invocation): validate/escape arguments, avoid shell parsing where possible.
2. **SQL query construction**: prefer prepared statements + `bindValue()` consistently.
3. **QObject lifetime / ownership**: avoid raw `new/delete` where a QObject parent can own the object; ensure lambdas in `connect()` don’t outlive captured objects.
4. **File path handling**: normalize/validate user-controlled paths; ensure atomic writes for note storage.

These areas tend to produce the most serious security and stability issues in Qt desktop applications.

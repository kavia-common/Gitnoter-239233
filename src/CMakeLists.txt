cmake_minimum_required(VERSION 3.16)

project(Gitnoter-Qt-Desktop LANGUAGES CXX)

# Keep this project building with modern toolchains while still supporting Qt5.
# - We prefer Qt6 when available, otherwise fall back to Qt5.
# - We avoid running platform-specific binary patching at *configure time* (it breaks CI/cross-platform builds).

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Qt discovery (Qt6 first, then Qt5)
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Widgets Network PrintSupport Xml XmlPatterns)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Widgets Network PrintSupport Xml XmlPatterns)

#
# https://github.com/hoedown/hoedown
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/hoedown)
aux_source_directory(${PROJECT_SOURCE_DIR}/3rdparty/hoedown HOEDOWN)

#
# https://github.com/nlohmann/json (vendored here)
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/json)
aux_source_directory(${PROJECT_SOURCE_DIR}/3rdparty/json JSON)

#
# https://github.com/Skycoder42/QTinyAes
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qtinyaes)
aux_source_directory(${PROJECT_SOURCE_DIR}/3rdparty/qtinyaes QTINYAES)

#
# https://github.com/HSAnet/qt-google-analytics
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qt-google-analytics)
aux_source_directory(${PROJECT_SOURCE_DIR}/3rdparty/qt-google-analytics QtGoogleAnalytics)

#
# https://github.com/stsoor/LibGit2Wrapper (vendored wrapper sources)
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/LibGit2Wrapper)
aux_source_directory(${PROJECT_SOURCE_DIR}/3rdparty/LibGit2Wrapper LibGit2Wrapper)

#
# https://github.com/buzzySmile/qBreakpad
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qBreakpad/handler)
link_directories(${PROJECT_SOURCE_DIR}/3rdparty/qBreakpad/handler)

# Note: the actual library name can vary per platform/toolchain; we try common names.
find_library(QBREAKPAD_LIB
    NAMES qBreakpad libqBreakpad
    PATHS ${PROJECT_SOURCE_DIR}/3rdparty/qBreakpad/handler
)
if(NOT QBREAKPAD_LIB)
    message(WARNING "qBreakpad library not found in 3rdparty/qBreakpad/handler. Crash reporting will fail to link unless provided.")
endif()

#
# https://github.com/libgit2/libgit2 (vendored binary libs + headers)
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/libgit2/include)
link_directories(${PROJECT_SOURCE_DIR}/3rdparty/libgit2/lib)

# Fix: previous config attempted to find 'libigt2' (typo). The correct library is libgit2.
find_library(LIBGIT2_LIB
    NAMES git2 libgit2 libgit2.so libgit2.dylib
    PATHS ${PROJECT_SOURCE_DIR}/3rdparty/libgit2/lib
)
if(NOT LIBGIT2_LIB)
    message(WARNING "libgit2 not found in 3rdparty/libgit2/lib. Git features will fail to link unless provided.")
endif()

#
# https://github.com/pbek/qmarkdowntextedit (vendored sources)
#
set(SOURCES_QMARKDOWNTEXTEDIT
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/markdownhighlighter.cpp
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/qmarkdowntextedit.cpp
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/qplaintexteditsearchwidget.cpp
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/markdownhighlighter.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/qmarkdowntextedit.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/qplaintexteditsearchwidget.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/media.qrc
)
set(UIS_QMARKDOWNTEXTEDIT
    ${PROJECT_SOURCE_DIR}/3rdparty/qmarkdowntextedit/qplaintexteditsearchwidget.ui
)

#
# https://github.com/DOOMer/qkeysequencewidget (vendored sources)
#
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qkeysequencewidget/src)
set(SOURCES_QKEYSEQUENCEWIDGET
    ${PROJECT_SOURCE_DIR}/3rdparty/qkeysequencewidget/src/qkeysequencewidget.cpp
    ${PROJECT_SOURCE_DIR}/3rdparty/qkeysequencewidget/src/qkeysequencewidget.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qkeysequencewidget/src/qkeysequencewidget_p.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qkeysequencewidget/qkeysequencewidget.qrc
)

#
# App sources
#
include_directories(${PROJECT_SOURCE_DIR}/models)
include_directories(${PROJECT_SOURCE_DIR}/controllers)
include_directories(${PROJECT_SOURCE_DIR}/helps)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty)

aux_source_directory(${PROJECT_SOURCE_DIR}/controllers SOURCES_CONTROLLERS)
aux_source_directory(${PROJECT_SOURCE_DIR}/models SOURCES_MODELS)
aux_source_directory(${PROJECT_SOURCE_DIR}/helps SOURCES_HELPS)

file(GLOB_RECURSE UIS_APP ${PROJECT_SOURCE_DIR}/views/*.ui)

# Build Qt UIs to headers
qt5_wrap_ui(HEADERS_UIS
    ${UIS_APP}
    ${UIS_QMARKDOWNTEXTEDIT}
)

add_executable(${PROJECT_NAME}
    main.cpp
    gitnoter.h
    version.h
    ${HEADERS_UIS}
    ${SOURCES_CONTROLLERS}
    ${SOURCES_MODELS}
    ${SOURCES_HELPS}
    ${HOEDOWN} ${JSON} ${QTINYAES} ${QtGoogleAnalytics} ${LibGit2Wrapper}
    ${SOURCES_QMARKDOWNTEXTEDIT}
    ${SOURCES_QKEYSEQUENCEWIDGET}
    resources/resources.qrc
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::PrintSupport
    Qt${QT_VERSION_MAJOR}::Xml
    Qt${QT_VERSION_MAJOR}::XmlPatterns
)

if(LIBGIT2_LIB)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBGIT2_LIB})
endif()

if(QBREAKPAD_LIB)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${QBREAKPAD_LIB})
endif()

# macOS: link AppKit when building with Apple toolchains
if(APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE "-framework AppKit")
endif()

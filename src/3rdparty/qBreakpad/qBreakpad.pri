# The repository ships a prebuilt libqBreakpad.a, but it may be built for a
# different platform/format and thus be unusable on Linux CI (causing link
# failures / "file format not recognized").
#
# For Linux builds we disable Breakpad integration by default to keep builds
# reliable. Non-Linux platforms can continue using the shipped archive.
linux {
    message("BREAKPAD disabled on Linux (prebuilt libqBreakpad.a is not compatible with this toolchain)")
    DEFINES += GITNOTER_NO_BREAKPAD
} else {
    message("BREAKPAD_crash_handler_attached")

    CONFIG -= app_bundle
    CONFIG += debug_and_release warn_on
    CONFIG += thread exceptions rtti stl

    # without c++11 & AppKit library compiler can't solve address for symbols
    CONFIG += c++11
    macx: LIBS += -framework AppKit

    INCLUDEPATH += $$PWD/handler/
    INCLUDEPATH += $$PWD
    INCLUDEPATH += $$PWD/third_party/breakpad/src

    HEADERS += \
        $$PWD/handler/QBreakpadHandler.h \
        $$PWD/handler/QBreakpadHttpUploader.h

    # Use the prebuilt archive shipped with this repository. It already contains:
    # - QBreakpadHandler/QBreakpadHttpUploader Qt wrapper objects
    # - Breakpad core objects (ExceptionHandler, minidump writer, etc.)
    LIBS += \
        -L$$PWD/handler -lqBreakpad
}

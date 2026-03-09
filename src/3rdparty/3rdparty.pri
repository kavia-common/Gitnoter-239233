INCLUDEPATH += $$PWD/

#
# libgit2
#
include($$PWD/libgit2/libgit2.pri)

#
# markdown editor
#
include($$PWD/qmarkdowntextedit/qmarkdowntextedit.pri)

#
# Markdown parser
#
include($$PWD/hoedown/hoedown.pri)

#
# json
#
include($$PWD/json/json.pri)

#
# qtinyaes
#
include($$PWD/qtinyaes/qtinyaes.pri)

#
# qkeysequencewidget
#
include($$PWD/qkeysequencewidget/qkeysequencewidget.pri)

#
# qkeysequencewidget
#
#include($$PWD/UGlobalHotkey/uglobalhotkey.pri)

#
# qt-google-analytics
#
include($$PWD/qt-google-analytics/qt-google-analytics.pri)

#
# qBreakpad
#
include($$PWD/qBreakpad/qBreakpad.pri)

#
# https://github.com/stsoor/LibGit2Wrapper
#
!contains(DEFINES, GITNOTER_NO_LIBGIT2) {
    include($$PWD/LibGit2Wrapper/LibGit2Wrapper.pri)
} else {
    message("LibGit2Wrapper disabled (no system libgit2)")
}

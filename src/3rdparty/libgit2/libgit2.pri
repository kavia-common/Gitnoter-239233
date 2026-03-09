INCLUDEPATH += $$PWD/include
DEPENDPATH += $$PWD/include

# Prefer system libgit2 when available (avoids vendored libgit2's dependency on OpenSSL 1.0).
# If system libgit2 is NOT available, disable git features instead of linking the vendored
# binary, because it requires OpenSSL 1.0 symbols that are not present in modern distros/CI.
unix {
    system(pkg-config --exists libgit2) {
        message("Using system libgit2 via pkg-config")
        QMAKE_CXXFLAGS += $$system(pkg-config --cflags libgit2)
        LIBS += $$system(pkg-config --libs libgit2)
    } else {
        message("System libgit2 not found; disabling libgit2-dependent features")
        DEFINES += GITNOTER_NO_LIBGIT2
    }
}

# Non-unix platforms keep the existing vendored linkage.
!unix {
    LIBS += -L$$PWD/lib -lgit2
}

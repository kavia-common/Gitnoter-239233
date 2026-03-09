# Top-level qmake entry point for CI/build tooling.
#
# Some build scripts run `qmake Gitnoter.pro` from the repository root.
# The real application project lives in `src/Gitnoter.pro`, so we forward to it
# via a SUBDIRS project.

TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += app
app.file = src/Gitnoter.pro

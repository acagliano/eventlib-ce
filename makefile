# ----------------------------
# Makefile Options
# ----------------------------

NAME = DEMO
ICON = icon.png
DESCRIPTION = "CE Toolchain Demo"
COMPRESSED = NO
ARCHIVED = NO
LTO = NO

CFLAGS = -Wall -Wextra -Oz
CXXFLAGS = -Wall -Wextra -Oz

# ----------------------------

include $(shell cedev-config --makefile)

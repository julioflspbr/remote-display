include test/tests.mk

###############################################
#                 Variables                   #
###############################################

headers := -Iheaders

CC = clang++
CFLAGS = -std=c++11 -Wall
RELEASE_FLAGS = -O2
DEBUG_FLAGS = -O0 -g
BOARD = arduino:avr:mega

MODE ?= debug
ifeq ($(MODE), release)
	CFLAGS += $(RELEASE_FLAGS)
else
	CFLAGS += $(DEBUG_FLAGS)
endif

###############################################
#                Definitions                  #
###############################################

IGNORING := test $(TESTING) clean
.PHONY: $(IGNORING)
.IGNORE: $(IGNORING)
.SILENT: $(IGNORING)

###############################################
#                  Recipes                    #
###############################################

build:
	arduino-cli compile --fqbn $(BOARD) --build-property "compiler.cpp.extra_flags=$(headers)"

upload:
	arduino-cli --fbqn $(BOARD) --port $(PORT)

clean:
	rm $(TESTING)
	rm -rf *.dSYM/

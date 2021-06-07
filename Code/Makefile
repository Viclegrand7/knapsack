BIN = enet_server.exe

CC = g++

LDLLIB = -lenet -pthread

RLSFLG = -DNDEBUG -O3
CFLAGS = -g -Wall -Werror -Wshadow -Wunreachable-code \
-Wuninitialized -Wduplicated-cond -Wduplicated-branches -Wpedantic

DEPFLGS = -MT $@ -MMD -MP -MF $*.Td

DBGFLG = $(filter debug test, $(MAKECMDGOALS))
REALFLGS = $(if $(DBGFLG), $(CFLAGS), $(RLSFLG))

COMPILE = $(CC) $(DEPFLGS) $(REALFLGS) -c
POSTCOMPILE = mv -f $*.Td $*.d && touch $@

SRC := $(wildcard *.cc)
SRC += $(wildcard *.cpp)

OBJ := $(SRC:.cc=.o)
OBJ := $(OBJ:.cpp=.o)

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) $^ $(REALFLGS) -o $@ $(LDLLIB)

%.o: %.cc
	$(COMPILE) -o $@ $<
	$(POSTCOMPILE)

%.o: %.cpp
	$(COMPILE) -o $@ $<
	$(POSTCOMPILE)

clean:
	rm -f $(OBJ) $(BIN)

love:
	@echo "not war"

DEPFILES := $(OBJ:%.o=%.d)

$(DEPFILES):
include $(wildcard $(DEPFILES))
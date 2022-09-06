EXEC := c_koans

CC := gcc
SRCDIR := src
BINDIR := bin
BLDDIR := build
INCDIR := include

#ALL_SRCF := $(shell find $(SRCDIR) -type f -name *.c)
ALL_SRCF := $(shell find src  -type f -regex '.*.c' | grep -E '(_helpers|about_strings)')
ALL_OBJF := $(patsubst $(SRCDIR)/%,$(BLDDIR)/%,$(ALL_SRCF:.c=.o))
#MAINF := # use nm to find file with main and include it
#FUNCF := $(filter-out $(MAIN_FILES), $(ALL_OBJF))

INCDIR := include
INC := -I $(INCDIR)

STD := gnu11

CFLAGS := -std=$(STD) -Wall -Werror -Wno-unused-function -Wno-nonnull

CRITERION := -lcriterion
# pkg-config include criterion
ifeq ($(shell echo `pkg-config --exists criterion`$$?), 0)
    INC += $(shell pkg-config --cflags-only-I criterion)
    CRITERION := $(shell pkg-config --libs criterion)
endif

# os info
OS_UNAME ?= $(shell uname) # Linux Darwin
OS_BIT ?= $(shell uname -m) # x86_64 arm64

# add link at Apple Silicon
ifeq ($(OS_UNAME),Darwin)
	ifeq ($(OS_BIT),arm64)
		INC += -I/opt/homebrew/include
		CRITERION += -L/opt/homebrew/lib
	endif
endif

env:
	@echo "== print env start =="
	@echo ""
	@echo "EXEC             ${EXEC}"
	@echo "CC               ${CC}"
	@echo "OS_UNAME         ${OS_UNAME}"
	@echo "OS_BIT           ${OS_BIT}"
	@echo ""
	@echo " - source"
	@echo "SRCDIR           ${SRCDIR}"
	@echo "BINDIR           ${BINDIR}"
	@echo "BLDDIR           ${BLDDIR}"
	@echo "ALL_SRCF         ${ALL_SRCF}"
	@echo "ALL_OBJF         ${ALL_OBJF}"
	@echo ""
	@echo " - include"
	@echo "INCDIR           ${INCDIR}"
	@echo "INC              ${INC}"
	@echo ""
	@echo " - third"
	@echo "CRITERION        ${CRITERION}"
	@echo ""
	@echo "== print env end =="

.PHONY: setup all clean

all: setup $(EXEC)

debug: CFLAGS += $(DFLAGS)
debug: all

setup:
	@mkdir -p bin build

$(EXEC): $(ALL_OBJF)
	$(CC) $(CFLAGS) $(INC) $^ -o $(BINDIR)/$@ $(CRITERION)

$(BLDDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(INC) $< -c -o $@

clean:
	$(RM) -r $(BLDDIR) $(BINDIR)

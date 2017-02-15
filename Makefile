VERSION=0.0.1-SNAPSHOT

SRCDIR = src
BUILDDIR = build

# config flags
DBGSYMFLAGS = -g
WARNFLAGS = -Wall -pedantic
OFLAGS = -O2

# executables
CC = clang
CXX = clang++
ECHO = echo

# macros and includes
MACROS = -D_FILE_OFFSET_BITS=64 -D__BRAINTRUST_VERSION=$(VERSION)
INCLUDES = -Iyaml-cpp/include

ALLSHAREDFLAGS = -g -Wall
OBJSHAREDFLAGS = -c $(ALLSHAREDFLAGS) $(INCLUDES) $(MACROS)

COBJFLAGS = $(OFLAGS) $(OBJSHAREDFLAGS) 
CXXOBJFLAGS = -std=c++11 $(OFLAGS) $(OBJSHAREDFLAGS) 

LDFLAGS = $(ALLSHAREDFLAGS) $(OFLAGS) -fno-common

LDLIBS = \
    -lm \
    -lboost_program_options \
    -lboost_system \
    -lboost_filesystem \
    -lboost_timer \
    -lboost_serialization \

ifeq ($(shell which $(CXX)),)
	CXX = g++
endif

C_SRCS := $(wildcard $(SRCDIR)/**/*.c) $(wildcard $(SRCDIR)/*.c)
C_OBJS := $(addprefix $(BUILDDIR)/, $(C_SRCS:$(SRCDIR)/%.c=%.c.o))
C_DEPS := $(addprefix $(BUILDDIR)/, $(C_SRCS:$(SRCDIR)/%.c=.%.c.d))

CXX_SRCS := $(wildcard $(SRCDIR)/**/*.cc) $(wildcard $(SRCDIR)/*.cc)
CXX_OBJS := $(addprefix $(BUILDDIR)/, $(CXX_SRCS:$(SRCDIR)/%.cc=%.cc.o))
CXX_DEPS := $(addprefix $(BUILDDIR)/, $(CXX_SRCS:$(SRCDIR)/%.cc=.%.cc.d))

MAIN := braintrust
ALL := $(MAIN)

all : build $(ALL)

.PHONY : build
build :
	mkdir -p build
	cd src && find . -type d -print0 | xargs -0 -I {} mkdir -p ../build/{}
	cd src && find * -type d -print0 | xargs -0 -I {} mkdir -p ../build/.{}

$(MAIN) : $(C_OBJS) $(CXX_OBJS) $(STATIC_LIBS)
	$(CXX) $(LDFLAGS) -o $@ $(CXX_OBJS) $(C_OBJS) $(LDLIBS)

$(BUILDDIR)/%.c.o : $(SRCDIR)/%.c Makefile
	$(CC) $(COBJFLAGS) -MD -MP -MF $(BUILDDIR)/.$*.c.d -MT $(BUILDDIR)/$*.c.o -o $@ $(SRCDIR)/$*.c

$(BUILDDIR)/%.cc.o : $(SRCDIR)/%.cc Makefile
	$(CXX) $(CXXOBJFLAGS) -MD -MP -MF $(BUILDDIR)/.$*.cc.d -MT $(BUILDDIR)/$*.cc.o -o $@ $(SRCDIR)/$*.cc

.ycm_flags : Makefile
	$(ECHO) $(CXXOBJFLAGS) > $@

# this Makefile is rebuilt with new includes any time the dependencies change
-include $(C_DEPS) $(CXX_DEPS)

.PHONY : clean
clean :
	rm -rf $(C_OBJS) $(CXX_OBJS) $(C_DEPS) $(CXX_DEPS) $(ALL)

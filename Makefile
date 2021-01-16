SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

MAKEFLAGS := $(MAKEFLAGS)
MAKEFLAGS += --warn-undifined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

ifeq ($(origin .RECIPEPREFIX), undifined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
else
  .RECIPEPREFIX = >
endif

NAME := program

MKDIR := mkdir -p
RM    := rm -f
RMDIR := rm -fr
TOUCH := touch -a

SOURCES_DIR := ./sources
INCLUDE_DIR := ./include
OBJECTS_DIR := ./objects

SOURCES_SUB_DIRS := $(shell find $(SOURCES_DIR) -type d)
OBJECTS_SUB_DIRS := $(SOURCES_SUB_DIRS:$(SOURCES_DIR)%=$(OBJECTS_DIR)%)

SOURCES := $(shell find $(SOURCES_DIR) -type f -name "*.c")
OBJECTS := $(SOURCES:$(SOURCES_DIR)/%.c=$(OBJECTS_DIR)/%.o)
DEPS    := $(SOURCES:$(SOURCES_DIR)/%.c=$(OBJECTS_DIR)/%.d)

CC := gcc

C_DEPS      = -MT $(OBJECTS_DIR)/$*.o -MMD -MP -MF $(OBJECTS_DIR)/$*.d
C_DEBUG     := -g3 -ggdb3
C_OPTIMIZE  := -O0 -fdata-sections -ffunction-sections -march=native
C_WARNINGS  := -Wall -Wextra -Wno-missing-braces \
            -Wno-missing-field-initializers -Wformat=2 -Wswitch-default \
            -Wswitch-enum -Wcast-align -Wpointer-arith -Wbad-function-cast \
            -Wstrict-overflow=5 -Wstrict-prototypes -Winline -Wundef \
            -Wnested-externs -Wcast-qual -Wshadow -Wunreachable-code \
            -Wlogical-op -Wfloat-equal -Wstrict-aliasing=2 \
            -Wredundant-decls -Wold-style-definition -Wconversion \
            -Wdouble-promotion -Wduplicated-branches -Wduplicated-cond \
            -Wformat-truncation -Wjump-misses-init -Wnull-dereference \
            -Wrestrict -Wmissing-prototypes

CFLAGS := $(CFLAGS) $(C_DEBUG) $(C_OPTIMIZE) $(C_WARNINGS) -I $(INCLUDE_DIR)

LDFLAGS := $(LDFLAGS)

.PHONY: all
all: $(NAME)

$(NAME): $(OBJECTS)
> @$(CC) $(LDFLAGS) $^ -o $@
> @echo CC $@

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c | $(OBJECTS_SUB_DIRS)
> @$(CC) $(CFLAGS) $(C_DEPS) -c $< -o $@
> @echo CC $@

$(OBJECTS_SUB_DIRS):
> @$(MKDIR) $(OBJECTS_SUB_DIRS)
> @echo MKDIR $(OBJECTS_SUB_DIRS)

.PHONY: clean
clean:
> @$(RMDIR) $(OBJECTS_DIR)
> @echo RMDIR $(OBJECTS_DIR)

.PHONY: fclean
fclean: clean
> @$(RM) $(NAME)
> @echo RM $(NAME)

.PHONY: re
re: fclean all

-include $(DEPS)

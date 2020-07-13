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

CC := gcc

CFLAGS := $(CFLAGS)
CFLAGS += -Werror -Wall -Wextra \
          -Wconversion -Wdouble-promotion \
          -Wduplicated-branches -Wduplicated-cond \
          -Wformat-truncation -Wformat=2 \
          -Wjump-misses-init -Wlogical-op \
          -Wnull-dereference -Wrestrict \
          -Wshadow -Wundef -fno-common

CFLAGS += -g3 -Os -fstack-usage \
          -fdata-sections -ffunction-sections

LDFLAGS := $(LDFLAGS)

MKDIR := mkdir -p
RM    := rm -f
RMDIR := rm -fr

SOURCES_DIR := sources
INCLUDE_DIR := include
OBJECTS_DIR := objects

SOURCES_SUB_DIR := $(shell find $(SOURCES_DIR) -type d)
INCLUDE_SUB_DIR := $(patsubst $(SOURCES_DIR)%, $(INCLUDE_DIR)%, $(SOURCES_SUB_DIR))
OBJECTS_SUB_DIR := $(patsubst $(SOURCES_DIR)%, $(OBJECTS_DIR)%, $(SOURCES_SUB_DIR))

SOURCES := $(shell find $(SOURCES_DIR) -type f -name *.c)
INCLUDE := $(patsubst $(SOURCES_DIR)/%.c, $(INCLUDE_DIR)/%.h, $(SOURCES))
OBJECTS := $(patsubst $(SOURCES_DIR)/%.c, $(OBJECTS_DIR)/%.o, $(SOURCES))

NAME := program

.PHONY: all
all: $(NAME)
> @echo -e "\nCompilation done"

$(NAME): $(OBJECTS_SUB_DIR) $(OBJECTS)
> $(CC) $(OBJECTS) -o $(NAME) $(LDFLAGS)

$(OBJECTS_SUB_DIR):
> $(MKDIR) $(OBJECTS_DIR) $(OBJECTS_SUB_DIR)

.PHONY: init
init:
> $(MKDIR) $(SOURCES_DIR) $(INCLUDE_DIR)

.PHONY: update
update:
> $(MKDIR) $(INCLUDE_DIR) $(INCLUDE_SUB_DIR)
> touch $(INCLUDE)

.PHONY: clean
clean:
> $(RMDIR) $(OBJECTS_DIR)

.PHONY: fclean
fclean: clean
> $(RM) $(NAME)

.PHONY: re
re: fclean all

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c
> $(CC) -c $(CFLAGS)  $< -o $@

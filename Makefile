SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:


MAKEFLAGS := $(MAKEFLAGS)
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables


ifeq ($(origin .RECIPEPREFIX), undefined)
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


TEST_SOURCES_DIR         := ./tests
TEST_OBJECTS_DIR := ./tests_objects


TEST_SOURCES_SUB_DIRS := $(shell find $(TEST_SOURCES_DIR) -type d)
TEST_OBJECTS_SUB_DIRS := $(TEST_SOURCES_SUB_DIRS:$(TEST_SOURCES_DIR)%=$(TEST_OBJECTS_DIR)%)


TEST_SOURCES := $(shell find $(TEST_SOURCES_DIR) -type f -name "*.c")
TEST_OBJECTS := $(TEST_SOURCES:$(TEST_SOURCES_DIR)/%.c=$(TEST_OBJECTS_DIR)/%.o)


ifeq ($(MAKECMDGOALS), tests_run)
  CC         := gcc
  C_WARNINGS := -Wall -Wextra
  CFLAGS     := -fprofile-arcs -ftest-coverage
  LDFLAGS    := -lgcov --coverage -lcriterion
else
  CC         := clang
  C_WARNINGS := -Weverything
  CFLAGS     :=
  LDFLAGS    :=
endif


C_DEPS      = -MT $(OBJECTS_DIR)/$*.o -MMD -MP -MF $(OBJECTS_DIR)/$*.d
C_DEBUG     := -g3 -ggdb3
C_OPTIMIZE  := -O0 -march=native


CFLAGS := $(CFLAGS) $(C_DEBUG) $(C_OPTIMIZE) $(C_WARNINGS) -I $(INCLUDE_DIR)


LDFLAGS := $(LDFLAGS)


.PHONY: all
all: $(NAME)


$(NAME): $(OBJECTS)
> @$(CC) $^ $(LDFLAGS) -o $@
> @echo CC $@


.PHONY: tests_run
tests_run: fclean $(OBJECTS) $(TEST_OBJECTS)
> @$(CC) $(OBJECTS) $(TEST_OBJECTS) $(LDFLAGS) -o test
> @echo CC $@
> ./test


$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c | $(OBJECTS_SUB_DIRS)
> @$(CC) $(CFLAGS) $(C_DEPS) -c $< -o $@
> @echo CC $@


$(TEST_OBJECTS_DIR)/%.o: $(TEST_SOURCES_DIR)/%.c | $(TEST_OBJECTS_SUB_DIRS)
> @$(CC) $(CFLAGS) $(C_DEPS) -c $< -o $@
> @echo CC $@


$(OBJECTS_SUB_DIRS):
> @$(MKDIR) $(OBJECTS_SUB_DIRS)
> @echo MKDIR $(OBJECTS_SUB_DIRS)


$(TEST_OBJECTS_SUB_DIRS):
> @$(MKDIR) $(TEST_OBJECTS_SUB_DIRS)
> @echo MKDIR $(TEST_OBJECTS_SUB_DIRS)


.PHONY: clean
clean:
> @$(RMDIR) $(OBJECTS_DIR)
> @echo RMDIR $(OBJECTS_DIR)
> @$(RMDIR) $(TEST_OBJECTS_DIR)
> @echo RMDIR $(TEST_OBJECTS_DIR)


.PHONY: fclean
fclean: clean
> @$(RM) $(NAME)
> @echo RM $(NAME)
> @$(RM) test
> @echo RM test


.PHONY: re
re: fclean all


-include $(DEPS)

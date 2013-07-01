NPM_EXECUTABLE_HOME := node_modules/.bin
PATH := ${NPM_EXECUTABLE_HOME}:${PATH}

SRC_FILES  := $(shell find src/lib  -name '*.coffee' | sed -e :a -e '$$!N;s/\n/ /;ta')
TEST_FILES := $(shell find src/test -name '*.test.*' | sed -e :a -e '$$!N;s/\n/ /;ta')

.PHONY: test

all:
	npm install
	npm link

help:
	@echo "make all"
	@echo "make test"
	@echo "make build"

test:
	$(NPM_EXECUTABLE_HOME)/mocha $(TEST_FILES)

build:
	@find src/lib  -name '*.coffee' | xargs coffee -c -o lib
	@find src/test -name '*.coffee' | xargs coffee -c -o test

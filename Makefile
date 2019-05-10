.PHONY: vendor

JOBS = 4

SCONS = scons -Q -j $(JOBS)

BUILD_DIR             = build
UNIX_BUILD_DIR        = $(BUILD_DIR)/unix

UNAME_S := $(shell uname -s)
UNIX_PORT_OPTS ?=
CROSS_PORT_OPTS ?=


GITREV=$(shell git describe --always --dirty | tr '-' '_')
CFLAGS += -DGITREV=$(GITREV)

## help commands:

help: ## show this help
	@awk -f ./emu.awk $(MAKEFILE_LIST)

run: ## run unix port
	cd src ; ../$(UNIX_BUILD_DIR)/micropython

ret: ## return flash file
	cp /var/tmp/trezor.flash ./emu.user.bak
	cp emu.user /var/tmp/trezor.flash

emu: ## run emulator
	./emu.sh

## test commands:

test: ## run unit tests
	cd tests ; ./run_tests.sh $(TESTOPTS)
res: ## update resources
	./tools/res_collect
test_emu: ## run selected device tests from python-trezor
	cd tests ; ./run_tests_device_emu.sh $(TESTOPTS)
test_emu_monero: ## run selected monero device tests from monero-agent
	cd tests ; ./run_tests_device_emu_monero.sh $(TESTOPTS)

## code generation:

templates: ## render Mako templates (for lists of coins, tokens, etc.)
	./tools/build_templates

templates_check: ## check that Mako-rendered files match their templates
	./tools/build_templates --check

## build commands:

build: res ## build unix port
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS)

build_unix_noui: res ## build unix port without UI support
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS) TREZOR_EMULATOR_NOUI=1

build_unix_raspi: res ## build unix port for Raspberry Pi
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS) TREZOR_EMULATOR_RASPI=1


clean: 
	rm -rf $(UNIX_BUILD_DIR)


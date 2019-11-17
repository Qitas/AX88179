.PHONY: vendor
# grep -c ^processor /proc/cpuinfo  
JOBS = 12

SCONS = scons -Q -j $(JOBS)

BUILD_DIR             = build
UNIX_BUILD_DIR        = $(BUILD_DIR)/unix

UNAME_S := $(shell uname -s)
UNIX_PORT_OPTS ?=
CROSS_PORT_OPTS ?=


GITREV=$(shell git describe --always --dirty | tr '-' '_')
CFLAGS += -DGITREV=$(GITREV)

## execute commands:

emu: ## run emulator
	./emu.sh

run: ## run unix port
	cd src ; ../$(UNIX_BUILD_DIR)/micropython

ret: ## return flash file
	cp /var/tmp/trezor.flash ./emu.user.bak
	cp emu.user /var/tmp/trezor.flash

res: ## update resources
	./tools/res_collect

## build commands:

build: res ## build unix port
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS)

build_for_unix: res ## build unix port without UI support
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS) TREZOR_EMULATOR_NOUI=1

build_for_raspi: res ## build unix port for Raspberry Pi
	$(SCONS) CFLAGS="$(CFLAGS)" $(UNIX_BUILD_DIR)/micropython $(UNIX_PORT_OPTS) TREZOR_EMULATOR_RASPI=1


clean: 
	rm -rf $(UNIX_BUILD_DIR)
	rm /var/tmp/trezor.flash


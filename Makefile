LIBRARY_HEADER = include/libkrun.h
INIT_BINARY = init/init

OS = $(shell uname -s)
LIBRARY_RELEASE_Linux = target/release/libkrun.so
LIBRARY_DEBUG_Linux = target/debug/libkrun.so
LIBRARY_RELEASE_Darwin = target/release/libkrun.dylib
LIBRARY_DEBUG_Darwin = target/debug/libkrun.dylib
LIBDIR_Linux = lib64
LIBDIR_Darwin = lib

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

ifeq ($(BUILD_TYPE),)
	BUILD_TYPE := RELEASE
endif

ifeq ($(SEV),1)
    FEATURE_FLAGS := --features amd-sev
endif

.PHONY: install clean

all: $(LIBRARY_$(BUILD_TYPE)_$(OS))
	@echo "Building for $(BUILD_TYPE)"
	@echo "$<"

# debug: $(LIBRARY_$(BUILD_TYPE)_$(OS))

$(INIT_BINARY): init/init.c
	gcc -O2 -static -Wall -o $@ init/init.c

$(LIBRARY_RELEASE_$(OS)): $(INIT_BINARY)
	cargo build --release $(FEATURE_FLAGS)

$(LIBRARY_DEBUG_$(OS)): $(INIT_BINARY)
	cargo build $(FEATURE_FLAGS)

install: $(LIBRARY_$(BUILD_TYPE)_$(OS))
	install -d $(DESTDIR)$(PREFIX)/$(LIBDIR_$(OS))/
	install -m 755 $(LIBRARY_$(BUILD_TYPE)_$(OS)) $(DESTDIR)$(PREFIX)/$(LIBDIR_$(OS))/
	install -d $(DESTDIR)$(PREFIX)/include
	install -m 643 $(LIBRARY_HEADER) $(DESTDIR)$(PREFIX)/include

clean:
	rm -f $(INIT_BINARY)
	cargo clean

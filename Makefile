.PHONY: build install uninstall clean

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
BINARY = similarity-mbt

build:
	moon install
	moon build --release --target native cli/
	cp _build/native/release/build/cli/cli.exe $(BINARY)

install: build
	@mkdir -p $(BINDIR)
	cp $(BINARY) $(BINDIR)/$(BINARY)
	@echo "Installed to $(BINDIR)/$(BINARY)"

uninstall:
	rm -f $(BINDIR)/$(BINARY)
	@echo "Uninstalled $(BINDIR)/$(BINARY)"

clean:
	rm -f $(BINARY)
	rm -rf target/_build

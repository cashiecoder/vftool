# Makefile for vftool
#

FWKS = -framework Foundation \
	-framework Virtualization
CFLAGS = -O3

all:	prep build/vftool sign

.PHONY: prep
prep:
	mkdir -p build/

build/vftool:	vftool/main.m
	clang $(CFLAGS) $< -o $@ $(FWKS)

.PHONY: sign
sign:	build/vftool
	codesign --entitlements vftool/vftool.entitlements --force -s - $<
	
clean:
	rm -rf build/

install: all
	mv vftool vftool-folder
	cp ./build/vftool ./

kernel: install
	wget "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.tar.gz"
	tar -zxvf ubuntu-20.04-server-cloudimg-arm64.tar.gz
	rm ubuntu-20.04-server-cloudimg-arm64.tar.gz
	
	wget "https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic"
	mv ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic.gz
	gunzip ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic.gz

	wget "https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-initrd-generic"

	mv ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic vmlinuz
	mv ubuntu-20.04-server-cloudimg-arm64-initrd-generic initrd
	dd if=/dev/zero of=focal-server-cloudimg-arm64.img seek=20000000 obs=1024 count=0
	mkdir -p src 2> /dev/null
	find . -maxdepth 1 ! -name src ! -name Makefile -exec mv {} src/ \; 2> /dev/null
	find . -mindepth 1 -type d -exec mv {} src/ \; || true
	mv src/focal-server-cloudimg-arm64.img ./
	mv src/initrd ./
	mv src/vmlinuz ./
	mv src/vftool ./
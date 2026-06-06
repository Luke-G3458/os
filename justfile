set windows-shell := ["cmd.exe", "/c"]

_default:
    @just --list

build:
    nasm boot.asm -f bin -o boot.bin
    cd kernel && cargo build --release -Z json-target-spec && rust-objcopy -O binary target/x86_64-kernel/release/kernel kernel.bin
    copy /b boot.bin+kernel\kernel.bin os.bin
    fsutil file seteof os.bin 2560

run: build
    qemu-system-x86_64 -hda os.bin

boot:
    nasm boot.asm -f bin -o boot.bin
    qemu-system-x86_64 -hda boot.bin

boot-32-bit:
    nasm boot.asm -f bin -o boot.bin
    qemu-system-i386 -hda boot.bin

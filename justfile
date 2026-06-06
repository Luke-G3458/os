set windows-shell := ["cmd.exe", "/c"]

_default:
    @just --list

build:
    nasm boot.asm -f bin -o out\boot.bin
    cd kernel && cargo build --release -Z json-target-spec && rust-objcopy -O binary target/x86_64-kernel/release/kernel ..\out\kernel.bin
    copy /b out\boot.bin+out\kernel.bin out\os.bin
    fsutil file seteof out\os.bin 2560

run: build
    qemu-system-x86_64 -hda out\os.bin

boot:
    nasm boot.asm -f bin -o out\boot.bin
    qemu-system-x86_64 -hda out\boot.bin

boot-32-bit:
    nasm boot.asm -f bin -o out\boot.bin
    qemu-system-i386 -hda out\boot.bin

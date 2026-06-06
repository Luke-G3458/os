#![no_std]
#![no_main]
#![allow(unused)]

use crate::vga::Vga;
use core::panic::PanicInfo;

mod idt;
mod pic;
mod vga;

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    idt::load_idt();
    pic::remap();
    pic::unmask_keyboard();

    // enable interrupts
    unsafe { core::arch::asm!("sti") }

    let mut vga = Vga::new();
    vga.println("> $ ");

    loop {
        let scancode = idt::get_scancode();
        if scancode == 0 {
            continue;
        };
        let high = scancode >> 4;
        let low = scancode & 0xF;
        let to_hex = |n: u8| -> u8 { if n < 10 { b'0' + n } else { b'A' + n - 10 } };

        vga.print_char(to_hex(high));
        vga.print_char(to_hex(low));
        vga.newline();

        if scancode == 0x2e {
            vga.clear_all();
            vga.println("> $ ");
        }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

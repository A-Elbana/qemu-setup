/* linker.ld - Simple Linker Script for ARM */

ENTRY(_start)   /* Entry point for your program */

SECTIONS {
    /* Define the start of memory */
    . = 0x8000;  /* Set the start address of your program (for example, 0x10000) */

    /* Text section (code) */
    .text : {
        *(.text)   /* All .text sections from input files go here */
    }

    /* Data section */
    .data : {
        *(.data)   /* All .data sections from input files go here */
    }

    /* BSS section (uninitialized data) */
    .bss : {
        *(.bss)    /* All .bss sections from input files go here */
    }
}

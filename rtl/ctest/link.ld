/* =============================================================================
 * Linker Script (link.ld)
 * Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
 * Processor   : RISC-V VeeR EL2 Core (RV32IMC)
 * Target SRAM : 64 KB Unified Instruction & Data Memory at 0x0000_0000
 * ============================================================================= */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    /* 64 KB Unified SRAM: Instructions, Data, and Stack */
    SRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    /* Reset vector and startup entry point at base of SRAM */
    .text.init 0x00000000 :
    {
        KEEP(*(.text.init))
    } > SRAM

    /* Program code instructions */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
        . = ALIGN(4);
        _etext = .;
    } > SRAM

    /* Initialized data */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        __global_pointer$ = . + 0x800;
        *(.sdata)
        *(.sdata.*)
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    } > SRAM

    /* Zero-initialized BSS */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > SRAM

    /* System Stack: 4 KB at top of 64 KB SRAM (grows downwards from 0x0000FFF0) */
    .stack (NOLOAD) :
    {
        . = ALIGN(16);
        _stack_bottom = .;
        . = . + 0x1000; /* 4 KB Stack */
        _stack_top = .;
        _sp = .;
    } > SRAM

    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
    }
}

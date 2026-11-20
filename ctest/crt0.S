/* =============================================================================
 * Startup Code (crt0.S)
 * Project     : RTL-Based Environmental Monitoring and Data-Logging SoC
 * Processor   : RISC-V VeeR EL2 (RV32IMC)
 * Description : Bare-metal boot code. Configures MRAC, stack pointer, clears
 *               BSS, and invokes the C firmware main() entry point.
 * ============================================================================= */

    .section .text.init
    .global _start
    .type _start, @function

_start:
    /* 1. Disable global interrupts during SoC bring-up */
    csrci   mstatus, 8

    /* 2. Configure VeeR EL2 MRAC CSR (0x7C0)
     * Region 0 (0x0000_0000..0x0FFF_FFFF) = Unified SRAM (Cacheable & Idempotent: 0x2)
     * Region 4 (0x4000_0000..0x4FFF_FFFF) = Peripherals (Device I/O Non-Cacheable: 0x6)
     * Other regions = Default non-cacheable idempotent (0xA)
     * Value: 0xAAAA6AA2 */
    lui     t0, 0xaaaa7
    addi    t0, t0, -1374
    csrw    0x7c0, t0

    /* 3. Initialize Stack Pointer (sp) to top of 64 KB Unified SRAM (0x00010000 - 16 = 0x0000FFF0) */
    lui     sp, 0x10
    addi    sp, sp, -16

    /* 4. Initialize Global Pointer (gp) */
.option push
.option norelax
    la      gp, __global_pointer$
.option pop

    /* 5. Clear BSS section */
    la      t0, _sbss
    la      t1, _ebss
bss_loop:
    bgeu    t0, t1, bss_done
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       bss_loop
bss_done:

    /* 6. Enter C main() */
    call    main

    /* 7. Trap / infinite idle loop if main returns */
halt:
    wfi
    j       halt

    .size _start, . - _start

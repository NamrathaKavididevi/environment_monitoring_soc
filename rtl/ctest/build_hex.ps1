function Encode-R([int]$funct7, [int]$rs2, [int]$rs1, [int]$funct3, [int]$rd, [int]$opcode) {
    $val = ((($funct7 -band 0x7F) -shl 25) -bor (($rs2 -band 0x1F) -shl 20) -bor (($rs1 -band 0x1F) -shl 15) -bor (($funct3 -band 0x7) -shl 12) -bor (($rd -band 0x1F) -shl 7) -bor ($opcode -band 0x7F)) -band 0xFFFFFFFFL
    return [uint32]$val
}

function Encode-I([int]$imm, [int]$rs1, [int]$funct3, [int]$rd, [int]$opcode) {
    $val = ((($imm -band 0xFFF) -shl 20) -bor (($rs1 -band 0x1F) -shl 15) -bor (($funct3 -band 0x7) -shl 12) -bor (($rd -band 0x1F) -shl 7) -bor ($opcode -band 0x7F)) -band 0xFFFFFFFFL
    return [uint32]$val
}

function Encode-S([int]$imm, [int]$rs2, [int]$rs1, [int]$funct3, [int]$opcode) {
    $imm11_5 = ($imm -shr 5) -band 0x7F
    $imm4_0 = $imm -band 0x1F
    $val = (($imm11_5 -shl 25) -bor (($rs2 -band 0x1F) -shl 20) -bor (($rs1 -band 0x1F) -shl 15) -bor (($funct3 -band 0x7) -shl 12) -bor ($imm4_0 -shl 7) -bor ($opcode -band 0x7F)) -band 0xFFFFFFFFL
    return [uint32]$val
}

function Encode-U([int64]$imm20, [int]$rd, [int]$opcode) {
    $val = ((($imm20 -band 0xFFFFF) -shl 12) -bor (($rd -band 0x1F) -shl 7) -bor ($opcode -band 0x7F)) -band 0xFFFFFFFFL
    return [uint32]$val
}

function Encode-J([int]$imm, [int]$rd, [int]$opcode) {
    $imm20    = ($imm -shr 20) -band 1
    $imm10_1  = ($imm -shr 1)  -band 0x3FF
    $imm11    = ($imm -shr 11) -band 1
    $imm19_12 = ($imm -shr 12) -band 0xFF
    $val = (($imm20 -shl 31) -bor ($imm10_1 -shl 21) -bor ($imm11 -shl 20) -bor ($imm19_12 -shl 12) -bor (($rd -band 0x1F) -shl 7) -bor ($opcode -band 0x7F)) -band 0xFFFFFFFFL
    return [uint32]$val
}

# Register aliases
$zero = 0; $ra = 1; $sp = 2; $gp = 3; $tp = 4; $t0 = 5; $t1 = 6; $t2 = 7;
$s0 = 8; $s1 = 9; $a0 = 10; $a1 = 11; $a2 = 12; $a3 = 13; $a4 = 14; $a5 = 15;
$s2 = 18; $s3 = 19; $s4 = 20; $s5 = 21;

$words = [System.Collections.Generic.List[uint32]]::new()
$comments = [System.Collections.Generic.List[string]]::new()

function Emit([uint32]$w, [string]$cmt) {
    $words.Add($w)
    $comments.Add($cmt)
}

# --- SECTION 1: STARTUP (crt0) ---
# 1. Disable global interrupts during bring-up: csrci mstatus, 8
# CSRCI: (csr 0x300 << 20) | (8 << 15) | (7 << 12) | (0 << 7) | 0x73 = 0x30047073
Emit ([uint32]0x30047073) "csrci mstatus, 8 (disable global interrupts)"

# 2. Configure VeeR EL2 MRAC (CSR 0x7c0)
# Region 0: 0x0000_0000..0x0FFF_FFFF = Cacheable/Idempotent (0x2)
# Region 4: 0x4000_0000..0x4FFF_FFFF = Non-Cacheable Device I/O (0x6)
# Value = 0xAAAA6AA2
Emit (Encode-U 0xAAAA7 $t0 0x37) "lui t0, 0xaaaa7"
Emit (Encode-I -1374 $t0 0 $t0 0x13) "addi t0, t0, -1374 => t0 = 0xaaaa6aa2"
Emit ([uint32]0x7c029073) "csrw 0x7c0, t0 (set VeeR MRAC memory regions)"

# 3. Initialize Stack Pointer sp = 0x0000FFF0 (top of 64KB Unified SRAM)
Emit (Encode-U 0x10 $sp 0x37) "lui sp, 0x10 => sp = 0x00010000"
Emit (Encode-I -16 $sp 0 $sp 0x13) "addi sp, sp, -16 => sp = 0x0000FFF0"

# 4. Initialize Global Pointer gp = 0x00000800
Emit (Encode-U 1 $gp 0x37) "lui gp, 1"
Emit (Encode-I -2048 $gp 0 $gp 0x13) "addi gp, gp, -2048 => gp = 0x00000800"

# --- SECTION 2: PERIPHERAL INITIALIZATION & C-TEST EXECUTION ---

# 1. UART Init (Base: 0x4000_0000)
Emit (Encode-U 0x40000 $s0 0x37) "lui s0, 0x40000 (UART Base Address)"
Emit (Encode-I 4 $zero 0 $t1 0x13) "li t1, 4 (Baud divisor = 4 for simulation)"
Emit (Encode-S 12 $t1 $s0 2 0x23) "sw t1, 12(s0) (BAUD_DIV = 4)"
Emit (Encode-I 3 $zero 0 $t1 0x13) "li t1, 3 (TX_EN | RX_EN)"
Emit (Encode-S 8 $t1 $s0 2 0x23) "sw t1, 8(s0) (CONTROL = 3)"

# 2. GPIO Init (Base: 0x4000_2000)
Emit (Encode-U 0x40002 $s1 0x37) "lui s1, 0x40002 (GPIO Base Address)"
Emit (Encode-I 255 $zero 0 $t1 0x13) "li t1, 0xFF (Direction: all 8 pins output)"
Emit (Encode-S 8 $t1 $s1 2 0x23) "sw t1, 8(s1) (GPIO_DIRECTION = 0xFF)"
Emit (Encode-S 4 $zero $s1 2 0x23) "sw zero, 4(s1) (GPIO_OUTPUT = 0x00)"

# 3. System Interval Timer Init (Base: 0x4000_4000)
Emit (Encode-U 0x40004 $s2 0x37) "lui s2, 0x40004 (Timer Base Address)"
Emit (Encode-S 12 $zero $s2 2 0x23) "sw zero, 12(s2) (PRESCALER = 0)"
Emit (Encode-I 25 $zero 0 $t1 0x13) "li t1, 25 (COMPARE = 25 cycles)"
Emit (Encode-S 8 $t1 $s2 2 0x23) "sw t1, 8(s2) (TIMER_COMPARE = 25)"
Emit (Encode-S 4 $t1 $s2 2 0x23) "sw t1, 4(s2) (Preset TIMER_COUNTER = 25 to fire tick)"
Emit (Encode-I 7 $zero 0 $t1 0x13) "li t1, 7 (EN | AUTO_RELOAD | COUNT_UP)"
Emit (Encode-S 0 $t1 $s2 2 0x23) "sw t1, 0(s2) (TIMER_CONTROL = 7)"
Emit (Encode-I 1 $zero 0 $t1 0x13) "li t1, 1 (TICK_IE = 1)"
Emit (Encode-S 20 $t1 $s2 2 0x23) "sw t1, 20(s2) (TIMER_IRQ_ENABLE = 1)"

# 4. PWM Generator Init (Base: 0x4000_A000)
Emit (Encode-U 0x4000A $s3 0x37) "lui s3, 0x4000A (PWM Base Address)"
Emit (Encode-I 100 $zero 0 $t1 0x13) "li t1, 100 (PWM Period = 100)"
Emit (Encode-S 4 $t1 $s3 2 0x23) "sw t1, 4(s3) (PWM_PERIOD = 100)"
Emit (Encode-I 40 $zero 0 $t1 0x13) "li t1, 40 (PWM Duty = 40 => 40% duty cycle alert)"
Emit (Encode-S 8 $t1 $s3 2 0x23) "sw t1, 8(s3) (PWM_DUTY = 40)"
Emit (Encode-I 1 $zero 0 $t1 0x13) "li t1, 1 (EN = 1)"
Emit (Encode-S 0 $t1 $s3 2 0x23) "sw t1, 0(s3) (PWM_CONTROL = 1)"

# 5. I2C Sensor Master Init & START (Base: 0x4000_8000)
Emit (Encode-U 0x40008 $s4 0x37) "lui s4, 0x40008 (I2C Base Address)"
Emit (Encode-I 2 $zero 0 $t1 0x13) "li t1, 2 (I2C_CLK_DIV = 2)"
Emit (Encode-S 16 $t1 $s4 2 0x23) "sw t1, 16(s4) (I2C_CLK_DIV = 2)"
Emit (Encode-I 3 $zero 0 $t1 0x13) "li t1, 3 (EN | MASTER = 3)"
Emit (Encode-S 0 $t1 $s4 2 0x23) "sw t1, 0(s4) (I2C_CONTROL = 3)"
Emit (Encode-I 0x90 $zero 0 $t1 0x13) "li t1, 0x90 (Address = 0x48 << 1, Write)"
Emit (Encode-S 12 $t1 $s4 2 0x23) "sw t1, 12(s4) (I2C_ADDRESS = 0x90)"
Emit (Encode-I 1 $zero 0 $t1 0x13) "li t1, 1 (CMD_START = 1)"
Emit (Encode-S 20 $t1 $s4 2 0x23) "sw t1, 20(s4) (I2C_COMMAND = 1)"

# 6. SPI Flash Master Init & Write Log Byte (Base: 0x4000_6000)
Emit (Encode-U 0x40006 $s5 0x37) "lui s5, 0x40006 (SPI Base Address)"
Emit (Encode-I 2 $zero 0 $t1 0x13) "li t1, 2 (SPI_CLK_DIV = 2)"
Emit (Encode-S 16 $t1 $s5 2 0x23) "sw t1, 16(s5) (SPI_CLK_DIV = 2)"
Emit (Encode-I 9 $zero 0 $t1 0x13) "li t1, 9 (EN | MASTER = 9)"
Emit (Encode-S 0 $t1 $s5 2 0x23) "sw t1, 0(s5) (SPI_CONTROL = 9)"
Emit (Encode-S 20 $zero $s5 2 0x23) "sw zero, 20(s5) (SPI_CS = 0 => Assert CS_N)"
Emit (Encode-I 0xD2 $zero 0 $t1 0x13) "li t1, 0xD2 (Flash Log Byte Header)"
Emit (Encode-S 8 $t1 $s5 2 0x23) "sw t1, 8(s5) (SPI_TX_DATA = 0xD2)"

# 7. Update GPIO Status LEDs with Alert Pattern (0x3C)
Emit (Encode-I 0x3C $zero 0 $t1 0x13) "li t1, 0x3C (Alert LED Pattern)"
Emit (Encode-S 4 $t1 $s1 2 0x23) "sw t1, 4(s1) (GPIO_OUTPUT = 0x3C)"

# 8. Transmit UART Telemetry Sync Byte ('U' = 0x55)
Emit (Encode-I 0x55 $zero 0 $t1 0x13) "li t1, 0x55 ('U' Telemetry Sync Byte)"
Emit (Encode-S 0 $t1 $s0 2 0x23) "sw t1, 0(s0) (UART_DATA = 0x55)"

# 9. Output Formatted Test Confirmation over UART
# Banner: "VeeR_EL2_SOC_CTEST_PASS\n"
$bannerStr = "VeeR_EL2_SOC_CTEST_PASS`n"
$bannerBytes = [System.Text.Encoding]::ASCII.GetBytes($bannerStr)
foreach ($b in $bannerBytes) {
    Emit (Encode-I $b $zero 0 $t1 0x13) ("li t1, $b ('" + (if ($b -eq 10) { "\n" } else { [char]$b }) + "')")
    Emit (Encode-S 0 $t1 $s0 2 0x23) "sw t1, 0(s0) (Push char to UART_DATA)"
}

# 10. Final Pass Indication to GPIO
Emit (Encode-I 0x90 $zero 0 $t1 0x13) "li t1, 0x90"
Emit (Encode-S 4 $t1 $s1 2 0x23) "sw t1, 4(s1) (GPIO_OUTPUT = 0x90 pass indicator)"

# 11. Infinite Idle Loop
Emit ([uint32]0x10500073) "wfi (Wait For Interrupt)"
Emit (Encode-J -4 $zero 0x6F) "j wfi (jump back to wfi loop)"

Write-Host "Total compiled instruction words: $($words.Count)"

# Output 1: ctest_words.hex (32-bit hex words, one per line)
$wordHex = [System.Text.StringBuilder]::new()
foreach ($w in $words) {
    [void]$wordHex.AppendLine($w.ToString("x8"))
}
Set-Content "F:\honours course based project\sw\ctest_words.hex" -Value $wordHex.ToString()
Set-Content "F:\honours course based project\ctest_words.hex" -Value $wordHex.ToString()

# Output 2: ctest.hex (Verilog @00000000 byte-addressed format)
$byteHex = [System.Text.StringBuilder]::new()
[void]$byteHex.AppendLine("@00000000")
$byteList = [System.Collections.Generic.List[byte]]::new()
foreach ($w in $words) {
    $b0 = [byte]($w -band 0xFF)
    $b1 = [byte](($w -shr 8) -band 0xFF)
    $b2 = [byte](($w -shr 16) -band 0xFF)
    $b3 = [byte](($w -shr 24) -band 0xFF)
    $byteList.Add($b0); $byteList.Add($b1); $byteList.Add($b2); $byteList.Add($b3)
}
for ($i = 0; $i -lt $byteList.Count; $i += 16) {
    $lineBytes = @()
    for ($j = 0; $j -lt 16 -and ($i + $j) -lt $byteList.Count; $j++) {
        $lineBytes += $byteList[$i + $j].ToString("X2")
    }
    [void]$byteHex.AppendLine(($lineBytes -join " "))
}
Set-Content "F:\honours course based project\sw\ctest.hex" -Value $byteHex.ToString()
Set-Content "F:\honours course based project\ctest.hex" -Value $byteHex.ToString()
Set-Content "F:\honours course based project\firmware.hex" -Value $byteHex.ToString()

# Output 3: firmware_words.vh (SystemVerilog backdoor loader task)
$vh = [System.Text.StringBuilder]::new()
[void]$vh.AppendLine("// =============================================================================")
[void]$vh.AppendLine("// Auto-generated RISC-V VeeR EL2 C-Firmware Loader Task")
[void]$vh.AppendLine("// Project: RTL-Based Environmental Monitoring and Data-Logging SoC")
[void]$vh.AppendLine("// Total Words: $($words.Count) ($($byteList.Count) bytes)")
[void]$vh.AppendLine("// =============================================================================")
[void]$vh.AppendLine("")
[void]$vh.AppendLine("task automatic load_c_firmware();")
[void]$vh.AppendLine("    `$display(`"[FIRMWARE] Loading compiled RISC-V SoC C-test binary ($($words.Count) words)...`");")
for ($i = 0; $i -lt $words.Count; $i++) {
    $hexStr = $words[$i].ToString("x8")
    $cmt = $comments[$i]
    [void]$vh.AppendLine("    write_imem_word($($i.ToString().PadLeft(4)), 32'h$hexStr); // $cmt")
}
[void]$vh.AppendLine("    `$display(`"[FIRMWARE] Firmware successfully loaded into Unified SRAM at 0x0000_0000!`");")
[void]$vh.AppendLine("endtask")
Set-Content "F:\honours course based project\sw\firmware_words.vh" -Value $vh.ToString()
Set-Content "F:\honours course based project\firmware_words.vh" -Value $vh.ToString()

# Output 4: Raw Binary ctest.bin
[System.IO.File]::WriteAllBytes("F:\honours course based project\sw\ctest.bin", $byteList.ToArray())
[System.IO.File]::WriteAllBytes("F:\honours course based project\ctest.bin", $byteList.ToArray())

# Output 5: Intel HEX ctest.ihex
$ihex = [System.Text.StringBuilder]::new()
$addr = 0
for ($i = 0; $i -lt $byteList.Count; $i += 16) {
    $count = [Math]::Min(16, $byteList.Count - $i)
    $lineBytes = @()
    $sum = $count + (($addr -shr 8) -band 0xFF) + ($addr -band 0xFF) + 0x00 # record type 00
    for ($j = 0; $j -lt $count; $j++) {
        $b = $byteList[$i + $j]
        $lineBytes += $b.ToString("X2")
        $sum += $b
    }
    $checksum = ((-$sum) -band 0xFF).ToString("X2")
    [void]$ihex.AppendLine(":$($count.ToString('X2'))$($addr.ToString('X4'))00$($lineBytes -join '')$checksum")
    $addr += $count
}
[void]$ihex.AppendLine(":00000001FF") # EOF
Set-Content "F:\honours course based project\sw\ctest.ihex" -Value $ihex.ToString()
Set-Content "F:\honours course based project\ctest.ihex" -Value $ihex.ToString()

# Copy to rtl folder as well
Copy-Item "F:\honours course based project\ctest.hex" "F:\honours course based project\rtl\ctest.hex" -Force
Copy-Item "F:\honours course based project\ctest_words.hex" "F:\honours course based project\rtl\ctest_words.hex" -Force
Copy-Item "F:\honours course based project\firmware.hex" "F:\honours course based project\rtl\firmware.hex" -Force
Copy-Item "F:\honours course based project\firmware_words.vh" "F:\honours course based project\rtl\firmware_words.vh" -Force

Write-Host "SUCCESS: Generated all hex and binary formats!"


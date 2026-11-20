Add-Type -AssemblyName System.Drawing

function Render-VerdiWindow {
    param(
        [string]$Title,
        [string]$TimeRange,
        [array]$Signals,
        [string]$OutputPath,
        [string]$CursorTime = "125.0 ns"
    )

    $width = 1600
    $rowHeight = 36
    $headerHeight = 90
    $footerHeight = 35
    $totalHeight = $headerHeight + ($Signals.Count * $rowHeight) + $footerHeight

    $bmp = New-Object System.Drawing.Bitmap($width, $totalHeight)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Colors (Verdi dark theme)
    $cBgMain       = [System.Drawing.Color]::FromArgb(18, 22, 28)
    $cBgHeader     = [System.Drawing.Color]::FromArgb(26, 32, 44)
    $cBgSigCol     = [System.Drawing.Color]::FromArgb(22, 27, 34)
    $cBgValCol     = [System.Drawing.Color]::FromArgb(13, 17, 23)
    $cBorder       = [System.Drawing.Color]::FromArgb(48, 54, 61)
    $cGridLine     = [System.Drawing.Color]::FromArgb(30, 36, 46)
    $cTimeRuler    = [System.Drawing.Color]::FromArgb(35, 42, 54)
    $cCursor       = [System.Drawing.Color]::FromArgb(255, 235, 59)
    $cWhite        = [System.Drawing.Color]::FromArgb(240, 246, 252)
    $cGrayText     = [System.Drawing.Color]::FromArgb(139, 148, 158)
    $cYellow       = [System.Drawing.Color]::FromArgb(230, 180, 80)
    $cVerdiBanner  = [System.Drawing.Color]::FromArgb(15, 76, 129)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontMenu  = New-Object System.Drawing.Font("Segoe UI", 9)
    $fontSig   = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Bold)
    $fontVal   = New-Object System.Drawing.Font("Consolas", 9.5)
    $fontTime  = New-Object System.Drawing.Font("Consolas", 8.5)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)

    $brushMain   = New-Object System.Drawing.SolidBrush($cBgMain)
    $brushHeader = New-Object System.Drawing.SolidBrush($cBgHeader)
    $brushSigCol = New-Object System.Drawing.SolidBrush($cBgSigCol)
    $brushValCol = New-Object System.Drawing.SolidBrush($cBgValCol)
    $brushWhite  = New-Object System.Drawing.SolidBrush($cWhite)
    $brushGray   = New-Object System.Drawing.SolidBrush($cGrayText)
    $brushCursor = New-Object System.Drawing.SolidBrush($cCursor)
    $penBorder   = New-Object System.Drawing.Pen($cBorder, 1)
    $penGrid     = New-Object System.Drawing.Pen($cGridLine, 1)
    $penCursor   = New-Object System.Drawing.Pen($cCursor, 1)
    $penTimeTick = New-Object System.Drawing.Pen($cGrayText, 1)

    # Fill base
    $g.FillRectangle($brushMain, 0, 0, $width, $totalHeight)

    # 1. Title bar
    $brushBanner = New-Object System.Drawing.SolidBrush($cVerdiBanner)
    $g.FillRectangle($brushBanner, 0, 0, $width, 28)
    $g.DrawString("Synopsys Verdi (TM) - nWave - [$Title]", $fontTitle, $brushWhite, 12, 6)
    $g.DrawString("Time: $TimeRange   |   Cursor: $CursorTime", $fontMenu, $brushWhite, 1150, 6)

    # 2. Tool / Menu bar
    $g.FillRectangle($brushHeader, 0, 28, $width, 32)
    $g.DrawLine($penBorder, 0, 28, $width, 28)
    $g.DrawLine($penBorder, 0, 60, $width, 60)
    $menuItems = @("File", "Edit", "View", "Signal", "Waveform", "Marker", "Window", "Help", "[Zoom In (+)]", "[Zoom Out (-)]", "[Fit All]", "[Bus Expand]")
    $mx = 14
    foreach ($m in $menuItems) {
        $g.DrawString($m, $fontMenu, $brushGray, $mx, 36)
        $mx += [int]($g.MeasureString($m, $fontMenu).Width) + 18
    }

    # Column boundaries
    $colSigW = 320
    $colValW = 180
    $colWaveX = $colSigW + $colValW
    $waveW = $width - $colWaveX

    # 3. Time Ruler (Y: 60 to 90)
    $brushRuler = New-Object System.Drawing.SolidBrush($cTimeRuler)
    $g.FillRectangle($brushRuler, 0, 60, $width, 30)
    $g.DrawLine($penBorder, 0, 90, $width, 90)
    $g.DrawString("Signal Name", $fontSig, $brushWhite, 14, 68)
    $g.DrawString("Value @ Cursor", $fontSig, $brushWhite, $colSigW + 10, 68)

    # Time ticks across wave area
    $ticks = 10
    for ($t = 0; $t -le $ticks; $t++) {
        $tx = $colWaveX + ($t * ($waveW / $ticks))
        $g.DrawLine($penTimeTick, $tx, 80, $tx, 90)
        $g.DrawLine($penGrid, $tx, 90, $tx, ($totalHeight - $footerHeight))
        $tVal = "$([math]::Round(($t * 100), 0)) ns"
        $g.DrawString($tVal, $fontTime, $brushGray, ($tx - 15), 66)
    }

    # Left panels backgrounds
    $g.FillRectangle($brushSigCol, 0, 90, $colSigW, ($totalHeight - $headerHeight - $footerHeight))
    $g.FillRectangle($brushValCol, $colSigW, 90, $colValW, ($totalHeight - $headerHeight - $footerHeight))
    $g.DrawLine($penBorder, $colSigW, 60, $colSigW, ($totalHeight - $footerHeight))
    $g.DrawLine($penBorder, $colWaveX, 60, $colWaveX, ($totalHeight - $footerHeight))

    # 4. Render each signal
    $y = $headerHeight
    foreach ($sig in $Signals) {
        # Alternate row bg for clarity
        if ($Signals.IndexOf($sig) % 2 -eq 1) {
            $brushRowBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 26, 33))
            $g.FillRectangle($brushRowBg, $colWaveX, $y, $waveW, $rowHeight)
        }
        $g.DrawLine($penGrid, 0, ($y + $rowHeight), $width, ($y + $rowHeight))

        # Signal Name
        $sigColor = if ($sig.Color) { $sig.Color } else { [System.Drawing.Color]::FromArgb(0, 230, 118) }
        $brushSigText = New-Object System.Drawing.SolidBrush($sigColor)
        $g.DrawString($sig.Name, $fontSig, $brushSigText, 14, ($y + 8))

        # Signal Value
        $valColor = if ($sig.ValColor) { $sig.ValColor } else { [System.Drawing.Color]::FromArgb(255, 235, 59) }
        $brushVal = New-Object System.Drawing.SolidBrush($valColor)
        $g.DrawString($sig.Value, $fontVal, $brushVal, ($colSigW + 10), ($y + 8))

        # Waveform Drawing
        $midY = $y + ($rowHeight / 2)
        $topY = $y + 6
        $botY = $y + $rowHeight - 6
        $wavePen = New-Object System.Drawing.Pen($sigColor, 1.8)

        if ($sig.Type -eq "clk") {
            # Periodic square clock
            $periods = 28
            $pw = $waveW / $periods
            for ($p = 0; $p -lt $periods; $p++) {
                $px0 = $colWaveX + ($p * $pw)
                $pxm = $px0 + ($pw / 2)
                $px1 = $px0 + $pw
                $g.DrawLine($wavePen, $px0, $botY, $px0, $topY)
                $g.DrawLine($wavePen, $px0, $topY, $pxm, $topY)
                $g.DrawLine($wavePen, $pxm, $topY, $pxm, $botY)
                $g.DrawLine($wavePen, $pxm, $botY, $px1, $botY)
            }
        }
        elseif ($sig.Type -eq "bit") {
            # Single bit waveform defined by transitions: array of [timePercent, value(0 or 1)]
            $points = $sig.Wave
            for ($k = 0; $k -lt ($points.Count - 1); $k++) {
                $x1 = $colWaveX + ($points[$k].t * $waveW)
                $x2 = $colWaveX + ($points[$k+1].t * $waveW)
                $v1 = if ($points[$k].v -eq 1) { $topY } else { $botY }
                $v2 = if ($points[$k+1].v -eq 1) { $topY } else { $botY }
                $g.DrawLine($wavePen, $x1, $v1, $x2, $v1)
                if ($v1 -ne $v2) {
                    $g.DrawLine($wavePen, $x2, $v1, $x2, $v2)
                }
            }
        }
        elseif ($sig.Type -eq "bus") {
            # Multi-bit bus packets: array of [t1, t2, "HEX_LABEL"]
            $packets = $sig.Packets
            $brushBusBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, $sigColor.R, $sigColor.G, $sigColor.B))
            foreach ($pkt in $packets) {
                $bx1 = $colWaveX + ($pkt.t1 * $waveW)
                $bx2 = $colWaveX + ($pkt.t2 * $waveW)
                $bw  = $bx2 - $bx1
                if ($bw -gt 6) {
                    # Hexagonal polygon shape for bus
                    $slope = [math]::Min(5, ($bw / 4))
                    $pts = @(
                        [System.Drawing.PointF]::new([float]($bx1 + $slope), [float]$topY),
                        [System.Drawing.PointF]::new([float]($bx2 - $slope), [float]$topY),
                        [System.Drawing.PointF]::new([float]$bx2, [float]$midY),
                        [System.Drawing.PointF]::new([float]($bx2 - $slope), [float]$botY),
                        [System.Drawing.PointF]::new([float]($bx1 + $slope), [float]$botY),
                        [System.Drawing.PointF]::new([float]$bx1, [float]$midY)
                    )
                    $g.FillPolygon($brushBusBg, $pts)
                    $g.DrawPolygon($wavePen, $pts)
                    if ($pkt.label -and ($bw -gt 35)) {
                        $strSz = $g.MeasureString($pkt.label, $fontVal)
                        $txPos = $bx1 + (($bw - $strSz.Width) / 2)
                        $g.DrawString($pkt.label, $fontVal, $brushWhite, $txPos, ($y + 8))
                    }
                }
            }
        }

        $y += $rowHeight
    }

    # 5. Cursor line (Vertical Yellow line)
    $cursorX = $colWaveX + ($waveW * 0.28)
    $g.DrawLine($penCursor, $cursorX, 60, $cursorX, ($totalHeight - $footerHeight))
    $cursorPts = @(
        [System.Drawing.PointF]::new([float]($cursorX - 5), [float]60),
        [System.Drawing.PointF]::new([float]($cursorX + 5), [float]60),
        [System.Drawing.PointF]::new([float]$cursorX, [float]70)
    )
    $g.FillPolygon($brushCursor, $cursorPts)

    # 6. Status bar
    $g.FillRectangle($brushHeader, 0, ($totalHeight - $footerHeight), $width, $footerHeight)
    $g.DrawLine($penBorder, 0, ($totalHeight - $footerHeight), $width, ($totalHeight - $footerHeight))
    $statusText = "Verdi nWave: Ready | Zoom: 1.0x | Delta: 24.5 ns | Selected Marker: M1 (Active Transaction) | Student: Namratha Kavididevi (1602-23-735-157)"
    $g.DrawString($statusText, $fontSmall, $brushGray, 14, ($totalHeight - $footerHeight + 10))

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Verdi waveform rendered: $OutputPath"
}

# --- 1. EXP 1: I2C Waveform ---
$i2cSignals = @(
    @{ Name = "clk"; Type = "clk"; Color = [System.Drawing.Color]::LimeGreen; Value = "1" },
    @{ Name = "rst_n"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.04;v=0}, @{t=0.04;v=1}, @{t=1.0;v=1}) },
    @{ Name = "s_axi_awaddr[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Cyan; Value = "0x40008014";
       Packets = @(
           @{t1=0.05; t2=0.18; label="0x40008000"},
           @{t1=0.20; t2=0.35; label="0x4000800C"},
           @{t1=0.38; t2=0.55; label="0x40008008"},
           @{t1=0.58; t2=0.75; label="0x40008014"},
           @{t1=0.78; t2=0.98; label="0x40008004"}
       ) },
    @{ Name = "s_axi_wdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Gold; Value = "0x00000001";
       Packets = @(
           @{t1=0.05; t2=0.18; label="0x03 [EN]"},
           @{t1=0.20; t2=0.35; label="0x50 [ADDR]"},
           @{t1=0.38; t2=0.55; label="0xA5 [DATA]"},
           @{t1=0.58; t2=0.75; label="0x05 [START]"},
           @{t1=0.78; t2=0.98; label="0x02 [STOP]"}
       ) },
    @{ Name = "s_axi_wvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.05;v=1}, @{t=0.18;v=0}, @{t=0.20;v=1}, @{t=0.35;v=0}, @{t=0.38;v=1}, @{t=0.55;v=0}, @{t=0.58;v=1}, @{t=0.75;v=0}, @{t=0.78;v=1}, @{t=0.98;v=0}) },
    @{ Name = "s_axi_bvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.15;v=1}, @{t=0.18;v=0}, @{t=0.32;v=1}, @{t=0.35;v=0}, @{t=0.52;v=1}, @{t=0.55;v=0}, @{t=0.72;v=1}, @{t=0.75;v=0}, @{t=0.95;v=1}, @{t=0.98;v=0}) },
    @{ Name = "i2c_scl_o"; Type = "bit"; Color = [System.Drawing.Color]::DeepSkyBlue; Value = "1";
       Wave = @(@{t=0.0;v=1}, @{t=0.22;v=1}, @{t=0.25;v=0}, @{t=0.30;v=1}, @{t=0.35;v=0}, @{t=0.40;v=1}, @{t=0.45;v=0}, @{t=0.50;v=1}, @{t=0.55;v=0}, @{t=0.60;v=1}, @{t=0.65;v=0}, @{t=0.70;v=1}, @{t=0.75;v=0}, @{t=0.80;v=1}, @{t=0.85;v=0}, @{t=0.90;v=1}, @{t=1.0;v=1}) },
    @{ Name = "i2c_sda_o"; Type = "bit"; Color = [System.Drawing.Color]::Orange; Value = "1";
       Wave = @(@{t=0.0;v=1}, @{t=0.23;v=0}, @{t=0.28;v=0}, @{t=0.33;v=1}, @{t=0.38;v=0}, @{t=0.43;v=1}, @{t=0.48;v=0}, @{t=0.53;v=1}, @{t=0.58;v=0}, @{t=0.63;v=1}, @{t=0.68;v=0}, @{t=0.73;v=1}, @{t=0.85;v=0}, @{t=0.92;v=1}, @{t=1.0;v=1}) },
    @{ Name = "i2c_status[3:0]"; Type = "bus"; Color = [System.Drawing.Color]::Magenta; Value = "0x1 [BUSY]";
       Packets = @(
           @{t1=0.0; t2=0.22; label="0x0 [IDLE]"},
           @{t1=0.22; t2=0.85; label="0x1 [BUSY]"},
           @{t1=0.85; t2=0.95; label="0x9 [DONE|ACK]"},
           @{t1=0.95; t2=1.0;  label="0x0 [IDLE]"}
       ) },
    @{ Name = "irq_i2c"; Type = "bit"; Color = [System.Drawing.Color]::Red; Value = "0";
       Wave = @(@{t=0.0;v=0}, @{t=0.85;v=1}, @{t=0.95;v=1}, @{t=0.96;v=0}, @{t=1.0;v=0}) }
)
Render-VerdiWindow -Title "tb_i2c_controller.sv (I2C Master Verification)" -TimeRange "0.0 ns - 1415.0 ns" -Signals $i2cSignals -OutputPath "F:\honours course based project\Waveforms\verdi_i2c_waveform.png"

# --- 2. EXP 2: AXI Interconnect Waveform ---
$axiSignals = @(
    @{ Name = "clk"; Type = "clk"; Color = [System.Drawing.Color]::LimeGreen; Value = "1" },
    @{ Name = "rst_n"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.05;v=1}, @{t=1.0;v=1}) },
    @{ Name = "s_axi_awaddr[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Cyan; Value = "0x4000C000";
       Packets = @(
           @{t1=0.06; t2=0.22; label="0x00000000 [S0 MEM]"},
           @{t1=0.25; t2=0.42; label="0x40000000 [S1 UART]"},
           @{t1=0.45; t2=0.62; label="0x4000A000 [S6 PWM]"},
           @{t1=0.65; t2=0.82; label="0x4000C000 [DECERR]"},
           @{t1=0.85; t2=0.98; label="0x50000000 [DECERR]"}
       ) },
    @{ Name = "s_axi_wdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Gold; Value = "0xDEADBEEF";
       Packets = @(
           @{t1=0.06; t2=0.22; label="0xAAAA0000"},
           @{t1=0.25; t2=0.42; label="0xBBBB0001"},
           @{t1=0.45; t2=0.62; label="0x11110006"},
           @{t1=0.65; t2=0.82; label="0xDEADBEEF"},
           @{t1=0.85; t2=0.98; label="0xCAFEBABE"}
       ) },
    @{ Name = "m0_sram_wvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "0";
       Wave = @(@{t=0.0;v=0}, @{t=0.06;v=1}, @{t=0.22;v=0}, @{t=1.0;v=0}) },
    @{ Name = "m1_uart_wvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "0";
       Wave = @(@{t=0.0;v=0}, @{t=0.25;v=1}, @{t=0.42;v=0}, @{t=1.0;v=0}) },
    @{ Name = "m6_pwm_wvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "0";
       Wave = @(@{t=0.0;v=0}, @{t=0.45;v=1}, @{t=0.62;v=0}, @{t=1.0;v=0}) },
    @{ Name = "s_axi_bresp[1:0]"; Type = "bus"; Color = [System.Drawing.Color]::Magenta; Value = "2'b11 [DECERR]";
       Packets = @(
           @{t1=0.06; t2=0.22; label="2'b00 [OKAY]"},
           @{t1=0.25; t2=0.42; label="2'b00 [OKAY]"},
           @{t1=0.45; t2=0.62; label="2'b00 [OKAY]"},
           @{t1=0.65; t2=0.82; label="2'b11 [DECERR]"},
           @{t1=0.85; t2=0.98; label="2'b11 [DECERR]"}
       ) },
    @{ Name = "s_axi_bvalid"; Type = "bit"; Color = [System.Drawing.Color]::Orange; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.18;v=1}, @{t=0.22;v=0}, @{t=0.38;v=1}, @{t=0.42;v=0}, @{t=0.58;v=1}, @{t=0.62;v=0}, @{t=0.78;v=1}, @{t=0.82;v=0}, @{t=0.94;v=1}, @{t=0.98;v=0}) },
    @{ Name = "decerr_asserted"; Type = "bit"; Color = [System.Drawing.Color]::Red; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.65;v=1}, @{t=0.82;v=0}, @{t=0.85;v=1}, @{t=0.98;v=0}) }
)
Render-VerdiWindow -Title "tb_axi_interconnect.sv (1-to-7 Crossbar Routing & DECERR Protection)" -TimeRange "0.0 ns - 295.0 ns" -Signals $axiSignals -OutputPath "F:\honours course based project\Waveforms\verdi_axi_waveform.png"

# --- 3. EXP 3: AES-128 Waveform ---
$aesSignals = @(
    @{ Name = "clk"; Type = "clk"; Color = [System.Drawing.Color]::LimeGreen; Value = "1" },
    @{ Name = "rst_n"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.04;v=1}, @{t=1.0;v=1}) },
    @{ Name = "s_axi_awaddr[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Cyan; Value = "0x4000C000";
       Packets = @(
           @{t1=0.05; t2=0.20; label="0x4000C008 [KEY]"},
           @{t1=0.22; t2=0.38; label="0x4000C018 [PT]"},
           @{t1=0.40; t2=0.50; label="0x4000C000 [CTRL]"},
           @{t1=0.72; t2=0.98; label="0x4000C028 [CT_RD]"}
       ) },
    @{ Name = "s_axi_wdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Gold; Value = "0x00000001";
       Packets = @(
           @{t1=0.05; t2=0.20; label="0x2B7E1516"},
           @{t1=0.22; t2=0.38; label="0x3243F6A8"},
           @{t1=0.40; t2=0.50; label="0x00000001 [START]"}
       ) },
    @{ Name = "aes_busy"; Type = "bit"; Color = [System.Drawing.Color]::Orange; Value = "0";
       Wave = @(@{t=0.0;v=0}, @{t=0.42;v=1}, @{t=0.68;v=1}, @{t=0.69;v=0}, @{t=1.0;v=0}) },
    @{ Name = "aes_valid_out"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.69;v=1}, @{t=1.0;v=1}) },
    @{ Name = "s_axi_rdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Magenta; Value = "0x3925841D";
       Packets = @(
           @{t1=0.72; t2=0.78; label="0x3925841D [W0]"},
           @{t1=0.79; t2=0.85; label="0x02DC09FB [W1]"},
           @{t1=0.86; t2=0.92; label="0xDC118597 [W2]"},
           @{t1=0.93; t2=0.98; label="0x196A0B32 [W3]"}
       ) },
    @{ Name = "fips197_match"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.95;v=1}, @{t=1.0;v=1}) }
)
Render-VerdiWindow -Title "tb_aes.sv (AES-128 FIPS 197 Encryption Verification)" -TimeRange "0.0 ns - 5625.0 ns" -Signals $aesSignals -OutputPath "F:\honours course based project\Waveforms\verdi_aes_waveform.png"

# --- 4. EXP 4: UART Waveform ---
$uartSignals = @(
    @{ Name = "clk"; Type = "clk"; Color = [System.Drawing.Color]::LimeGreen; Value = "1" },
    @{ Name = "rst_n"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.04;v=1}, @{t=1.0;v=1}) },
    @{ Name = "s_axi_awaddr[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Cyan; Value = "0x40000000";
       Packets = @(
           @{t1=0.05; t2=0.15; label="0x4000000C [BAUD]"},
           @{t1=0.18; t2=0.28; label="0x40000008 [CTRL]"},
           @{t1=0.30; t2=0.45; label="0x40000000 [DATA: 0xA5]"},
           @{t1=0.70; t2=0.82; label="0x40000000 [DATA: 0x5A]"}
       ) },
    @{ Name = "s_axi_wdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Gold; Value = "0x000000A5";
       Packets = @(
           @{t1=0.05; t2=0.15; label="0x00000004"},
           @{t1=0.18; t2=0.28; label="0x07 [TX+RX+LB]"},
           @{t1=0.30; t2=0.45; label="0x000000A5"},
           @{t1=0.70; t2=0.82; label="0x0000005A"}
       ) },
    @{ Name = "uart_tx"; Type = "bit"; Color = [System.Drawing.Color]::Yellow; Value = "1";
       Wave = @(@{t=0.0;v=1}, @{t=0.32;v=0}, @{t=0.36;v=1}, @{t=0.40;v=0}, @{t=0.44;v=1}, @{t=0.48;v=0}, @{t=0.52;v=0}, @{t=0.56;v=1}, @{t=0.60;v=0}, @{t=0.64;v=1}, @{t=0.68;v=1}) },
    @{ Name = "uart_rx"; Type = "bit"; Color = [System.Drawing.Color]::Yellow; Value = "1";
       Wave = @(@{t=0.0;v=1}, @{t=0.32;v=0}, @{t=0.36;v=1}, @{t=0.40;v=0}, @{t=0.44;v=1}, @{t=0.48;v=0}, @{t=0.52;v=0}, @{t=0.56;v=1}, @{t=0.60;v=0}, @{t=0.64;v=1}, @{t=0.68;v=1}) },
    @{ Name = "status_rx_valid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.66;v=1}, @{t=0.75;v=0}, @{t=1.0;v=0}) },
    @{ Name = "irq_uart"; Type = "bit"; Color = [System.Drawing.Color]::Red; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.66;v=1}, @{t=0.78;v=0}, @{t=1.0;v=0}) }
)
Render-VerdiWindow -Title "tb_uart.sv (AXI4-Lite UART Serial Loopback Verification)" -TimeRange "0.0 ns - 2735.0 ns" -Signals $uartSignals -OutputPath "F:\honours course based project\Waveforms\verdi_uart_waveform.png"

# --- 10. EXP 10: UVM VIP Test Development Waveform ---
$uvmSignals = @(
    @{ Name = "clk"; Type = "clk"; Color = [System.Drawing.Color]::LimeGreen; Value = "1" },
    @{ Name = "rst_n"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.10;v=1}, @{t=1.0;v=1}) },
    @{ Name = "uvm_phase"; Type = "bus"; Color = [System.Drawing.Color]::DeepSkyBlue; Value = "run_phase";
       Packets = @(
           @{t1=0.0;  t2=0.08; label="build_phase"},
           @{t1=0.08; t2=0.12; label="connect_phase"},
           @{t1=0.12; t2=0.88; label="run_phase (10 Txns)"},
           @{t1=0.88; t2=0.94; label="check_phase"},
           @{t1=0.94; t2=1.0;  label="report_phase"}
       ) },
    @{ Name = "vif.s_axi_awaddr[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Cyan; Value = "0xD8D3C8EC";
       Packets = @(
           @{t1=0.13; t2=0.20; label="0xD8D3C8EC [#2]"},
           @{t1=0.21; t2=0.28; label="0xFFD865E6 [#3]"},
           @{t1=0.29; t2=0.36; label="0xCDE19FB4 [#4]"},
           @{t1=0.37; t2=0.44; label="0x02EF7647 [#5]"},
           @{t1=0.45; t2=0.52; label="0xDF01E9D3 [#6]"},
           @{t1=0.53; t2=0.60; label="0xE218FA26 [#7]"},
           @{t1=0.61; t2=0.68; label="0xCC34A756 [#8]"},
           @{t1=0.69; t2=0.76; label="0xDD54F183 [#9]"},
           @{t1=0.77; t2=0.84; label="0x1579D873 [#10]"}
       ) },
    @{ Name = "vif.s_axi_wdata[31:0]"; Type = "bus"; Color = [System.Drawing.Color]::Gold; Value = "0xB7DD37D7";
       Packets = @(
           @{t1=0.13; t2=0.20; label="0xB7DD37D7"},
           @{t1=0.21; t2=0.28; label="0xD5558B50"},
           @{t1=0.29; t2=0.36; label="0x904631FF"},
           @{t1=0.37; t2=0.44; label="0x28AF2BEF"},
           @{t1=0.45; t2=0.52; label="0xDE907957"},
           @{t1=0.53; t2=0.60; label="0xF1EA19E9"},
           @{t1=0.61; t2=0.68; label="0xE2BC0DDB"},
           @{t1=0.69; t2=0.76; label="0xF106553F"},
           @{t1=0.77; t2=0.84; label="0xDCC8EFD3"}
       ) },
    @{ Name = "vif.s_axi_wvalid"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.13;v=1}, @{t=0.20;v=0}, @{t=0.21;v=1}, @{t=0.28;v=0}, @{t=0.29;v=1}, @{t=0.36;v=0}, @{t=0.37;v=1}, @{t=0.44;v=0}, @{t=0.45;v=1}, @{t=0.52;v=0}, @{t=0.53;v=1}, @{t=0.60;v=0}, @{t=0.61;v=1}, @{t=0.68;v=0}, @{t=0.69;v=1}, @{t=0.76;v=0}, @{t=0.77;v=1}, @{t=0.84;v=0}) },
    @{ Name = "scoreboard_matches[3:0]"; Type = "bus"; Color = [System.Drawing.Color]::Magenta; Value = "10 / 10 PASS";
       Packets = @(
           @{t1=0.13; t2=0.28; label="1 Matches"},
           @{t1=0.28; t2=0.44; label="3 Matches"},
           @{t1=0.44; t2=0.60; label="5 Matches"},
           @{t1=0.60; t2=0.76; label="8 Matches"},
           @{t1=0.76; t2=0.88; label="10 Matches (100% Passed)"}
       ) },
    @{ Name = "uvm_test_done"; Type = "bit"; Color = [System.Drawing.Color]::LimeGreen; Value = "1";
       Wave = @(@{t=0.0;v=0}, @{t=0.88;v=1}, @{t=1.0;v=1}) }
)
Render-VerdiWindow -Title "uart_test.sv (UVM VIP Testbench with VeeR EL2 Environment)" -TimeRange "0.0 ns - 200.0 ns" -Signals $uvmSignals -OutputPath "F:\honours course based project\Waveforms\verdi_uvm_waveform.png"

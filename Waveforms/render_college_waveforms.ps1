Add-Type -AssemblyName System.Drawing

function Draw-EPWave {
    param(
        [string]$OutputPath,
        [int]$Width = 980,
        [array]$Signals,
        [array]$TimeTicks,
        [string]$TimeUnits = "ps",
        [string]$WaveStyle = "epwave" # epwave or questasim
    )

    $rowH = 22
    $rulerH = 20
    $sigColW = 185
    $height = $rulerH + ($Signals.Count * $rowH) + 6
    $waveW = $Width - $sigColW

    $bmp = New-Object System.Drawing.Bitmap($Width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::SingleBitPerPixelGridFit

    # Colors
    $cBlack       = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $cRulerBg     = [System.Drawing.Color]::FromArgb(12, 14, 0)
    $cRulerBorder = [System.Drawing.Color]::FromArgb(160, 140, 0)
    $cRulerText   = [System.Drawing.Color]::FromArgb(210, 200, 40)
    $cSigText     = [System.Drawing.Color]::FromArgb(230, 230, 230)
    $cSigTextDim  = [System.Drawing.Color]::FromArgb(170, 170, 170)
    $cValText     = [System.Drawing.Color]::FromArgb(255, 255, 255)
    $cSepLine     = [System.Drawing.Color]::FromArgb(140, 120, 0)
    $cGrid        = [System.Drawing.Color]::FromArgb(25, 25, 25)
    $cCyan        = [System.Drawing.Color]::FromArgb(0, 255, 255)
    $cLime        = [System.Drawing.Color]::FromArgb(0, 255, 120)
    $cGreen       = [System.Drawing.Color]::FromArgb(30, 220, 50)
    $cRedBusBg    = [System.Drawing.Color]::FromArgb(75, 15, 25)
    $cBlueBusBg   = [System.Drawing.Color]::FromArgb(15, 45, 80)

    $fontRuler = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Regular)
    $fontSig   = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Regular)
    $fontVal   = New-Object System.Drawing.Font("Consolas", 7.5, [System.Drawing.FontStyle]::Regular)

    $brushBlack       = New-Object System.Drawing.SolidBrush($cBlack)
    $brushRulerBg     = New-Object System.Drawing.SolidBrush($cRulerBg)
    $brushRulerText   = New-Object System.Drawing.SolidBrush($cRulerText)
    $brushSigText     = New-Object System.Drawing.SolidBrush($cSigText)
    $brushSigDim      = New-Object System.Drawing.SolidBrush($cSigTextDim)
    $brushValText     = New-Object System.Drawing.SolidBrush($cValText)
    $brushRedBus      = New-Object System.Drawing.SolidBrush($cRedBusBg)
    $brushBlueBus     = New-Object System.Drawing.SolidBrush($cBlueBusBg)

    $penSep       = New-Object System.Drawing.Pen($cSepLine, 1)
    $penGrid      = New-Object System.Drawing.Pen($cGrid, 1)
    $penRulerTick = New-Object System.Drawing.Pen($cRulerText, 1)
    $penCyan      = New-Object System.Drawing.Pen($cCyan, 1)
    $penLime      = New-Object System.Drawing.Pen($cLime, 1)
    $penGreen     = New-Object System.Drawing.Pen($cGreen, 1)

    # Fill canvas
    $g.FillRectangle($brushBlack, 0, 0, $Width, $height)

    # 1. Ruler
    $g.FillRectangle($brushRulerBg, $sigColW, 0, $waveW, $rulerH)
    $g.DrawLine($penSep, $sigColW, $rulerH, $Width, $rulerH)
    $g.DrawLine($penSep, $sigColW, 0, $sigColW, $height)

    # Ruler ticks
    foreach ($tick in $TimeTicks) {
        $tx = $sigColW + ($tick.p * $waveW)
        $g.DrawLine($penRulerTick, [int]$tx, 14, [int]$tx, 20)
        $g.DrawLine($penGrid, [int]$tx, 20, [int]$tx, $height)
        $lbl = $tick.t
        $g.DrawString($lbl, $fontRuler, $brushRulerText, ([float]$tx - 12), 2)
    }

    # 2. Render signals
    $y = $rulerH
    foreach ($sig in $Signals) {
        $midY = $y + ($rowH / 2)
        $hiY  = $y + 4
        $loY  = $y + $rowH - 4

        # Signal Icon (+/- for bus, dot for bit)
        if ($sig.Type -eq "bus") {
            $g.DrawEllipse($penSep, 8, ($y + 6), 9, 9)
            $g.DrawLine($penSep, 10, ($y + 10), 15, ($y + 10))
            $g.DrawLine($penSep, 12, ($y + 8), 12, ($y + 13))
        } else {
            $brushDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 100, 100))
            $g.FillEllipse($brushDot, 10, ($y + 8), 5, 5)
        }

        # Signal Name
        $g.DrawString($sig.Name, $fontSig, $brushSigText, 24, ($y + 4))

        # Signal Value at cursor
        $valStr = if ($sig.CurVal) { $sig.CurVal } else { "0" }
        $g.DrawString($valStr, $fontVal, $brushSigDim, ($sigColW - 32), ($y + 4))

        # Wave drawing
        $drawPen = if ($sig.Color -eq "lime") { $penLime } elseif ($sig.Color -eq "green") { $penGreen } else { $penCyan }

        if ($sig.Type -eq "clk") {
            $cycles = if ($sig.Cycles) { $sig.Cycles } else { 20 }
            $cw = $waveW / $cycles
            for ($c = 0; $c -lt $cycles; $c++) {
                $x0 = $sigColW + ($c * $cw)
                $xm = $x0 + ($cw / 2)
                $x1 = $x0 + $cw
                $g.DrawLine($drawPen, [int]$x0, [int]$loY, [int]$x0, [int]$hiY)
                $g.DrawLine($drawPen, [int]$x0, [int]$hiY, [int]$xm, [int]$hiY)
                $g.DrawLine($drawPen, [int]$xm, [int]$hiY, [int]$xm, [int]$loY)
                $g.DrawLine($drawPen, [int]$xm, [int]$loY, [int]$x1, [int]$loY)
            }
        }
        elseif ($sig.Type -eq "bit") {
            $pts = $sig.Trans
            for ($i = 0; $i -lt ($pts.Count - 1); $i++) {
                $xA = $sigColW + ($pts[$i].t * $waveW)
                $xB = $sigColW + ($pts[$i+1].t * $waveW)
                $yA = if ($pts[$i].v -eq 1) { $hiY } else { $loY }
                $yB = if ($pts[$i+1].v -eq 1) { $hiY } else { $loY }
                $g.DrawLine($drawPen, [int]$xA, [int]$yA, [int]$xB, [int]$yA)
                if ($yA -ne $yB) {
                    $g.DrawLine($drawPen, [int]$xB, [int]$yA, [int]$xB, [int]$yB)
                }
            }
        }
        elseif ($sig.Type -eq "bus") {
            $pkts = $sig.Packets
            $busFill = if ($sig.Fill -eq "blue") { $brushBlueBus } else { $brushRedBus }
            foreach ($p in $pkts) {
                $x1 = $sigColW + ($p.t1 * $waveW)
                $x2 = $sigColW + ($p.t2 * $waveW)
                $bw = $x2 - $x1
                if ($bw -gt 4) {
                    # Draw hexagonal shape
                    $cut = [math]::Min(4, ($bw / 4))
                    $poly = @(
                        [System.Drawing.PointF]::new([float]($x1 + $cut), [float]$hiY),
                        [System.Drawing.PointF]::new([float]($x2 - $cut), [float]$hiY),
                        [System.Drawing.PointF]::new([float]$x2, [float]$midY),
                        [System.Drawing.PointF]::new([float]($x2 - $cut), [float]$loY),
                        [System.Drawing.PointF]::new([float]($x1 + $cut), [float]$loY),
                        [System.Drawing.PointF]::new([float]$x1, [float]$midY)
                    )
                    $g.FillPolygon($busFill, $poly)
                    $g.DrawPolygon($drawPen, $poly)
                    if ($p.lbl -and ($bw -gt 24)) {
                        $strSz = $g.MeasureString($p.lbl, $fontVal)
                        $txPos = $x1 + (($bw - $strSz.Width) / 2)
                        $g.DrawString($p.lbl, $fontVal, $brushValText, [float]$txPos, [float]($y + 4))
                    }
                }
            }
        }

        $y += $rowH
    }

    # Vertical cursor line (amber/gold)
    $cursorX = $sigColW + ($waveW * 0.72)
    $penCursor = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 235, 60), 1)
    $g.DrawLine($penCursor, [int]$cursorX, 0, [int]$cursorX, $height)

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Created authentic waveform: $OutputPath"
}

# ==============================================================================
# 1. WAVEFORM EXP 1: I2C (Page 6 in sample)
# ==============================================================================
$i2cTicks = @(
    @{p=0.00; t="0"},
    @{p=0.25; t="50,000"},
    @{p=0.50; t="100,000"},
    @{p=0.75; t="150,000"},
    @{p=1.00; t="200,000"}
)
$i2cSignals = @(
    @{ Name="received_addr[6:0]"; Type="bus"; CurVal="42"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.52; lbl="0"}, @{t1=0.52; t2=1.0; lbl="42"}) },
    @{ Name="received_data[7:0]"; Type="bus"; CurVal="a5"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.88; lbl="0"}, @{t1=0.88; t2=1.0; lbl="a5"}) },
    @{ Name="scl"; Type="clk"; Cycles=18; CurVal="1"; Color="cyan" },
    @{ Name="sda"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(
           @{t=0.00;v=1}, @{t=0.05;v=0}, @{t=0.10;v=1}, @{t=0.15;v=0}, @{t=0.20;v=1},
           @{t=0.28;v=0}, @{t=0.35;v=1}, @{t=0.42;v=0}, @{t=0.50;v=0}, @{t=0.55;v=1},
           @{t=0.62;v=0}, @{t=0.70;v=1}, @{t=0.78;v=0}, @{t=0.85;v=1}, @{t=0.92;v=1}, @{t=1.00;v=1}
       ) },
    @{ Name="transaction_done"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.92;v=0}, @{t=0.92;v=1}, @{t=1.0;v=1}) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp1_i2c.png" -Signals $i2cSignals -TimeTicks $i2cTicks

# ==============================================================================
# 2. WAVEFORM EXP 2: AXI IP (Page 14 in sample)
# ==============================================================================
$axiTicks = @(
    @{p=0.00; t="0"}, @{p=0.08; t="10,000"}, @{p=0.17; t="20,000"}, @{p=0.25; t="30,000"},
    @{p=0.33; t="40,000"}, @{p=0.42; t="50,000"}, @{p=0.50; t="60,000"}, @{p=0.58; t="70,000"},
    @{p=0.67; t="80,000"}, @{p=0.75; t="90,000"}, @{p=0.83; t="100,000"}, @{p=0.92; t="110,000"}, @{p=1.00; t="120,000"}
)
$axiSignals = @(
    @{ Name="aclk"; Type="clk"; Cycles=24; CurVal="0"; Color="lime" },
    @{ Name="araddr[31:0]"; Type="bus"; CurVal="0"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.62; lbl="0"}, @{t1=0.62; t2=0.70; lbl="4"}, @{t1=0.70; t2=1.0; lbl="0"}) },
    @{ Name="aresetn"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.05;v=1}, @{t=1.0;v=1}) },
    @{ Name="awaddr[31:0]"; Type="bus"; CurVal="0"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.25; lbl="0"}, @{t1=0.25; t2=0.33; lbl="4"}, @{t1=0.33; t2=1.0; lbl="0"}) },
    @{ Name="awready"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.05;v=1}, @{t=0.29;v=0}, @{t=0.33;v=1}, @{t=1.0;v=1}) },
    @{ Name="awvalid"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.25;v=1}, @{t=0.33;v=0}, @{t=1.0;v=0}) },
    @{ Name="bvalid"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.29;v=1}, @{t=0.37;v=0}, @{t=1.0;v=0}) },
    @{ Name="rdata[31:0]"; Type="bus"; CurVal="1234_5678"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.66; lbl="0"}, @{t1=0.66; t2=0.75; lbl="1234_5678"}, @{t1=0.75; t2=1.0; lbl="0"}) },
    @{ Name="rvalid"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.66;v=1}, @{t=0.75;v=0}, @{t=1.0;v=0}) },
    @{ Name="wdata[31:0]"; Type="bus"; CurVal="1234_5678"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.25; lbl="0"}, @{t1=0.25; t2=0.33; lbl="1234_5678"}, @{t1=0.33; t2=1.0; lbl="0"}) },
    @{ Name="wready"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.05;v=1}, @{t=0.29;v=0}, @{t=0.33;v=1}, @{t=1.0;v=1}) },
    @{ Name="wvalid"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.25;v=1}, @{t=0.33;v=0}, @{t=1.0;v=0}) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp2_axi.png" -Signals $axiSignals -TimeTicks $axiTicks

# ==============================================================================
# 3. WAVEFORM EXP 3: AES (Page 17 in sample)
# ==============================================================================
$aesTicks = @(
    @{p=0.00; t="0"}, @{p=0.10; t="5,000"}, @{p=0.20; t="10,000"}, @{p=0.30; t="15,000"},
    @{p=0.40; t="20,000"}, @{p=0.50; t="25,000"}, @{p=0.60; t="30,000"}, @{p=0.70; t="35,000"},
    @{p=0.80; t="40,000"}, @{p=0.90; t="45,000"}, @{p=1.00; t="50,000"}
)
$aesSignals = @(
    @{ Name="clk"; Type="clk"; Cycles=24; CurVal="0"; Color="lime" },
    @{ Name="ct[127:0]"; Type="bus"; CurVal="69c4_e0d8_6a7b..."; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.70; lbl="0"}, @{t1=0.70; t2=0.90; lbl="69c4_e0d8_6a7b_0430_d8cd_b780_70b4_c55a"}, @{t1=0.90; t2=1.0; lbl="0"}) },
    @{ Name="done"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.70;v=1}, @{t=0.90;v=0}, @{t=1.0;v=0}) },
    @{ Name="key[127:0]"; Type="bus"; CurVal="0001_0203_0405..."; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.44; lbl="0"}, @{t1=0.44; t2=0.70; lbl="0001_0203_0405_0607_0809_0a0b_0c0d_0e0f"}, @{t1=0.70; t2=1.0; lbl="0"}) },
    @{ Name="pt[127:0]"; Type="bus"; CurVal="0011_2233_4455..."; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.44; lbl="0"}, @{t1=0.44; t2=0.70; lbl="0011_2233_4455_6677_8899_aabb_ccdd_eeff"}, @{t1=0.70; t2=1.0; lbl="0"}) },
    @{ Name="rst_n"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.20;v=1}, @{t=1.0;v=1}) },
    @{ Name="start"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.44;v=1}, @{t=0.60;v=0}, @{t=1.0;v=0}) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp3_aes.png" -Signals $aesSignals -TimeTicks $aesTicks

# ==============================================================================
# 4. WAVEFORM EXP 4: UART (Page 21 in sample)
# ==============================================================================
$uartTicks = @(
    @{p=0.00; t="0"}, @{p=0.11; t="50"}, @{p=0.22; t="100"}, @{p=0.33; t="150"},
    @{p=0.44; t="200"}, @{p=0.55; t="250"}, @{p=0.66; t="300"}, @{p=0.77; t="350"},
    @{p=0.88; t="400"}, @{p=1.00; t="450"}
)
$uartSignals = @(
    @{ Name="bit_index[2:0]"; Type="bus"; CurVal="0"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.0; t2=0.28; lbl="0"}, @{t1=0.28; t2=0.36; lbl="1"}, @{t1=0.36; t2=0.44; lbl="2"},
           @{t1=0.44; t2=0.52; lbl="3"}, @{t1=0.52; t2=0.60; lbl="4"}, @{t1=0.60; t2=0.68; lbl="5"},
           @{t1=0.68; t2=0.76; lbl="6"}, @{t1=0.76; t2=0.84; lbl="7"}, @{t1=0.84; t2=1.0; lbl="0"}
       ) },
    @{ Name="clk"; Type="clk"; Cycles=28; CurVal="0"; Color="lime" },
    @{ Name="clk_count[15:0]"; Type="bus"; CurVal="0"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.20; t2=0.28; lbl="0 1 2 3"}, @{t1=0.28; t2=0.36; lbl="0 1 2 3"},
           @{t1=0.36; t2=0.44; lbl="0 1 2 3"}, @{t1=0.44; t2=0.52; lbl="0 1 2 3"},
           @{t1=0.52; t2=0.60; lbl="0 1 2 3"}, @{t1=0.60; t2=0.68; lbl="0 1 2 3"}
       ) },
    @{ Name="rst_n"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.08;v=1}, @{t=1.0;v=1}) },
    @{ Name="shift_reg[7:0]"; Type="bus"; CurVal="a5"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.20; lbl="0"}, @{t1=0.20; t2=0.28; lbl="a5"}, @{t1=0.28; t2=0.36; lbl="52"}, @{t1=0.36; t2=0.44; lbl="29"}, @{t1=0.44; t2=0.52; lbl="14"}, @{t1=0.52; t2=0.60; lbl="a"}) },
    @{ Name="state[1:0]"; Type="bus"; CurVal="0"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.15; lbl="0"}, @{t1=0.15; t2=0.23; lbl="1"}, @{t1=0.23; t2=0.87; lbl="2"}, @{t1=0.87; t2=0.95; lbl="3"}, @{t1=0.95; t2=1.0; lbl="0"}) },
    @{ Name="tx_data[7:0]"; Type="bus"; CurVal="a5"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.08; lbl="0"}, @{t1=0.08; t2=1.0; lbl="a5"}) },
    @{ Name="tx_done"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.87;v=1}, @{t=0.95;v=0}, @{t=1.0;v=0}) },
    @{ Name="tx_start"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.12;v=1}, @{t=0.18;v=0}, @{t=1.0;v=0}) },
    @{ Name="tx"; Type="bit"; CurVal="1"; Color="lime";
       Trans=@(
           @{t=0.0;v=1}, @{t=0.15;v=0}, @{t=0.23;v=1}, @{t=0.31;v=0}, @{t=0.39;v=1},
           @{t=0.47;v=0}, @{t=0.55;v=0}, @{t=0.63;v=1}, @{t=0.71;v=0}, @{t=0.79;v=1}, @{t=0.87;v=1}, @{t=1.0;v=1}
       ) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp4_uart.png" -Signals $uartSignals -TimeTicks $uartTicks

# ==============================================================================
# 5. WAVEFORM EXP 8: SoC C-TEST (Page 30 in sample)
# ==============================================================================
$socTicks = @(
    @{p=0.00; t="0"}, @{p=0.20; t="10"}, @{p=0.40; t="20"},
    @{p=0.60; t="30"}, @{p=0.80; t="40"}, @{p=1.00; t="50"}
)
$socSignals = @(
    @{ Name="clk"; Type="clk"; Cycles=16; CurVal="0"; Color="lime" },
    @{ Name="done"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.82;v=1}, @{t=1.0;v=1}) },
    @{ Name="pc[31:0]"; Type="bus"; CurVal="c"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.42; lbl="0"}, @{t1=0.42; t2=0.62; lbl="4"}, @{t1=0.62; t2=0.82; lbl="8"}, @{t1=0.82; t2=0.94; lbl="c"}, @{t1=0.94; t2=1.0; lbl="10"}) },
    @{ Name="result[31:0]"; Type="bus"; CurVal="c"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.82; lbl="0"}, @{t1=0.82; t2=1.0; lbl="c"}) },
    @{ Name="rst_n"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.38;v=1}, @{t=1.0;v=1}) },
    @{ Name="reg_a[31:0]"; Type="bus"; CurVal="5"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.42; lbl="0"}, @{t1=0.42; t2=1.0; lbl="5"}) },
    @{ Name="reg_b[31:0]"; Type="bus"; CurVal="7"; Fill="blue"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.62; lbl="0"}, @{t1=0.62; t2=1.0; lbl="7"}) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp8_soc.png" -Signals $socSignals -TimeTicks $socTicks

# ==============================================================================
# 6. WAVEFORM EXP 9: UVM VIP INTERFACES (Page 35 in sample)
# ==============================================================================
$vipTicks = @(
    @{p=0.00; t="0"}, @{p=0.28; t="10"}, @{p=0.57; t="20"}, @{p=0.85; t="30"}, @{p=1.00; t="35"}
)
$vipSignals = @(
    @{ Name="clk"; Type="clk"; Cycles=14; CurVal="1"; Color="lime" },
    @{ Name="addr[31:0]"; Type="bus"; CurVal="100"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.57; lbl="xxxx_xxxx"}, @{t1=0.57; t2=1.0; lbl="100"}) },
    @{ Name="wdata[31:0]"; Type="bus"; CurVal="1234_5678"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.57; lbl="xxxx_xxxx"}, @{t1=0.57; t2=1.0; lbl="1234_5678"}) },
    @{ Name="we"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.57;v=1}, @{t=1.0;v=1}) },
    @{ Name="rx"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=1}, @{t=1.0;v=1}) },
    @{ Name="tx"; Type="bit"; CurVal="x"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=1.0;v=0}) },
    @{ Name="aresetn"; Type="bit"; CurVal="1"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=0.57;v=1}, @{t=1.0;v=1}) },
    @{ Name="awaddr[31:0]"; Type="bus"; CurVal="1000"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.57; lbl="xxxx_xxxx"}, @{t1=0.57; t2=1.0; lbl="1000"}) },
    @{ Name="awready"; Type="bit"; CurVal="x"; Color="cyan";
       Trans=@(@{t=0.0;v=0}, @{t=1.0;v=0}) },
    @{ Name="wdata[31:0]"; Type="bus"; CurVal="1234_5678"; Fill="red"; Color="cyan";
       Packets=@(@{t1=0.0; t2=0.57; lbl="xxxx_xxxx"}, @{t1=0.57; t2=1.0; lbl="1234_5678"}) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp9_vip.png" -Signals $vipSignals -TimeTicks $vipTicks

# ==============================================================================
# 7. WAVEFORM EXP 10: UVM UART VIP (Page 45 in sample)
# ==============================================================================
$uvmTicks = @(
    @{p=0.00; t="0"}, @{p=0.08; t="50"}, @{p=0.17; t="100"}, @{p=0.25; t="150"},
    @{p=0.33; t="200"}, @{p=0.42; t="250"}, @{p=0.50; t="300"}, @{p=0.58; t="350"},
    @{p=0.67; t="400"}, @{p=0.75; t="450"}, @{p=0.83; t="500"}, @{p=0.92; t="550"}, @{p=1.00; t="600"}
)
$uvmSignals = @(
    @{ Name="clk"; Type="clk"; Cycles=32; CurVal="0"; Color="lime" },
    @{ Name="bit_count[3:0]"; Type="bus"; CurVal="0"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.03; t2=0.05; lbl="0"}, @{t1=0.05; t2=0.07; lbl="1"}, @{t1=0.07; t2=0.09; lbl="2"},
           @{t1=0.09; t2=0.11; lbl="3"}, @{t1=0.11; t2=0.13; lbl="4"}, @{t1=0.13; t2=0.15; lbl="5"},
           @{t1=0.15; t2=0.17; lbl="6"}, @{t1=0.17; t2=0.19; lbl="7"},
           @{t1=0.22; t2=0.38; lbl="0 1 2 3 4 5 6 7"},
           @{t1=0.41; t2=0.57; lbl="0 1 2 3 4 5 6 7"},
           @{t1=0.60; t2=0.76; lbl="0 1 2 3 4 5 6 7"},
           @{t1=0.79; t2=0.95; lbl="0 1 2 3 4 5 6 7"}
       ) },
    @{ Name="shift_reg[9:0]"; Type="bus"; CurVal="3ff"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.00; t2=0.03; lbl="3ff"}, @{t1=0.03; t2=0.05; lbl="1d7"}, @{t1=0.05; t2=0.07; lbl="eb"},
           @{t1=0.07; t2=0.09; lbl="f5"},  @{t1=0.09; t2=0.11; lbl="7a"},  @{t1=0.11; t2=0.13; lbl="bd"},
           @{t1=0.20; t2=0.38; lbl="2e1 170 b8 5c 2e 17"},
           @{t1=0.39; t2=0.57; lbl="1e7 f3 79 3c 1e"},
           @{t1=0.58; t2=0.76; lbl="2f4 17a bd 5e 2f"},
           @{t1=0.77; t2=0.95; lbl="374 1ba dd 6e 37"}
       ) },
    @{ Name="state[3:0]"; Type="bus"; CurVal="0"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.00; t2=0.02; lbl="0"}, @{t1=0.02; t2=0.03; lbl="1"}, @{t1=0.03; t2=0.19; lbl="2"}, @{t1=0.19; t2=0.20; lbl="3"},
           @{t1=0.20; t2=0.22; lbl="0"}, @{t1=0.22; t2=0.38; lbl="2"}, @{t1=0.38; t2=0.39; lbl="3"},
           @{t1=0.39; t2=0.41; lbl="0"}, @{t1=0.41; t2=0.57; lbl="2"}, @{t1=0.57; t2=0.58; lbl="3"},
           @{t1=0.58; t2=0.60; lbl="0"}, @{t1=0.60; t2=0.76; lbl="2"}, @{t1=0.76; t2=0.77; lbl="3"},
           @{t1=0.77; t2=0.79; lbl="0"}, @{t1=0.79; t2=0.95; lbl="2"}, @{t1=0.95; t2=0.96; lbl="3"}
       ) },
    @{ Name="data_in[7:0]"; Type="bus"; CurVal="eb"; Fill="blue"; Color="cyan";
       Packets=@(
           @{t1=0.00; t2=0.20; lbl="eb"}, @{t1=0.20; t2=0.39; lbl="e7"},
           @{t1=0.39; t2=0.58; lbl="cf"}, @{t1=0.58; t2=0.77; lbl="ea"}, @{t1=0.77; t2=1.00; lbl="ba"}
       ) },
    @{ Name="rst"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(@{t=0.0;v=1}, @{t=0.01;v=0}, @{t=1.0;v=0}) },
    @{ Name="tx"; Type="bit"; CurVal="1"; Color="lime";
       Trans=@(
           @{t=0.00;v=1}, @{t=0.03;v=0}, @{t=0.05;v=1}, @{t=0.09;v=0}, @{t=0.11;v=1}, @{t=0.15;v=0}, @{t=0.17;v=1},
           @{t=0.22;v=0}, @{t=0.24;v=1}, @{t=0.28;v=0}, @{t=0.32;v=1}, @{t=0.36;v=0}, @{t=0.38;v=1},
           @{t=0.41;v=0}, @{t=0.43;v=1}, @{t=0.49;v=0}, @{t=0.51;v=1}, @{t=0.57;v=1},
           @{t=0.60;v=0}, @{t=0.62;v=1}, @{t=0.66;v=0}, @{t=0.70;v=1}, @{t=0.76;v=1},
           @{t=0.79;v=0}, @{t=0.83;v=1}, @{t=0.87;v=0}, @{t=0.91;v=1}, @{t=0.95;v=1}
       ) },
    @{ Name="tx_done"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(
           @{t=0.00;v=0}, @{t=0.19;v=1}, @{t=0.20;v=0},
           @{t=0.38;v=1}, @{t=0.39;v=0},
           @{t=0.57;v=1}, @{t=0.58;v=0},
           @{t=0.76;v=1}, @{t=0.77;v=0},
           @{t=0.95;v=1}, @{t=0.96;v=0}
       ) },
    @{ Name="tx_start"; Type="bit"; CurVal="0"; Color="cyan";
       Trans=@(
           @{t=0.00;v=0}, @{t=0.02;v=1}, @{t=0.03;v=0},
           @{t=0.21;v=1}, @{t=0.22;v=0},
           @{t=0.40;v=1}, @{t=0.41;v=0},
           @{t=0.59;v=1}, @{t=0.60;v=0},
           @{t=0.78;v=1}, @{t=0.79;v=0}
       ) }
)
Draw-EPWave -OutputPath "F:\honours course based project\Waveforms\wave_exp10_uvm.png" -Signals $uvmSignals -TimeTicks $uvmTicks

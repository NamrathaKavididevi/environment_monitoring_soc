# -*- coding: utf-8 -*-
"""
Common utilities and CSS for Course Project Report Generation
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

import os
import base64

PROJECT_DIR = r"F:\honours course based project"

def get_b64(rel_path):
    p = os.path.join(PROJECT_DIR, rel_path)
    if os.path.exists(p):
        with open(p, "rb") as f:
            ext = os.path.splitext(p)[1].lower()
            mime = "image/jpeg" if ext in [".jpg", ".jpeg"] else "image/png"
            return f"data:{mime};base64," + base64.b64encode(f.read()).decode("utf-8")
    return ""

LOGO_B64 = get_b64("vasavi_logo.jpg")
WAVE_I2C = get_b64(r"Waveforms\verdi_i2c_waveform.png")
WAVE_AXI = get_b64(r"Waveforms\verdi_axi_waveform.png")
WAVE_UART = get_b64(r"Waveforms\verdi_uart_waveform.png")
WAVE_SOC = get_b64(r"Waveforms\wave_exp8_soc.png")
WAVE_UVM = get_b64(r"Waveforms\verdi_uvm_waveform.png")

CSS = """
@page {
    size: A4 portrait;
    margin: 0;
}
* {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact;
}
body {
    margin: 0;
    padding: 0;
    font-family: 'Latin Modern Roman', 'Georgia', 'Times New Roman', serif;
    font-size: 10pt;
    line-height: 1.52;
    color: #111;
    background: #fff;
}
.page {
    width: 210mm;
    height: 297mm;
    padding: 20mm 22mm 20mm 22mm;
    margin: 0 auto;
    page-break-after: always;
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.page-header {
    display: flex;
    justify-content: space-between;
    border-bottom: 0.6pt solid #333;
    padding-bottom: 4px;
    font-size: 8.5pt;
    font-style: italic;
    color: #333;
    margin-bottom: 14px;
}
.page-footer {
    display: flex;
    justify-content: space-between;
    border-top: 0.4pt solid #aaa;
    padding-top: 4px;
    font-size: 8.5pt;
    color: #444;
}
.page-content {
    flex-grow: 1;
}
h1.chap-title {
    font-size: 16.5pt;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-top: 0;
    margin-bottom: 12px;
    color: #0d233a;
    border-bottom: 1.5pt solid #0d233a;
    padding-bottom: 5px;
}
h2.chap-num {
    font-size: 13pt;
    font-weight: bold;
    color: #333;
    margin-top: 0;
    margin-bottom: 4px;
}
h2.sec-title {
    font-size: 11.5pt;
    font-weight: bold;
    margin-top: 12px;
    margin-bottom: 6px;
    color: #111;
}
h3.subsec-title {
    font-size: 10.5pt;
    font-weight: bold;
    margin-top: 9px;
    margin-bottom: 4px;
    color: #222;
}
p {
    margin-top: 0;
    margin-bottom: 8px;
    text-align: justify;
}
ul, ol {
    margin-top: 3px;
    margin-bottom: 8px;
    padding-left: 20px;
}
li {
    margin-bottom: 3px;
    text-align: justify;
}
.callout {
    border: 1pt solid #2b5797;
    background-color: #f4f8fc;
    padding: 8px 12px;
    margin: 10px 0;
    border-radius: 2px;
}
.callout-title {
    font-weight: bold;
    font-size: 9pt;
    color: #1b365d;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}
.callout-body {
    font-size: 9pt;
    color: #222;
    margin: 0;
    line-height: 1.4;
}
table.latex-table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0;
    font-size: 8.2pt;
    line-height: 1.35;
}
table.latex-table th {
    border-top: 1.5pt solid #000;
    border-bottom: 0.8pt solid #000;
    padding: 5px 5px;
    font-weight: bold;
    text-align: left;
    background: #fafafa;
}
table.latex-table td {
    padding: 4px 5px;
    border-bottom: 0.4pt solid #ddd;
    vertical-align: top;
}
table.latex-table tr:last-child td {
    border-bottom: 1.5pt solid #000;
}
.caption {
    font-size: 8.8pt;
    margin-bottom: 5px;
    text-align: left;
}
.caption-fig {
    font-size: 8.8pt;
    margin-top: 6px;
    margin-bottom: 8px;
    text-align: center;
}
.caption b, .caption-fig b {
    font-weight: bold;
}
.listing-box {
    border: 0.8pt solid #cfd8dc;
    background: #fbfcfd;
    padding: 6px 8px;
    margin: 8px 0 4px 0;
    border-radius: 2px;
    overflow: hidden;
}
.listing-table {
    width: 100%;
    border-collapse: collapse;
    font-family: 'Consolas', 'Courier New', monospace;
    font-size: 7.5pt;
    line-height: 1.3;
}
.listing-table td.ln {
    width: 26px;
    color: #888;
    text-align: right;
    padding-right: 6px;
    user-select: none;
    border-right: 0.6pt solid #e0e0e0;
    vertical-align: top;
}
.listing-table td.code {
    padding-left: 6px;
    color: #111;
    white-space: pre-wrap;
    word-break: break-all;
}
.kw { color: #0000bb; font-weight: bold; }
.dt { color: #006600; font-weight: bold; }
.st { color: #a31515; }
.cm { color: #008000; font-style: italic; }
.num { color: #098658; }
.fig-container {
    text-align: center;
    margin: 6px 0;
}
.fig-container img {
    max-width: 98%;
    max-height: 140mm;
    border: 0.6pt solid #ccc;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
"""

def make_page(content, page_num_str="", header_title="RTL-Based Environmental Monitoring and Data-Logging SoC"):
    header_html = ""
    if header_title:
        header_html = f"""
        <div class="page-header">
            <span>{header_title}</span>
            <span>Honours CBP Report</span>
        </div>
        """
    footer_html = ""
    if page_num_str:
        # Check if Roman numeral (front matter) or regular integer (chapters)
        if any(c in page_num_str for c in ['i', 'v', 'x']):
            footer_html = f"""
            <div class="page-footer" style="justify-content: center;">
                <span>{page_num_str}</span>
            </div>
            """
        else:
            footer_html = f"""
            <div class="page-footer">
                <span>Namratha Kavididevi | Roll No: 1602-23-735-157</span>
                <span>{page_num_str}</span>
            </div>
            """
    return f"""
    <div class="page">
        {header_html}
        <div class="page-content">
            {content}
        </div>
        {footer_html}
    </div>
    """

def format_listing(lines, start_idx=1):
    rows = []
    for i, line in enumerate(lines):
        ln = start_idx + i
        escaped = line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        rows.append(f"<tr><td class='ln'>{ln}</td><td class='code'>{escaped}</td></tr>")
    return "<div class='listing-box'><table class='listing-table'>" + "".join(rows) + "</table></div>"

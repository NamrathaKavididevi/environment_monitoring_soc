# -*- coding: utf-8 -*-
"""
Master Build Script for Honours Course Based Project Technical Report
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
College  : Vasavi College of Engineering (Autonomous)
Degree   : Honours Degree in System on Chip Design (ECE)
"""

import os
import sys
import subprocess

PROJECT_DIR = r"F:\honours course based project"
REPORT_GEN_DIR = os.path.join(PROJECT_DIR, "report_gen")
if REPORT_GEN_DIR not in sys.path:
    sys.path.insert(0, REPORT_GEN_DIR)

from common import CSS
from front_matter_and_chap1 import get_front_matter_and_chap1_pages
from chap2_arch import get_chap2_pages
from chap3_github import get_chap3_pages
from chap4_toolchain import get_chap4_pages
from chap5_addressmap import get_chap5_pages
from chap6_testplan import get_chap6_pages
from chap7_vips import get_chap7_pages
from chap8_uvm import get_chap8_pages
from chap9_waves import get_chap9_pages

def build_report():
    print("Gathering report pages...")
    all_pages = []

    # Front matter + Chapter 1
    fm_c1 = get_front_matter_and_chap1_pages()
    print(f"Front matter + Chapter 1: {len(fm_c1)} pages")
    all_pages.extend(fm_c1)

    # Chapter 2: Architecture
    c2 = get_chap2_pages()
    print(f"Chapter 2 (Architecture): {len(c2)} pages")
    all_pages.extend(c2)

    # Chapter 3: GitHub
    c3 = get_chap3_pages()
    print(f"Chapter 3 (GitHub): {len(c3)} pages")
    all_pages.extend(c3)

    # Chapter 4: RISC-V Toolchain
    c4 = get_chap4_pages()
    print(f"Chapter 4 (Toolchain): {len(c4)} pages")
    all_pages.extend(c4)

    # Chapter 5: Address Map
    c5 = get_chap5_pages()
    print(f"Chapter 5 (Address Map): {len(c5)} pages")
    all_pages.extend(c5)

    # Chapter 6: Testplan
    c6 = get_chap6_pages()
    print(f"Chapter 6 (Testplan): {len(c6)} pages")
    all_pages.extend(c6)

    # Chapter 7: VIPs & Interfaces
    c7 = get_chap7_pages()
    print(f"Chapter 7 (VIPs & Interfaces): {len(c7)} pages")
    all_pages.extend(c7)

    # Chapter 8: UVM TB & Block Diagram
    c8 = get_chap8_pages()
    print(f"Chapter 8 (UVM TB): {len(c8)} pages")
    all_pages.extend(c8)

    # Chapter 9: C Test, UVM Test, Waveforms & RCA
    c9 = get_chap9_pages()
    print(f"Chapter 9 (Waveforms & Sign-Off): {len(c9)} pages")
    all_pages.extend(c9)

    print(f"\nTotal Report Pages to render: {len(all_pages)}")

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Course Project Report - Namratha Kavididevi (1602-23-735-157)</title>
    <style>
    {CSS}
    </style>
</head>
<body>
{"".join(all_pages)}
</body>
</html>
"""

    html_path = os.path.join(PROJECT_DIR, "Course_Project_Report.html")
    pdf_path = os.path.join(PROJECT_DIR, "Course_Project_Report.pdf")

    print(f"Writing HTML to: {html_path}")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"HTML size: {os.path.getsize(html_path):,} bytes")

    # Run Chrome Headless to compile PDF
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        os.path.expanduser(r"~\AppData\Local\Google\Chrome\Application\chrome.exe")
    ]
    chrome_bin = None
    for cp in chrome_paths:
        if os.path.exists(cp):
            chrome_bin = cp
            break

    if not chrome_bin:
        print("ERROR: Chrome executable not found!")
        sys.exit(1)

    print(f"Found Chrome: {chrome_bin}")
    print("Compiling PDF with Chrome headless (print-to-pdf)...")

    cmd = [
        chrome_bin,
        "--headless",
        "--disable-gpu",
        "--run-all-compositor-stages-before-draw",
        "--no-pdf-header-footer",
        f"--print-to-pdf={pdf_path}",
        html_path
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0 and os.path.exists(pdf_path):
        pdf_size = os.path.getsize(pdf_path)
        print(f"\nSUCCESS! PDF generated successfully:")
        print(f"Path: {pdf_path}")
        print(f"Size: {pdf_size:,} bytes")
    else:
        print("Chrome error:")
        print(res.stderr)
        print(res.stdout)

if __name__ == "__main__":
    build_report()

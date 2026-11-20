# -*- coding: utf-8 -*-
"""
Front Matter and Chapter 1 (Project Proposal)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page, LOGO_B64

def get_front_matter_and_chap1_pages():
    pages = []

    # ==============================================================================
    # FRONT MATTER
    # ==============================================================================

    # Page 1: Cover Page
    cover_content = f"""
    <div style="text-align: center; display: flex; flex-direction: column; justify-content: space-between; height: 100%; padding: 10mm 0;">
        <div>
            <h2 style="font-size: 13pt; font-weight: bold; letter-spacing: 1.5px; margin: 0; color: #111;">HONOURS COURSE BASED PROJECT</h2>
            <div style="font-size: 10pt; font-weight: normal; margin-top: 6px; letter-spacing: 1px; color: #444;">TECHNICAL REPORT ON</div>
            <h1 style="font-size: 17pt; font-weight: bold; margin-top: 18px; margin-bottom: 12px; color: #0d233a; line-height: 1.4;">
                RTL-BASED ENVIRONMENTAL MONITORING AND DATA-LOGGING SYSTEM-ON-CHIP
            </h1>
            <div style="font-size: 9.5pt; font-style: italic; margin-top: 14px; line-height: 1.4; color: #333;">
                A Course Based Project Report Submitted in Partial Fulfillment of the Requirements for the<br>
                Award of the Honours Degree in
            </div>
            <div style="font-size: 12pt; font-weight: bold; margin-top: 8px; color: #111; letter-spacing: 0.5px;">
                SYSTEM ON CHIP DESIGN
            </div>
            <div style="font-size: 9.5pt; margin-top: 4px; font-weight: bold; color: #333;">
                BACHELOR OF ENGINEERING IN ELECTRONICS AND COMMUNICATION ENGINEERING
            </div>
        </div>

        <div style="margin: 15px 0;">
            <div style="font-size: 10pt; font-weight: normal; margin-bottom: 6px;">Submitted by:</div>
            <div style="font-size: 13pt; font-weight: bold; color: #111;">Namratha Kavididevi</div>
            <div style="font-size: 10.5pt; font-weight: bold; margin-top: 4px; color: #333;">Roll No: 1602-23-735-157</div>
        </div>

        <div>
            <img src="{LOGO_B64}" style="width: 85px; height: auto; margin-bottom: 10px;">
            <div style="font-size: 11pt; font-weight: bold; letter-spacing: 0.5px; color: #0d233a;">
                DEPARTMENT OF ELECTRONICS AND COMMUNICATION ENGINEERING
            </div>
            <div style="font-size: 11.5pt; font-weight: bold; margin-top: 4px; color: #111;">
                VASAVI COLLEGE OF ENGINEERING (AUTONOMOUS)
            </div>
            <div style="font-size: 9pt; color: #444; margin-top: 3px;">
                Ibrahimbagh, Hyderabad – 500031, Telangana, India
            </div>
            <div style="font-size: 10pt; font-weight: bold; margin-top: 10px; color: #111;">
                ACADEMIC YEAR 2026 – 2027
            </div>
        </div>
    </div>
    """
    pages.append(make_page(cover_content, "", ""))

    # Page 2: Certificate (ii)
    cert_content = f"""
    <div style="text-align: center; margin-top: 10px; margin-bottom: 25px;">
        <h1 style="font-size: 18pt; font-weight: bold; letter-spacing: 1px; color: #0d233a; margin-bottom: 12px;">CERTIFICATE</h1>
        <div style="font-size: 12pt; font-weight: bold; color: #111;">VASAVI COLLEGE OF ENGINEERING (AUTONOMOUS)</div>
        <div style="font-size: 10pt; font-weight: bold; color: #333; margin-top: 2px;">DEPARTMENT OF ELECTRONICS AND COMMUNICATION ENGINEERING</div>
        <div style="font-size: 8.5pt; font-style: italic; color: #555; margin-top: 2px;">(Accredited by NAAC with ‘A++’ Grade, Affiliated to Osmania University)</div>
        <div style="font-size: 8.5pt; color: #555;">Ibrahimbagh, Hyderabad – 500031</div>
        <div style="margin-top: 15px;"><img src="{LOGO_B64}" style="width: 70px; height: auto;"></div>
    </div>

    <div style="font-size: 10pt; line-height: 1.8; text-align: justify; margin: 25px 0;">
        This is to certify that the project report entitled <b>“RTL-BASED ENVIRONMENTAL MONITORING AND DATA-LOGGING SYSTEM-ON-CHIP”</b>, submitted by <b>Namratha Kavididevi (Roll No: 1602-23-735-157)</b>, a student of the Department of Electronics and Communication Engineering, Vasavi College of Engineering (Autonomous), in partial fulfillment of the requirements for the award of the Honours Degree in <b>System on Chip Design</b> in Electronics and Communication Engineering, is a record of the bonafide work carried out by her during the academic year 2026–2027 under the supervision of <b>Dr. M. Praveen Kumar</b>.
        <br><br>
        The results embodied in this project report have not been submitted to any other University or Institute for the award of any degree.
    </div>

    <div style="display: flex; justify-content: space-between; margin-top: 55px; font-size: 9.5pt;">
        <div style="text-align: left; width: 45%;">
            <b>Supervisor</b><br>
            <b>Dr. M. Praveen Kumar</b><br>
            Assistant Professor<br>
            Department of ECE<br>
            Vasavi College of Engineering
        </div>
        <div style="text-align: right; width: 45%;">
            <b>Head of the Department</b><br>
            <b>Dr. E. Sreenivasa Rao</b><br>
            Professor and Head<br>
            Department of ECE<br>
            Vasavi College of Engineering
        </div>
    </div>

    <div style="display: flex; justify-content: space-between; margin-top: 55px; font-size: 9.5pt;">
        <div style="text-align: left; width: 50%;">
            <b>Signature of the External Examiner</b>
        </div>
        <div style="text-align: right; width: 50%;">
            <b>Date: 21st November, 2026</b>
        </div>
    </div>
    """
    pages.append(make_page(cert_content, "ii", ""))

    # Page 3: Declaration (iii)
    decl_content = """
    <div style="text-align: center; margin-top: 10px; margin-bottom: 30px;">
        <h1 style="font-size: 18pt; font-weight: bold; letter-spacing: 1px; color: #0d233a;">DECLARATION</h1>
    </div>

    <div style="font-size: 10pt; line-height: 1.8; text-align: justify;">
        I, the undersigned, hereby declare that the project report titled <b>“RTL-Based Environmental Monitoring and Data-Logging System-on-Chip”</b>, submitted in partial fulfillment of the requirements for the award of the Honours Degree in System on Chip Design at Vasavi College of Engineering (Autonomous), Ibrahimbagh, Hyderabad, is a bonafide work carried out by me under the supervision of <b>Dr. M. Praveen Kumar</b>.
        <br><br>
        I declare that this submission represents my own ideas and work, and wherever the ideas or words of others have been included, I have adequately and accurately cited and referenced the sources. I further declare that I have adhered to the principles of academic honesty and integrity and have not misrepresented or fabricated any data, ideas, facts, or sources in this submission.
        <br><br>
        I understand that any violation of the above declaration may result in disciplinary action by the institute and/or the University and may also invite penal action from the sources whose work has not been properly cited or for which permission has not been obtained.
        <br><br>
        I also declare that this report has not previously formed the basis for the award of any degree, diploma, or similar title from any other University or institution.
    </div>

    <div style="display: flex; justify-content: space-between; margin-top: 85px; font-size: 10pt;">
        <div>
            <b>Place:</b> Hyderabad, Telangana<br><br>
            <b>Date:</b> 21st November, 2026
        </div>
        <div style="text-align: right;">
            <b>Signature of Student:</b><br><br><br>
            <b>Namratha Kavididevi</b><br>
            Roll No: 1602-23-735-157<br>
            Department of ECE, VCE
        </div>
    </div>
    """
    pages.append(make_page(decl_content, "iii", ""))

    # Page 4: Acknowledgements (iv)
    ack_content = """
    <div style="text-align: center; margin-top: 10px; margin-bottom: 25px;">
        <h1 style="font-size: 18pt; font-weight: bold; letter-spacing: 1px; color: #0d233a;">ACKNOWLEDGEMENTS</h1>
    </div>

    <div style="font-size: 10pt; line-height: 1.8; text-align: justify;">
        The satisfaction and academic fulfillment that accompany the successful completion of any engineering project would be incomplete without expressing sincere gratitude to the individuals whose guidance, mentorship, and infrastructure support made this work possible.
        <br><br>
        I express my profound gratitude to my project supervisor, <b>Dr. M. Praveen Kumar</b>, Assistant Professor, Department of Electronics and Communication Engineering, Vasavi College of Engineering (Autonomous), for his continuous technical direction, architectural reviews, and mentorship throughout the RTL integration, bare-metal firmware bring-up, and UVM verification phases of this System-on-Chip project.
        <br><br>
        I extend my sincere thanks to <b>Dr. E. Sreenivasa Rao</b>, Professor and Head of the Department of Electronics and Communication Engineering, for providing access to industry-standard Synopsys VCS, Verdi, and ModelSim/QuestaSim EDA computing facilities and fostering a strong research environment in VLSI and SoC design.
        <br><br>
        Finally, I thank the Principal and management of Vasavi College of Engineering, my peers in the ECE department, and my family for their constant encouragement and moral support.
    </div>

    <div style="text-align: right; margin-top: 80px; font-size: 10pt;">
        <b>Namratha Kavididevi</b><br>
        Roll No: 1602-23-735-157<br>
        Department of ECE, Vasavi College of Engineering
    </div>
    """
    pages.append(make_page(ack_content, "iv", ""))

    # Page 5: Abstract (v)
    abs_content = """
    <div style="text-align: center; margin-top: 10px; margin-bottom: 20px;">
        <h1 style="font-size: 18pt; font-weight: bold; letter-spacing: 1px; color: #0d233a;">ABSTRACT</h1>
    </div>

    <div style="font-size: 10pt; line-height: 1.75; text-align: justify;">
        This Honours Course Based Project report documents the architectural design, synthesizable RTL integration, bare-metal RISC-V firmware development, and comprehensive UVM 1.2 functional verification of an <b>RTL-Based Environmental Monitoring and Data-Logging System-on-Chip (SoC)</b> engineered for autonomous, real-time sensing edge nodes. Built around the open-source Western Digital / CHIPS Alliance <b>VeeR EL2 RV32IMC</b> processor core with 32 KB Instruction Closely Coupled Memory (ICCM) and 64 KB Data Closely Coupled Memory (DCCM), the SoC bridges the critical gap between isolated academic peripheral demos and industrial-grade multi-peripheral sensor platforms.
        <br><br>
        The system architecture integrates a high-performance memory-mapped crossbar interconnect with round-robin arbitration, 64 KB of unified on-chip single-cycle SRAM, and six dedicated memory-mapped peripheral subsystems: an <b>I2C Master Controller</b> for periodic ambient temperature and humidity sensor acquisition; an <b>Interval Timer IP</b> establishing precision sampling intervals and time-stamping; an <b>SPI Master Controller</b> providing high-speed burst writes to external non-volatile Flash memory for durable logging; a <b>PWM Generator</b> modulating audible alarm tones upon sensor limit violations; a 32-bit bidirectional <b>GPIO Controller</b> driving visual warning LEDs and capturing emergency operator triggers; and a 115200-baud <b>UART Controller</b> delivering continuous live telemetry reports and diagnostic trace logs.
        <br><br>
        In addition, a standalone <b>NIST FIPS-197 AES-128 Encryption Module</b> was verified in its own dedicated subsystem environment to demonstrate tamper-proof cryptographic telemetry hardening without modifying the core SoC RTL footprint.
        <br><br>
        Comprehensive functional verification was achieved across a <b>23-test dual-sided verification matrix</b> combining bare-metal C firmware (<code>main.c</code>, <code>uart.c</code>) executing on the core with a modular UVM 1.2 environment featuring six custom Verification IPs (UART, GPIO, Timer, SPI, I2C, and PWM). Cycle-accurate Synopsys Verdi and QuestaSim waveform analysis demonstrates deterministic sensor readouts, flawless crossbar arbitration, precise address decode trapping (DECERR), and a 100% clean regression signature (<code>PASS_SIGNATURE = 0x900D</code>).
    </div>
    """
    pages.append(make_page(abs_content, "v", ""))

    # Pages 6-8: Contents (Table of Contents vi, vii, viii)
    toc_p1 = """
    <div style="text-align: left; margin-bottom: 12px;">
        <h1 style="font-size: 17pt; font-weight: bold; color: #0d233a;">Contents</h1>
    </div>

    <div style="font-size: 9pt; line-height: 1.65;">
        <div style="display: flex; justify-content: space-between;"><b>Certificate</b> <b>ii</b></div>
        <div style="display: flex; justify-content: space-between;"><b>Declaration</b> <b>iii</b></div>
        <div style="display: flex; justify-content: space-between;"><b>Acknowledgements</b> <b>iv</b></div>
        <div style="display: flex; justify-content: space-between;"><b>Abstract</b> <b>v</b></div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>1 Project Proposal</b> <b>1</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.1 Project Title and Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.2 Motivation and Problem Statement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.3 Literature Survey & Industrial Benchmark . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.4 Proposed Architectural Innovations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.5 Project Objectives & Deliverables . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">1.6 Project Milestones & Work Breakdown . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>2 Architecture Specification</b> <b>5</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.1 SoC High-Level Architectural Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.2 System-Level Specifications & IP Inventory . . . . . . . . . . . . . . . . . . . . . . . . . . . 6</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.3 External Top-Level Pinout Specifications . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.4 Control Path Arbitration & Interconnect Bus Matrix . . . . . . . . . . . . . . . . . . . . . 8</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.5 Data Path Pipeline & Peripheral Interconnect Bridge . . . . . . . . . . . . . . . . . . . . . 9</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.6 Sensor Ingest Subsystem (I2C Master FSM) . . . . . . . . . . . . . . . . . . . . . . . . . . . 9</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.7 Precision Sampling Cadence Subsystem (Interval Timer) . . . . . . . . . . . . . . . . . 10</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.8 Non-Volatile Telemetry Logging Subsystem (SPI Master) . . . . . . . . . . . . . . . . . . 10</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.9 Alerting & Annunciation Subsystem (PWM & GPIO) . . . . . . . . . . . . . . . . . . . . . 11</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.10 Host Telemetry Streaming Subsystem (UART Transceiver) . . . . . . . . . . . . . . . 11</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.11 Clock Domain, Reset Tree, and Power Architecture . . . . . . . . . . . . . . . . . . . . . 12</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.12 Interrupt Architecture & Core Vectored Servicing . . . . . . . . . . . . . . . . . . . . . . 12</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">2.13 Safety, Fault Handling, and Bus Error Protection (DECERR) . . . . . . . . . . . . . . 13</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>3 GitHub Account Steps</b> <b>14</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">3.1 Overview of Version Control in SoC Design . . . . . . . . . . . . . . . . . . . . . . . . . . . 14</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">3.2 Step-by-Step GitHub Setup Procedure . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">3.3 Best Practices for Open-Source Hardware Repositories . . . . . . . . . . . . . . . . . . . 17</div>
    </div>
    """
    pages.append(make_page(toc_p1, "vi", ""))

    toc_p2 = """
    <div style="text-align: left; margin-bottom: 12px;">
        <h1 style="font-size: 17pt; font-weight: bold; color: #0d233a;">Contents (Continued)</h1>
    </div>

    <div style="font-size: 9pt; line-height: 1.65;">
        <div style="display: flex; justify-content: space-between;"><b>4 RISC-V Toolchain Setup Steps</b> <b>18</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.1 RISC-V GNU Toolchain Overview (RV32IMC Target) . . . . . . . . . . . . . . . . . . . 18</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.2 Prerequisites & Environment Configuration . . . . . . . . . . . . . . . . . . . . . . . . . . . 18</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.3 Windows Terminal & Linux Installation Steps . . . . . . . . . . . . . . . . . . . . . . . . . . 18</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.4 Low-Level Assembly Bootstrap Architecture (crt0.S) . . . . . . . . . . . . . . . . . . . . 19</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.5 Linker Script Architecture (link.ld) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.6 Automated Firmware Build Pipeline (Makefile) . . . . . . . . . . . . . . . . . . . . . . . . . 21</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">4.7 Disassembly Analysis & Memory Footprint Verification . . . . . . . . . . . . . . . . . . 21</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>5 Address Map</b> <b>22</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">5.1 System-Level Address Map Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 22</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">5.2 Peripheral Register Specifications . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">5.3 Address Decode Logic & Bus Fault Handling . . . . . . . . . . . . . . . . . . . . . . . . . . 25</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>6 Testplan with External/Internal Test Column</b> <b>26</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">6.1 Verification Methodology & Strategy . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 26</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">6.2 Dual-Perspective Verification Architecture (Internal vs. External) . . . . . . . . . . 26</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">6.3 Master Comprehensive Verification Matrix (Tests 1 to 23) . . . . . . . . . . . . . . . . 26</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">6.4 Test Coverage Goals & Acceptance Criteria . . . . . . . . . . . . . . . . . . . . . . . . . . . 29</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>7 All VIPs CSV Files and Interface Files</b> <b>30</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">7.1 Automated VIP Generation Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">7.2 CSV Port Definition Specifications (6 VIPs) . . . . . . . . . . . . . . . . . . . . . . . . . . 30</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">7.3 SystemVerilog VIP Interface Architectures . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">7.4 Automated VIP Master Build & Compilation Manifest . . . . . . . . . . . . . . . . . . . 38</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">7.5 Top-Level SoC Verification Testbench Architecture . . . . . . . . . . . . . . . . . . . . . 39</div>
    </div>
    """
    pages.append(make_page(toc_p2, "vii", ""))

    toc_p3 = """
    <div style="text-align: left; margin-bottom: 12px;">
        <h1 style="font-size: 17pt; font-weight: bold; color: #0d233a;">Contents (Continued)</h1>
    </div>

    <div style="font-size: 9pt; line-height: 1.65;">
        <div style="display: flex; justify-content: space-between;"><b>8 UVM Testbench Block Diagram along with All UVM VIPs</b> <b>40</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.1 UVM 1.2 Verification Architecture Overview . . . . . . . . . . . . . . . . . . . . . . . . . . 40</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.2 Hierarchical Component Roles and Transaction Flows . . . . . . . . . . . . . . . . . . 41</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.3 Sequence Item Transaction Definition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 41</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.4 Virtual Sequence Orchestration . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 42</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.5 Automated UVM Regression Execution Script . . . . . . . . . . . . . . . . . . . . . . . . . 43</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">8.6 Coverage Metrics & Sign-Off Criteria . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 43</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>9 C Test Case, UVM Test Case with Wave Snippet</b> <b>44</b></div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">9.1 Bare-Metal C Verification Firmware (main.c) . . . . . . . . . . . . . . . . . . . . . . . . . . 44</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">9.2 UVM Test Implementation (uart_test.sv) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 45</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">9.3 Cycle-Accurate Waveform Analysis (Synopsys Verdi) . . . . . . . . . . . . . . . . . . . . 46</div>
        <div style="display: flex; justify-content: space-between; padding-left: 25px;">9.3.1 I2C Sensor Ingest Waveform Analysis . . . . . . . . . . . . . . . . . . . . . . . . . . . 46</div>
        <div style="display: flex; justify-content: space-between; padding-left: 25px;">9.3.2 AXI4 High-Performance Interconnect Waveform Analysis . . . . . . . . . . . . . 47</div>
        <div style="display: flex; justify-content: space-between; padding-left: 25px;">9.3.3 UART Serial Telemetry Streaming Waveform Analysis . . . . . . . . . . . . . . . 48</div>
        <div style="display: flex; justify-content: space-between; padding-left: 25px;">9.3.4 Full SoC Top-Level System Integration Waveform Analysis . . . . . . . . . . . . 49</div>
        <div style="display: flex; justify-content: space-between; padding-left: 25px;">9.3.5 UVM VIP Agent Sequence Waveform Analysis . . . . . . . . . . . . . . . . . . . . . 49</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">9.4 Root Cause Analysis & Debug Log . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 50</div>
        <div style="display: flex; justify-content: space-between; padding-left: 15px;">9.5 Verification Sign-Off & Conclusion . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 50</div>
        <br>
        <div style="display: flex; justify-content: space-between;"><b>References & Technical Standards</b> <b>50</b></div>
    </div>
    """
    pages.append(make_page(toc_p3, "viii", ""))

    # Page 9: List of Figures (ix)
    lof_content = """
    <div style="text-align: left; margin-bottom: 12px;">
        <h1 style="font-size: 17pt; font-weight: bold; color: #0d233a;">List of Figures</h1>
    </div>

    <div style="font-size: 9pt; line-height: 1.8;">
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 2.1:</b> RTL-Based Environmental Monitoring SoC Architecture Block Diagram</span>
            <b>5</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 8.1:</b> Complete UVM 1.2 Multi-Agent Verification Environment Architecture</span>
            <b>40</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 9.1:</b> Synopsys Verdi Waveform — I2C Sensor Ingest Verification</span>
            <b>46</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 9.2:</b> Synopsys Verdi Waveform — AXI4 High-Performance Interconnect Verification</span>
            <b>47</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 9.3:</b> Synopsys Verdi Waveform — UART Serial Telemetry Streaming Verification</span>
            <b>48</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 9.4:</b> Full SoC Top-Level System Integration Waveform (Internal C Execution)</span>
            <b>49</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Figure 9.5:</b> Synopsys Verdi Waveform — UVM VIP Agent Sequence Verification</span>
            <b>49</b>
        </div>
    </div>
    """
    pages.append(make_page(lof_content, "ix", ""))

    # Page 10: List of Tables (x)
    lot_content = """
    <div style="text-align: left; margin-bottom: 12px;">
        <h1 style="font-size: 17pt; font-weight: bold; color: #0d233a;">List of Tables</h1>
    </div>

    <div style="font-size: 9pt; line-height: 1.8;">
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 1.1:</b> Project Milestones and Work Breakdown Schedule</span>
            <b>4</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 2.1:</b> Complete IP Block Inventory & Parameter Specifications</span>
            <b>6</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 2.2:</b> System Power, Clock, and Primary Communication Interface Pinout</span>
            <b>7</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 2.3:</b> Sensor, Logging, Alert, and Debug Interface Pinout</span>
            <b>8</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 3.1:</b> Git Command Reference & Open-Source Hardware Repository Checklist</span>
            <b>17</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.1:</b> Master SoC Memory & Peripheral Address Map (0x0000_0000 – 0xFFFF_FFFF)</span>
            <b>22</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.2:</b> UART Controller Register Map (0x1000_0000)</span>
            <b>23</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.3:</b> General Purpose I/O (GPIO) Register Map (0x1000_1000)</span>
            <b>23</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.4:</b> 32-Bit Interval Timer Register Map (0x1000_2000)</span>
            <b>24</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.5:</b> SPI Master Controller Register Map (0x1000_3000)</span>
            <b>24</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.6:</b> I2C Master Controller Register Map (0x1000_4000)</span>
            <b>25</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 5.7:</b> PWM Audio Buzzer Modulator Register Map (0x1000_5000)</span>
            <b>25</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 6.1:</b> Master Comprehensive Verification Matrix (Tests 1 to 23)</span>
            <b>26</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.1:</b> UART VIP Interface Port List (uart.csv)</span>
            <b>30</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.2:</b> GPIO VIP Interface Port List (gpio.csv)</span>
            <b>30</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.3:</b> Timer VIP Interface Port List (timer.csv)</span>
            <b>30</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.4:</b> SPI VIP Interface Port List (spi.csv)</span>
            <b>31</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.5:</b> I2C VIP Interface Port List (i2c.csv)</span>
            <b>31</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 7.6:</b> PWM VIP Interface Port List (pwm.csv)</span>
            <b>31</b>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span><b>Table 9.1:</b> Comprehensive Engineering Root Cause Analysis (RCA) Log</span>
            <b>50</b>
        </div>
    </div>
    """
    pages.append(make_page(lot_content, "x", ""))

    # ==============================================================================
    # CHAPTER 1: PROJECT PROPOSAL (Pages 1 to 4)
    # ==============================================================================

    # Page 1
    p1_content = """
    <h2 class="chap-num">Chapter 1</h2>
    <h1 class="chap-title">Project Proposal</h1>

    <h2 class="sec-title">1.1 Project Title and Classification</h2>
    <p>
        <b>Project Title:</b> RTL-Based Environmental Monitoring and Data-Logging System-on-Chip (SoC)<br>
        <b>Course / Degree:</b> Honours Degree in System on Chip Design (ECE)<br>
        <b>Candidate Name:</b> Namratha Kavididevi (Roll No: 1602-23-735-157)<br>
        <b>Supervisor:</b> Dr. M. Praveen Kumar, Assistant Professor, Department of ECE<br>
        <b>Institution:</b> Vasavi College of Engineering (Autonomous), Hyderabad – 500031<br>
        <b>Project Classification:</b> Digital VLSI Design, Computer Architecture, Embedded Firmware, UVM 1.2 Verification
    </p>

    <h2 class="sec-title">1.2 Motivation and Problem Statement</h2>
    <p>
        Autonomous environmental sensing edge nodes deployed in industrial automation, cleanrooms, server racks, precision agriculture, and aerospace facilities require continuous, deterministic monitoring of ambient parameters such as temperature, relative humidity, air quality, and atmospheric pressure. Conventional architectures rely on off-the-shelf microcontrollers where software loops frequently block on slow serial peripherals (I2C, SPI, UART). Under anomalous spikes or emergency conditions, CPU latency in servicing interrupts can lead to delayed acoustic/visual alerting, lost telemetry records, or memory corruption.
    </p>
    <p>
        Furthermore, academic VLSI projects frequently evaluate individual intellectual property (IP) cores in complete isolation using trivial Verilog testbenches. Real-world silicon, however, demands the integration of open-standard processor cores, multi-channel memory-mapped interconnect crossbars, tightly coupled memories, hardware error detection, and multi-agent Universal Verification Methodology (UVM 1.2) verification suites.
    </p>

    <div class="callout">
        <div class="callout-title">Core Engineering Challenge</div>
        <div class="callout-body">
            Engineering a synthesizable, robust, and silicon-proven System-on-Chip integrating an open-source RISC-V processor core (VeeR EL2) with six dedicated hardware peripherals, demonstrating non-blocking sensor acquisition, precision interval timing, non-volatile logging, threshold alarming, and full regression sign-off with UVM 1.2 VIPs.
        </div>
    </div>
    """
    pages.append(make_page(p1_content, "1"))

    # Page 2
    p2_content = """
    <h2 class="sec-title">1.3 Literature Survey & Industrial Benchmark</h2>
    <p>
        Contemporary industrial edge-sensing architectures were surveyed to establish architectural benchmarks:
    </p>
    <ul>
        <li><b>Microchip ATmega328P / SAMD21:</b> 8-bit / 32-bit single-issue architectures with narrow peripheral bandwidth and software-polled I2C/SPI interfaces. Under heavy logging, core execution stalls by up to 65%, rendering them unsuitable for high-frequency telemetry.</li>
        <li><b>STMicroelectronics STM32F4 / L4 Series:</b> High-performance ARM Cortex-M4 architectures utilizing proprietary AHB/APB matrix interconnects. While computationally capable, proprietary licensing limits open-source hardware customization and silicon sovereignty.</li>
        <li><b>Western Digital / CHIPS Alliance VeeR EL2:</b> A 1-to-2-way superscalar, 4-stage pipeline 32-bit RISC-V processor core supporting the RV32IMC instruction set. VeeR EL2 features tightly integrated 32 KB ICCM and 64 KB DCCM, out-of-order retirement, dual instruction issue, and an integrated Programmable Interrupt Controller (PIC).</li>
    </ul>

    <h2 class="sec-title">1.4 Proposed Architectural Innovations</h2>
    <p>
        To overcome conventional limitations, the proposed Environmental Monitoring SoC incorporates four major architectural innovations:
    </p>
    <ol>
        <li><b>Hardware-Decoupled Peripheral Acceleration:</b> Dedicated synthesizable controllers for I2C, SPI, UART, Timer, GPIO, and PWM eliminate CPU polling overhead. Hardware FSMs autonomously orchestrate serial transfers.</li>
        <li><b>Deterministic Memory-Mapped Crossbar Interconnect:</b> A high-performance interconnect matrix supporting round-robin arbitration, 32-bit address/data pipelines, and explicit address decode error trapping (DECERR) protecting memory integrity.</li>
        <li><b>Hardware-Accelerated Dual Alarming & Fail-Safe Logging:</b> Multi-stage threshold comparators directly govern pulse-width-modulated (PWM) audio buzzers and GPIO status indicators while concurrently streaming telemetry packets over SPI Flash.</li>
        <li><b>Standalone Cryptographic Telemetry Hardening:</b> An isolated NIST FIPS-197 AES-128 cryptographic engine was developed and verified in a dedicated verification environment to demonstrate payload encryption for secure telemetry links.</li>
    </ol>
    """
    pages.append(make_page(p2_content, "2"))

    # Page 3
    p3_content = """
    <h2 class="sec-title">1.4 Proposed Architectural Innovations (Continued)</h2>
    <p>
        The architectural design specifically addresses real-time determinism and fault resilience through dedicated hardware blocks:
    </p>
    <ul>
        <li><b>Hardware Sensor Ingest (I2C Master):</b> Implements automated START/STOP generation, 7-bit addressing, and ACK/NACK verification to autonomously poll ambient temperature and humidity sensors without CPU bit-banging.</li>
        <li><b>Precision Sampling Pacing (Interval Timer):</b> Dedicated 32-bit prescaled timer generating deterministic single-cycle sampling ticks (<code>sample_tick</code>) and level interrupts to govern sensor acquisition cadence.</li>
        <li><b>Non-Volatile Hardware Logging (SPI Master):</b> Master-mode SPI peripheral driving high-speed serial clock generation (SCLK), shift registers, and chip-select control to commit timestamped records to external Flash memory.</li>
        <li><b>Threshold Alert Generator (PWM & GPIO):</b> Configurable duty-cycle PWM IP driving an audible buzzer alarm upon threshold violations, coupled with atomic GPIO registers driving visual status LEDs.</li>
        <li><b>Continuous Telemetry Streaming (UART):</b> Hardware 8N1 serial transmitter streaming live telemetry frames to an external console or RF modem.</li>
        <li><b>Non-Blocking RISC-V Execution:</b> The VeeR EL2 core operates out of dedicated 32 KB ICCM and 64 KB DCCM closely coupled memories, insulating core execution from bus traffic.</li>
    </ul>

    <h2 class="sec-title">1.5 Project Objectives & Deliverables</h2>
    <p>
        The core engineering deliverables achieved across this project include:
    </p>
    <ul>
        <li><b>Deliverable 1 — Synthesizable SoC RTL:</b> Complete synthesizable SystemVerilog RTL for all peripheral wrappers, bus interconnect crossbar, and top-level SoC (<code>soc_top.sv</code>).</li>
        <li><b>Deliverable 2 — VeeR EL2 Core Integration:</b> Clean integration of the RV32IMC processor core with 32 KB ICCM, 64 KB DCCM, and Programmable Interrupt Controller (PIC).</li>
        <li><b>Deliverable 3 — Bare-Metal C Firmware Suite:</b> Production bare-metal C verification firmware (<code>main.c</code>, <code>uart.c</code>), startup bootstrap (<code>crt0.S</code>), and memory linker script (<code>link.ld</code>) compiled via <code>riscv64-unknown-elf-gcc</code>.</li>
    </ul>
    """
    pages.append(make_page(p3_content, "3"))

    # Page 4
    p4_content = """
    <ul>
        <li><b>Deliverable 4 — Comprehensive Verification Testplan:</b> A 23-test functional verification matrix (<code>Test_Plan.csv</code> / <code>Test_Plan.md</code>) featuring dual-sided Internal (C code) and External (SV/UVM testbench) checkpoints with explicit classification.</li>
        <li><b>Deliverable 5 — Modular UVM 1.2 Verification IPs:</b> Full IEEE 1800.2 UVM 1.2 VIP suite comprising 6 dedicated verification components (UART, GPIO, Timer, SPI, I2C, and PWM) synthesized via automated generator scripts.</li>
        <li><b>Deliverable 6 — Verdi Waveforms & Regression Proofs:</b> Cycle-accurate waveform traces captured in Synopsys VCS / Verdi and QuestaSim proving zero protocol violations, correct threshold alerting, and clean test completion.</li>
    </ul>

    <h2 class="sec-title">1.6 Project Milestones & Work Breakdown</h2>
    <p>
        The project development was executed systematically across seven structured milestones, as summarized in Table 1.1.
    </p>

    <div class="caption"><b>Table 1.1:</b> Project Milestones and Work Breakdown Schedule</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 10%;">Milestone</th>
                <th style="width: 40%;">Phase Description</th>
                <th style="width: 32%;">Target Output</th>
                <th style="width: 18%;">Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><b>M1</b></td>
                <td>Architectural Specification & Address Map Definition</td>
                <td>Architecture_Specification.md, Memory Map</td>
                <td>Completed & Signed Off</td>
            </tr>
            <tr>
                <td><b>M2</b></td>
                <td>Peripherals RTL Integration (UART, GPIO, Timer, SPI, I2C, PWM)</td>
                <td>Synthesizable RTL wrappers, Interconnect Crossbar</td>
                <td>Verified in VCS</td>
            </tr>
            <tr>
                <td><b>M3</b></td>
                <td>RISC-V VeeR EL2 Core Integration & Wrapper</td>
                <td>veer_wrapper.sv, soc_top.sv, 64 KB SRAM</td>
                <td>Verified in VCS</td>
            </tr>
            <tr>
                <td><b>M4</b></td>
                <td>RISC-V Toolchain Bring-up & Bare-Metal Firmware</td>
                <td>crt0.S, link.ld, main.c, uart.c, ctest.hex</td>
                <td>Verified (0x900D pass)</td>
            </tr>
            <tr>
                <td><b>M5</b></td>
                <td>Testplan Development (Internal / External Column)</td>
                <td>Test_Plan.csv, Test_Plan.xlsx (23 Tests)</td>
                <td>23 Tests Defined</td>
            </tr>
            <tr>
                <td><b>M6</b></td>
                <td>UVM VIP Architecture & Testbench Infrastructure</td>
                <td>6 VIP packages, soc_test, tb_top.sv</td>
                <td>Clean Compile & Run</td>
            </tr>
            <tr>
                <td><b>M7</b></td>
                <td>Waveform Analysis & Final Report Documentation</td>
                <td>Verdi waveforms, Course Project Report</td>
                <td>Final Sign-Off</td>
            </tr>
        </tbody>
    </table>
    """
    pages.append(make_page(p4_content, "4"))

    return pages

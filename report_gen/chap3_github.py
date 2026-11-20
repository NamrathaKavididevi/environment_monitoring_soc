# -*- coding: utf-8 -*-
"""
Chapter 3: GitHub Account Steps (Pages 14 to 17)
Candidate: Namratha Kavididevi (Roll No: 1602-23-735-157)
"""

from common import make_page, format_listing

def get_chap3_pages():
    pages = []

    # Listings defined beforehand
    lst3_1 = format_listing([
        '# Step 4: Generate a high-security Ed25519 SSH key pair',
        'ssh-keygen -t ed25519 -C "namratha.kavididevi@vasavi.ac.in"',
        '# Enter file in which to save the key (/home/namratha/.ssh/id_ed25519): [Press Enter]',
        '# Enter passphrase (empty for no passphrase): [Enter Passphrase]',
        '',
        '# Step 5: Start the local SSH agent service in PowerShell / Bash',
        'eval $(ssh-agent -s)',
        '# Agent pid 4812',
        '',
        '# Step 6: Add the generated private key to the SSH agent',
        'ssh-add ~/.ssh/id_ed25519',
        '# Identity added: /home/namratha/.ssh/id_ed25519 (namratha.kavididevi@vasavi.ac.in)'
    ], 1)

    lst3_2 = format_listing([
        '# Step 9: Configure Git global identity credentials',
        'git config --global user.name "Namratha Kavididevi"',
        'git config --global user.email "namratha.kavididevi@vasavi.ac.in"',
        'git config --global init.defaultBranch main',
        'git config --global core.autocrlf input',
        '',
        '# Verify global settings',
        'git config --list',
        '# user.name=Namratha Kavididevi',
        '# user.email=namratha.kavididevi@vasavi.ac.in'
    ], 1)

    lst3_3 = format_listing([
        '# Step 11: Initialize repository and checkout main branch',
        'cd "F:/honours course based project"',
        'git init -b main',
        '',
        '# Step 12: Add GitHub remote URL',
        'git remote add origin https://github.com/NamrathaKavididevi/environment_monitoring_soc.git',
        '',
        '# Verify remote configuration',
        'git remote -v',
        '# origin  https://github.com/NamrathaKavididevi/environment_monitoring_soc.git (fetch)',
        '# origin  https://github.com/NamrathaKavididevi/environment_monitoring_soc.git (push)'
    ], 1)

    lst3_4 = format_listing([
        '# Electronic Design Automation (EDA) Simulation Artifacts',
        '*.vpd',
        '*.fsdb',
        '*.vcd',
        '*.wlf',
        '*.log',
        'novas.*',
        'verdiLog/',
        'simv*',
        'csrc/',
        'work/',
        '',
        '# Firmware Compiler Intermediates',
        '*.o',
        '*.elf',
        '*.bin',
        '*.d',
        '',
        '# Temporary System Files',
        'Thumbs.db',
        '.DS_Store'
    ], 1)

    lst3_5 = format_listing([
        'commit 4a9f1b2c (HEAD -> main, origin/main)',
        'Author: Namratha Kavididevi <namratha.kavididevi@vasavi.ac.in>',
        'Date:   Sat Nov 21 00:30:15 2026 +0530',
        '',
        '    docs: clean project workspace and finalize course project documentation',
        '    - Remove temporary helper scripts and obsolete intermediate files',
        '    - Update master Test_Plan with verified internal/external columns',
        '    - Stage official Vasavi College logo and 5 Verdi waveform captures',
        '    - Verify 6 VIP interfaces and CSV signal manifests'
    ], 1)

    # Page 14
    p14_content = f"""
    <h2 class="chap-num">Chapter 3</h2>
    <h1 class="chap-title">GitHub Account Steps</h1>

    <h2 class="sec-title">3.1 Overview of Version Control in SoC Design</h2>
    <p>
        Modern System-on-Chip (SoC) engineering involves complex, multi-layered codebases comprising synthesizable RTL, testbenches, verification components (VIPs), memory models, linker scripts, and embedded firmware. Robust version control via Git and GitHub is essential to ensure traceability, enable collaborative peer review, maintain reproducible build environments, and safeguard intellectual property across all design milestones.
    </p>

    <h2 class="sec-title">3.2 Step-by-Step GitHub Setup Procedure</h2>
    <p>
        The following 15-step procedure outlines the establishment of the remote repository hosting the Environmental Monitoring SoC:
    </p>

    <h3 class="subsec-title">Phase 1: Account Creation, Security & Git Installation</h3>
    <ul>
        <li><b>Step 1 — GitHub Account Creation:</b> Navigate to <code>https://github.com</code> and register an account using the institutional email address.</li>
        <li><b>Step 2 — Two-Factor Authentication (2FA):</b> Enforce time-based one-time password (TOTP) 2FA using an authenticator app to protect the repository from unauthorized access.</li>
        <li><b>Step 3 — Git Client Installation:</b> Download and install Git for Windows (v2.46.0+) or configure Git on Linux via <code>apt-get install git</code>.</li>
        <li><b>Step 4 — SSH Key Pair Generation:</b> Generate an elliptic curve ED25519 cryptographic key pair for secure SSH communication without password prompts.</li>
        <li><b>Step 5 — Start the SSH Agent:</b> Ensure the background SSH authentication agent is active.</li>
        <li><b>Step 6 — Register the Private Key:</b> Add the newly generated private key to the local SSH agent.</li>
    </ul>

    <div class="caption"><b>Listing 3.1:</b> Terminal Commands for SSH Key Generation and Agent Registration</div>
    {lst3_1}
    """
    pages.append(make_page(p14_content, "14"))

    # Page 15
    p15_content = f"""
    <h3 class="subsec-title">Phase 2: GitHub Registration & Local Identity Configuration</h3>
    <ul>
        <li><b>Step 7 — Copy Public Key to GitHub:</b> Display the contents of <code>id_ed25519.pub</code> and paste it into GitHub under <i>Settings &rarr; SSH and GPG Keys &rarr; New SSH Key</i>.</li>
        <li><b>Step 8 — Verify SSH Connection:</b> Execute <code>ssh -T git@github.com</code> to verify authenticated communication with GitHub servers.</li>
        <li><b>Step 9 — Configure Local Git Identity:</b> Set global user name and email to match the project candidate identity.</li>
        <li><b>Step 10 — Create the Remote Repository:</b> On GitHub, create a new public repository named <code>environment_monitoring_soc</code>.</li>
    </ul>

    <div class="caption"><b>Listing 3.2:</b> Local Git User Identity and Global Environment Configuration</div>
    {lst3_2}

    <h3 class="subsec-title">Phase 3: Repository Initialization and Remote Linking</h3>
    <ul>
        <li><b>Step 11 — Initialize Local Repository:</b> In the project root directory (<code>F:/honours course based project</code>), initialize Git tracking.</li>
        <li><b>Step 12 — Link to GitHub Remote:</b> Add the official remote repository URL.</li>
    </ul>

    <div class="caption"><b>Listing 3.3:</b> Repository Initialization and Remote URL Binding</div>
    {lst3_3}
    """
    pages.append(make_page(p15_content, "15"))

    # Page 16
    p16_content = f"""
    <h3 class="subsec-title">Phase 4: Staging, .gitignore Architecture & Clean Commit</h3>
    <ul>
        <li><b>Step 13 — Configure <code>.gitignore</code> for EDA Tools:</b> Electronic Design Automation tools (Synopsys VCS, Verdi, QuestaSim, Vivado) produce massive binary simulation databases, log dumps, and temporary waveforms. A strict <code>.gitignore</code> ensures only synthesizable RTL, testbenches, documentation, and verified assets are tracked.</li>
    </ul>

    <div class="caption"><b>Listing 3.4:</b> Production <code>.gitignore</code> File for EDA & Firmware Toolchains</div>
    {lst3_4}

    <div class="caption"><b>Listing 3.5:</b> Clean Commit Log Showing Milestone Traceability</div>
    {lst3_5}
    """
    pages.append(make_page(p16_content, "16"))

    # Page 17
    p17_content = """
    <h3 class="subsec-title">Phase 5: Remote Push, Branch Protection & CI Integration</h3>
    <ul>
        <li><b>Step 14 — Remote Push to Main Branch:</b> Push the verified commit tree to GitHub using <code>git push -u origin main</code>.</li>
        <li><b>Step 15 — Branch Protection & Issue Tracking:</b> Enable GitHub branch protection rules requiring status checks and signed commits before merging future updates.</li>
    </ul>

    <h2 class="sec-title">3.3 Best Practices for Open-Source Hardware Repositories</h2>
    <p>
        Hardware repositories require structured directory organization. The <code>environment_monitoring_soc</code> repository adheres to industry best practices, separating synthesizable RTL (<code>rtl/</code>, <code>soc_top.sv</code>), verification components (<code>VIPs/</code>), bare-metal firmware (<code>ctest/</code>), and project documentation (<code>TestPlan/</code>).
    </p>

    <div class="caption"><b>Table 3.1:</b> Git Command Reference & Open-Source Hardware Repository Checklist</div>
    <table class="latex-table">
        <thead>
            <tr>
                <th style="width: 25%;">Git Command</th>
                <th style="width: 45%;">Operation & Purpose in Hardware Design</th>
                <th style="width: 30%;">Status in Project</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>git init -b main</code></td>
                <td>Initializes Git tracking with standard <code>main</code> branch naming.</td>
                <td>Completed</td>
            </tr>
            <tr>
                <td><code>git remote add origin ...</code></td>
                <td>Binds local workspace to GitHub remote repository.</td>
                <td>Configured & Verified</td>
            </tr>
            <tr>
                <td><code>git status --short</code></td>
                <td>Verifies that no EDA binary artifacts or simulation logs are untracked.</td>
                <td>Clean Workspace</td>
            </tr>
            <tr>
                <td><code>git commit -m "..."</code></td>
                <td>Creates atomic milestone commit with descriptive engineering message.</td>
                <td>Documented in Log</td>
            </tr>
            <tr>
                <td><code>git push -u origin main</code></td>
                <td>Synchronizes local commits with GitHub cloud infrastructure.</td>
                <td>Pushed Successfully</td>
            </tr>
        </tbody>
    </table>

    <div class="callout">
        <div class="callout-title">Public Repository Link</div>
        <div class="callout-body">
            The full synthesizable SystemVerilog RTL, UVM 1.2 Verification IPs, bare-metal C firmware, and documentation are accessible at:<br>
            <b>URL:</b> <code>https://github.com/NamrathaKavididevi/environment_monitoring_soc.git</code>
        </div>
    </div>
    """
    pages.append(make_page(p17_content, "17"))

    return pages

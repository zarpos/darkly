<div align="center">

# 🔒 Darkly

**A web security project from the 42 school curriculum.**  
The goal: find **14 hidden flags** in a deliberately vulnerable web application by exploiting real-world security vulnerabilities.

![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)
![Security](https://img.shields.io/badge/Topic-Web%20Security-red?style=for-the-badge)
![Flags](https://img.shields.io/badge/Flags-14-brightgreen?style=for-the-badge)

</div>

---

## 📖 What is Darkly?

Darkly is a **web penetration testing** project. You are given a VM running a PHP web application full of intentional security holes, and your job is to find and exploit them all.

Each vulnerability teaches a real concept from the OWASP Top 10 and general web security — from SQL injection to cookie tampering, from brute-force attacks to path traversal.

---

## 🚀 Launch the VM

The target machine runs inside a VirtualBox VM. Two launch methods are provided — **no configuration needed**, just drop the ISO and run.

> **Prerequisite:** Download `Darkly_i386.iso` from the 42 intra and place it inside the `setup/` folder.

### Option A — Shell script *(recommended — no extra installs)*

```bash
cd setup/
bash launch.sh          # create & boot the VM
bash launch.sh stop     # shut it down
bash launch.sh destroy  # remove it completely
```

Uses `VBoxManage`, which ships with VirtualBox. Nothing else to install.

### Option B — Vagrant

```bash
cd setup/
vagrant up        # create & boot the VM
vagrant halt      # shut it down
vagrant destroy   # remove it completely
```

Once the VM is running, open your browser at:

```
http://172.16.60.128
```

---

## 🏴 The 14 Flags

Each flag lives in `breaches/<flag>/Resources/` — a write-up is included for each one.

> ⚠️ **Spoiler-free zone.** If you haven't done the project yet, the write-ups are inside each subfolder — don't open them if you want the full experience!


## 📁 Project Structure

```
darkly/
├── breaches/               # One folder per flag
│   └── <FlagName>/
│       ├── flag            # The flag hash
│       └── Resources/
│           ├── explanation.txt   # Original notes
│           └── explanation.md   # Full write-up
├── setup/                  # VM launch environment
│   ├── launch.sh           # VBoxManage script (no Vagrant needed)
│   ├── Vagrantfile         # Vagrant alternative
│   ├── README.md           # Setup instructions
│   └── Darkly_i386.iso     # ⚠ Not committed (see .gitignore)
└── subject/
    └── en.subject.pdf      # Official project subject
```

---

## 🛡️ Vulnerabilities Covered

```
SQL Injection · XSS · Path Traversal · File Upload Bypass
Open Redirect · Cookie Tampering · Brute Force
HTTP Header Spoofing · Hidden Field Manipulation
Parameter Tampering · Information Disclosure · Hardcoded Backdoors
```

---

<div align="center">
<sub>Made with ☕ at <a href="https://42.fr">42 School</a></sub>
</div>

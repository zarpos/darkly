# Setup — Darkly VM

## Requirements

- [VirtualBox](https://www.virtualbox.org/) installed
- `Darkly_i386.iso` downloaded from the 42 intra and placed **in this folder**

---

## Option A — Shell script (recommended, no extra installs)

Uses `VBoxManage`, which comes bundled with VirtualBox. No need to install anything else.

```bash
cd setup/
bash launch.sh          # create and boot the VM
bash launch.sh stop     # shut down the VM
bash launch.sh destroy  # remove the VM completely
```

---

## Option B — Vagrant

Requires [Vagrant](https://www.vagrantup.com/) to be installed in addition to VirtualBox.

```bash
cd setup/
vagrant up        # create and boot the VM
vagrant halt      # shut down the VM
vagrant destroy   # remove the VM completely
```

---

Once booted, the challenge is accessible at:

```
http://172.16.60.128
```

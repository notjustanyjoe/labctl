# labctl

Build and manage a local Red Hat Enterprise Linux (RHEL) lab environment for testing and development.  
This project uses **Packer** to create RHEL base boxes and **Vagrant** to spin up multi-machine environments with optional **Ansible** provisioning.

---

## Requirements

Install the following on your host system:

- **Packer** ≥ 1.10  
- **Vagrant** ≥ 2.4  
- **VirtualBox** ≥ 7.x  
- (Optional) **Ansible** ≥ 2.14 for provisioning  

Ensure your user has access to `/dev/vboxdrv` (VirtualBox driver).

---

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/<your-user>/labctl.git
cd labctl
```

### 2. Prepare the RHEL ISO
1. Download the **RHEL DVD ISO** for your desired version (8 or 9) from  
   [https://access.redhat.com/downloads/content/rhel](https://access.redhat.com/downloads/content/rhel)
2. While on the download page, copy the **SHA256 checksum**.
3. Place the ISO under `packer/iso/`:
   ```bash
   mkdir -p packer/iso
   mv ~/Downloads/rhel-9.*-x86_64-dvd.iso packer/iso/
   ```
4. Copy a variable file template and edit it:
   ```bash
   cd packer
   cp rhel9.pkrvars.hcl.example rhel9.pkrvars.hcl
   # edit iso_path and iso_checksum
   cd ..
   ```

---

### 3. (One-time) Set up Vagrant registration
Generate a global `~/.vagrant.d/Vagrantfile` and install required plugins.

```bash
./scripts/setup-vagrant-registration.sh
```

You’ll be prompted for your **Organization ID** and **Activation Key**.

If you don’t have these yet:
1. Visit [https://console.redhat.com/insights/connector/activation-keys](https://console.redhat.com/insights/connector/activation-keys)  
2. Log in with your Red Hat Developer account.  
3. Create a key → choose **Role: Workstation**, **SLA: Self-Support**, **Usage: Development/Test**.  
4. Note your **Organization ID** and **Activation Key Name**.

---

### 4. Build the RHEL base box (Packer)
```bash
cd packer
packer fmt .
packer init .
packer validate -var-file=rhel9.pkrvars.hcl rhel.pkr.hcl
packer build    -var-file=rhel9.pkrvars.hcl rhel.pkr.hcl
cd ..
```

The output `.box` file is stored in `packer/builds/`.

---

### 5. Launch the lab (Vagrant)
```bash
cd vagrant
vagrant up
```

This will:
- Register the VMs with RHSM (via `vagrant-registration`)  
- Sync `/etc/hosts` entries between machines (via `vagrant-hosts`)  

Default VMs:
| Hostname | IP Address   | Purpose   |
|-----------|--------------|-----------|
| ctl       | 10.10.10.10  | Control   |
| node1     | 10.10.10.11  | Managed   |

SSH in:
```bash
vagrant ssh ctl
```

---

### 6. (Optional) Provision with Ansible
From your host:
```bash
ansible-playbook -i ansible/inventories/vagrant.ini ansible/playbooks/common.yml
```

---

### 7. Clean up
```bash
cd vagrant
vagrant destroy -f
```

This unregisters all VMs from RHSM and removes them cleanly.

---

## Directory Structure

```
labctl/
├── ansible/
│   ├── inventories/
│   │   └── vagrant.ini
│   └── playbooks/
│       └── common.yml
├── packer/
│   ├── http/
│   │   └── ks.cfg
│   ├── iso/
│   ├── scripts/
│   │   ├── prepare.sh
│   │   └── cleanup.sh
│   ├── builds/
│   └── rhel.pkr.hcl
├── vagrant/
│   └── Vagrantfile
└── scripts/
    └── setup-vagrant-registration.sh
```

---

## Notes
- The default Packer and Vagrant settings use **EFI**, 4 GB RAM, and 2 vCPUs.
- Boxes are automatically registered/unregistered via the `vagrant-registration` plugin.
- This project is intended for **development and testing only** (self-support SLA).

---

© 2025 labctl project
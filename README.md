# labctl

Build and manage a local Red Hat Enterprise Linux (RHEL) lab environment for testing and development.  
This project uses **Packer** to create RHEL base boxes and **Vagrant** to spin up multi-machine environments with optional **Ansible** provisioning.

---

## Requirements

The following software must be installed on your local machine before building and running the lab:

- [Packer](https://www.packer.io/) — used to build RHEL base boxes for Vagrant  
- [Vagrant](https://www.vagrantup.com/) — used to create and manage the lab VMs  
- [VirtualBox](https://www.virtualbox.org/) — virtualization provider for the lab environment  

(Optional) [Ansible](https://www.ansible.com/) — used for provisioning and configuration management

You must have a **Red Hat Subscription** to download the RHEL DVD ISO, create an activation key, and access repositories for package installs or updates.  
If you don’t already have an account, [create one here](https://developers.redhat.com) and accept the terms and conditions of the **Red Hat Developer Program**, which provides no-cost subscriptions for development use only.

---

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/<your-user>/labctl.git
cd labctl
```

### 2. Prepare the RHEL ISO
1. Download the **RHEL DVD ISO** and copy the checksum for your desired version (8 or 9) from  
   [https://access.redhat.com/downloads/content/rhel](https://access.redhat.com/downloads/content/rhel)
   > Click on **Show details** and then copy the **SHA-256 Checksum**.
2. Place the ISO under `packer/iso/`:
   ```bash
   mkdir -p packer/iso
   mv ~/Downloads/rhel-9.*-x86_64-dvd.iso packer/iso/
   ```
3. Copy a variable file template and edit it:
   ```bash
   cd packer
   cp rhel9.pkrvars.hcl.example rhel9.pkrvars.hcl
   # edit iso_path and iso_checksum
   vim rhel9.pkrvars.hcl
   cd ..
   ```

---

### 3. (One-time) Set up Vagrant registration
Generate a global `~/.vagrant.d/Vagrantfile` and install required plugins.

You’ll be prompted for your **Organization ID** and **Activation Key**.

If you don’t have these yet:
1. Visit [https://console.redhat.com/insights/connector/activation-keys](https://console.redhat.com/insights/connector/activation-keys)  
2. Log in with your Red Hat Developer account.  
3. Create a key → choose **Role: Workstation**, **SLA: Self-Support**, **Usage: Development/Test**.  
4. Note your **Organization ID** and **Activation Key Name**.

Now Run:
```bash
./scripts/setup-vagrant-registration.sh
```
> NOTE: This is only needed the first time you run this project or if your Organization ID/Activation Key changes.
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
│ ├── inventories/
│ │ └── vagrant.ini
│ └── playbooks/
│ └── common.yml
├── packer/
│ ├── builds/
│ ├── http/
│ │ ├── ks.cfg
│ │ └── (future ks10.cfg)
│ ├── iso/
│ ├── scripts/
│ │ ├── prepare.sh
│ │ └── cleanup.sh
│ ├── rhel.pkr.hcl
│ ├── rhel8.pkrvars.hcl.example
│ ├── rhel9.pkrvars.hcl.example
│ └── rhel10.pkrvars.hcl.example
├── vagrant/
│ └── Vagrantfile
├── scripts/
│ └── setup-vagrant-registration.sh
├── vagrant-plugins.list
└── README.md
```

---

## Notes
- The default Packer and Vagrant settings use **EFI**, 4 GB RAM, and 2 vCPUs.
- Boxes are automatically registered/unregistered via the `vagrant-registration` plugin.
- This project is intended for **development and testing only** (self-support SLA).
- **Tested and verified working with:** **RHEL 8** and **RHEL 9**. (RHEL 10 support in progress)

---

© 2025 labctl project
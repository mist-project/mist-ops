resource "proxmox_vm_qemu" "mist-backend-pg-dev" {
  name        = "vm-mist-backend-pg-dev"
  desc        = "Backend PostgreSQL Development VM"
  vmid        = "300"
  target_node = "pve-mistiop"

  agent            = 1
  clone            = "ubuntu-2204-template"
  full_clone       = true
  automatic_reboot = false

  # Hardware and network Settings
  boot    = ""
  qemu_os = "other"
  bios    = "seabios"

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }
  memory  = 4096
  balloon = 4096

  # Network Settings
  ipconfig0 = "ip=192.168.0.20/24,gw=192.168.0.1"
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Storage and Cloud-Init Settings
  scsihw = "virtio-scsi-single"
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "vm-storage"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage  = "vm-storage"
          size     = "32G"
          iothread = true
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type = "serial0"
  }


  os_type = "cloud-init"
  ciuser  = var.MIST_BACKEND_PG_DEV_USERNAME
  sshkeys = var.MIST_BACKEND_PG_DEV_SSH_PUBKEY
}


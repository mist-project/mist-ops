resource "proxmox_vm_qemu" "control-center" {
  name        = "vm-control-center"
  desc        = "Control Center VM"
  vmid        = "302"
  target_node = "pve-mistiop"

  agent            = 1
  clone            = "ubuntu-2204-template"
  full_clone       = true
  automatic_reboot = true

  # Hardware and network Settings
  qemu_os = "other"
  bios    = "seabios"

  cpu {
    cores   = 1
    sockets = 1
    type    = "x86-64-v2-AES"
  }
  memory  = 2048
  balloon = 1024

  # Network Settings
  ipconfig0 = "ip=192.168.0.22/24,gw=192.168.0.1"
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
  ciuser  = var.CONTROL_CENTER_USERNAME
  sshkeys = var.CONTROL_CENTER_SSH_PUBKEY
}


packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}


variable "sound_driver" {
  type = string
}

variable "accel_graphics" {
  type = string
}

variable "verbose" {
  type    = bool
  default = false
}

variable "cpu_cores" {
  type    = number
  default = 4
}

variable "memory" {
  type    = number
  default = 4096
}

variable "headless" {
  type    = bool
  default = false
}

locals {
  build_name_qemu       = join(".", ["windows-x86_64", replace(timestamp(), ":", "꞉"), "qcow2"]) # unicode replacement char for colon
  build_name_virtualbox = join(".", ["windows-x86_64", replace(timestamp(), ":", "꞉")]) # unicode replacement char for colon
}


source "qemu" "default" {
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c Packer_Provisioning_Shutdown"
  boot_command         = ["<enter>"]
  boot_wait            = "1s"
  cd_files             = ["drivers", "Autounattend.xml", "configure.ps1", "drivers.ps1", "winrm.ps1", "stage1.ps1", "stage2.ps1"]
  cd_label             = "Win11Install"
  disk_size            = "524288M"
  memory               = var.memory
  format               = "qcow2"
  accelerator          = "kvm"
  disk_discard         = "unmap"
  disk_detect_zeroes   = "unmap"
  disk_interface       = "virtio"
  disk_compression     = false
  skip_compaction      = true
  net_device           = "virtio-net"
  vga                  = "virtio"
  machine_type         = "q35"
  cpu_model            = "host"
  vtpm                 = true
  tpm_device_type      = "tpm-tis"
  efi_boot             = true
  efi_firmware_code    = "/usr/share/OVMF/x64/OVMF_CODE.secboot.4m.fd"
  efi_firmware_vars    = "/usr/share/OVMF/x64/OVMF_VARS.4m.fd"
  sockets              = 1
  cores                = var.cpu_cores
  threads              = 1
  qemuargs             = [["-rtc", "base=utc,clock=host"], ["-usbdevice", "mouse"], ["-usbdevice", "keyboard"]]
  headless             = var.headless
  iso_checksum         = "none"
  iso_url              = "win11.iso"
  output_directory     = "output/windows"
  communicator         = "winrm"
  winrm_username       = "user"
  winrm_password       = "packer-build-passwd"
  winrm_insecure       = true
  winrm_timeout        = "45m"
  vm_name              = local.build_name_qemu
}


build {
  sources = ["source.qemu.default"]

  provisioner "windows-shell" {
    inline = ["powershell -c \"[Environment]::CurrentDirectory = $PWD.Path; Invoke-Expression([System.IO.File]::ReadAllText('F:/stage1.ps1'))\""]
  }
  
  provisioner "windows-restart" {
  }
  
  provisioner "windows-shell" {
    inline = ["powershell -c \"[Environment]::CurrentDirectory = $PWD.Path; Invoke-Expression([System.IO.File]::ReadAllText('F:/stage2.ps1'))\""]
  }
  
  provisioner "windows-restart" {
  }

  provisioner "shell-local" {
    inline = [<<EOS
tee output/windows/windows-x86_64.run.sh <<EOF
#!/usr/bin/env bash
trap "trap - SIGTERM && kill -- -\$\$" SIGINT SIGTERM EXIT
mkdir -p "/tmp/swtpm.0" "share"
/usr/bin/swtpm socket --tpm2 --tpmstate dir="/tmp/swtpm.0" --ctrl type=unixio,path="/tmp/swtpm.0/vtpm.sock" &
/usr/bin/qemu-system-x86_64 \\
  -name windows-x86_64 \\
  -machine type=q35,accel=kvm \\
  -vga virtio \\
  -cpu host \\
  -drive file=${local.build_name_qemu},if=virtio,cache=writeback,discard=unmap,detect-zeroes=unmap,format=qcow2 \\
  -device tpm-tis,tpmdev=tpm0 -tpmdev emulator,id=tpm0,chardev=vtpm -chardev socket,id=vtpm,path=/tmp/swtpm.0/vtpm.sock \\
  -drive file=/usr/share/OVMF/x64/OVMF_CODE.secboot.4m.fd,if=pflash,unit=0,format=raw,readonly=on \\
  -drive file=efivars.fd,if=pflash,unit=1,format=raw \\
  -smp ${var.cpu_cores},sockets=1,cores=${var.cpu_cores},maxcpus=${var.cpu_cores} -m ${var.memory}M \\
  -netdev user,id=user.0 -device virtio-net,netdev=user.0 \\
  -audio driver=pa,model=hda,id=snd0 -device hda-output,audiodev=snd0 \\
  -virtfs local,path=share,mount_tag=host.0,security_model=mapped,id=host.0 \\
  -usbdevice mouse -usbdevice keyboard \\
  -rtc base=utc,clock=host
EOF
# -display none, -daemonize, hostfwd=::12345-:22 for running as a daemonized server
chmod +x output/windows/windows-x86_64.run.sh
EOS
    ]
    only_on = ["linux"]
    only    = ["qemu.default"]
  }
}

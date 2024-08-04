# Proof of concept windows deployment on metal or virtual

## WARNING

Some of the scripts in this project **will** destroy all data on your system. So be careful! **I will not take any responsibility for any of your lost files!**

# Installation Process

After the preamble: how to install everything? I assume after this point you want to try everything out first before going the steps to install everything onto your production machine. (**NO!!!**)

Your test environment should include packer for automation, swtpm for TPM emulation and either QEMU (Linux), VirtualBox (Windows) or Proxmox for virtualization.

Just execute pipeline.ps1 on either Windows or Linux and let the setup process build everything fully automated.

## ⚠️ WORK IN PROGRESS ⚠️

That's all for now. Happy deployment. --johndeedly

{ config, pkgs, ... }:
{

    # Enable virtualization and virt-manager
    virtualisation.libvirtd = {
        enable = true;
        qemu = {
            #ovmf.packages = [pkgs.unstable.OVMFFull];
            swtpm.enable = true;
        };
    };

    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
        virt-manager
        unstable.freerdp # Allow us to connect
    ];


    # Allow us to use virt-manager
    users.users.thobson.extraGroups = ["libvirtd"];


    # oneshot based off https://github.com/sej7278/virt-installs/blob/master/win10.sh

    # https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
    # 
    # install = ''
    # virt-install \
    # --virt-type kvm \
    # --name=win10-headless \
    # --os-variant=win10 \
    # --vcpus 4,sockets=1,cores=4,threads=1 \
    # --cpu host-passthrough \
    # --memory 8192 \
    # --features smm.state=on,kvm_hidden=on,hyperv_relaxed=on,hyperv_vapic=on,hyperv_spinlocks=on,hyperv_spinlocks_retries=8191 \
    # --clock hypervclock_present=yes \
    # --disk path=win10.qcow2,size=32,format=qcow2,sparse=true,bus=scsi,cache=writethrough,discard=unmap,io=threads  \
    # --controller type=scsi,model=virtio-scsi \
    # --graphics spice \
    # --video model=qxl,vgamem=32768,ram=131072,vram=131072,heads=1 \
    # --channel spicevmc,target_type=virtio,name=com.redhat.spice.0 \
    # --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    # --network bridge=virbr0,model=virtio \
    # --input type=tablet,bus=virtio \
    # --metadata title='Win10' \
    # --disk virtio-win-0.1.229.iso,device=cdrom \
    # --cdrom Win10_22H2_English_x64v1.iso \
    # --boot menu=on
    # '';

}
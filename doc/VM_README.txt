===========================================
This README is about how to configure 
and play the vm image SciFlo Appliance.vmdk
===========================================


================
install vmplayer
================
On CentOS
. download VMware-Player-5.0.0-812388.x86_64.txt
. chmod +x VMware-Player-5.0.0-812388.x86_64.txt
. sudo ./VMware-Player-5.0.0-812388.x86_64.txt
  /usr/bin/vmplayer will be installed.
. Remember to use
  sudo /etc/init.d/vmware restart
  to restart the vmware daemon, in addition to
  replaying the vm image. This helps!


=============
play vm image
=============
. vmplayer SciFlo\ Appliance.vmx (note: not the .vmdk file)
  needs X11 display set
. agree to upgrade the vmware tools and give the password
  on host (with sudo or root)
. log in to vm (refer to README.txt for user id and passwd)
. ifconfig to find out the ip of vm (e.g., 192.168.94.128)


=========================
configure port forwarding
for remote login
=========================
. quite vm
. give alias to the vm's ip
  add this line to /etc/hosts
  192.168.94.128   cmac-appliance
. edit /etc/vmware/vmnet8/nat/nat.conf
  and add lines like for port forwarding:
  8080 = cmac-appliance:80
  8022 = cmac-appliance:22
. or, to get the port setting, can copy
  /home/leipan/nat.conf
  to
  /etc/vmware/vmnet8/nat/nat.conf
. restart vm daemon
  sudo /etc/init.d/vmware restart
. edit /etc/sysconfig/iptables
  to open ports 8080, 8022
  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8022 -j ACCEPT
. play the vm
. from remote,
  ssh -p 8022 usr@hhost
  example:
  ssh -p 8022 sflops@oscar1.jpl.nasa.gov


====================================
install vmware tools in an ubuntu vm
====================================
assume there is only command line interface
. play the vm and login as sudo user
. sudo mkdir /mnt/cdrom
. sudo mount /dev/cdrom /mnt/cdrom
. ls /mnt/cdrom to verify the mount
. tar xzvf /mnt/cdrom/VMwareTools-x.x.x-xxxx.tar.gz -C /tmp/
. cd /tmp/vmware-tools-distrib/; sudo ./vmware-install.pl -d
. sudo reboot


=========================
configure shared folder
=========================
. Virtual Machine Settings -> Options -> Shared Folders -> Always enabled
  (name: export, Host Path: /export)

. On guest vm, sudo vi /etc/fstab, and append this line:
.host:/export/data1    /export/data1    vmhgfs    user    0    0

. Or, it can be done manually by:
  sudo mount -t vmhgfs .host:/export/data1 /export/data1


===========================
which virtual image to use?
===========================
. on cmacws.jpl.nasa.gov
  /home/leipan/cmac-vm/latest_copy_of_vm
. on cmacws2.jpl.nasa.gov
  /home/leipan/cmac-vm/cmacws2_deployment
. on cmacws3.jpl.nasa.gov
  /home/leipan/cmac-vm/cmacws3_deployment
. on cmacws4.jpl.nasa.gov
  /home/leipan/cmac-vm/cmacws4_deployment


===========================
configure web portal inside virtual machine
===========================
. vi /etc/apache2/sites-available/default
  to set, for example:
  DocumentRoot /home/svc/cmac/trunk/web_portal/



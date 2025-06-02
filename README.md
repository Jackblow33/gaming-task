# Debian 13 sid Gnome gaming task <br>
auto-install.sh & extras.sh are scripts to install and configure the bare minimum to have a fuctionnal gnome desktop environement to build on top. This Debian installation can perform as good as any other gaming oriented distro's I guess... It have been tested against CachyOS and Ubuntu 25.04 and in both case this installer score a tad bit better using a custom TKG kernel 6.14+ (not included). As of now, you have to compile your own kernel, but a kernel install script is provided as example (/gaming-task/modules/dropbox-kernel-0.3.sh) and could be use to integrate your own kernel into the auto-install.sh script. Simply use the TKG compilation script to compile easily your kernel if you want the best possible performance with this installer.
# 1- Download mini.iso

https://d-i.debian.org/daily-images/amd64/daily/netboot/ <br>
<br>
git clone https://github.com/jackblow33/gaming-task.git <br>
cd gaming-task <br>
chmod +x *.sh <br>
./auto-install.sh <br>

##
After first boot <br>
Execute /gaming-task/extras.sh <br>


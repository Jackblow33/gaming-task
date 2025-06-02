# Debian 13 sid gnome-gaming-task <br>
The `auto-install.sh` and `extras.sh` scripts are designed to install and configure the bare minimum to have a functional GNOME desktop environment, which can be built upon. This Debian installation can perform as well as any other gaming-oriented distribution, based on testing against CachyOS and Ubuntu 25.04. In both cases, this installer scored slightly better when using a custom TKG kernel 6.14+ (not included).<br>

At the moment, you have to optionally compile your own kernel, but a kernel install script is provided as an example (`/gaming-task/modules/dropbox-kernel-0.3.sh`) and could be used to integrate your own kernel into the `auto-install.sh` script. You can use the TKG compilation script to easily compile your kernel if you want the best possible performance with this installer.<br>

This is not ready for official release but it works perfectly fine and saves a lot of time if you know how to use it. Hundreds of hours have been devoted to coding and testing. Only a small percentage of codes have been add to this repo. More to come sooner or later...  <br>

It is optimize for Nvidia graphics cards and the script gonna check if an Nvidia gpu is detected and gonna offer you to install a recent proprietary driver directly downloaded from Nvidia. The script gonna list all the modification his gonna do also. <br>

That doesn't mean that this is not working with AMD gpu. Just not throughly tested. It works obo. <br>

This is not meant to become an other distro but a Debian tasksel task...<br>
BTW this project have started with kde in mind so almost everything is ready to build kde-gaming-task.
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


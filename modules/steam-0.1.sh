#!/bin/bash

# Debian Steam install
# steam-0.1.sh
# 2025-05-30

install_steam() {
sudo dpkg --add-architecture i386 && sudo apt update
sudo apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb -P /home/$USER/Downloads || error_handler
sudo mkdir -p ~/.local/share/Steam
sudo chown -R $USER:$USER ~/.local/share/Steam
# sudo apt --fix-broken install
sudo apt install libutempter0  xterm
sudo dpkg -i /home/$USER/Downloads/steam.deb || error_handler
}

# mangohud
##	sudo apt install -y gcc g++ gcc-multilib g++-multilib ninja-build meson python3-mako python3-setuptools python3-wheel pkg-config mesa-common-dev libx11-dev libxnvctrl-dev libdbus-1-dev python3-numpy python3-matplotlib libxkbcommon-dev libxkbcommon-dev:i386 libwayland-dev libwayland-dev:i386
build_mangohud() {
sudo apt install -y libxnvctrl0
cd /home/$USER/Downloads
git clone https://github.com/flightlessmango/MangoHud.git
cd MangoHud
./build.sh build
./build.sh install
# To tar up the resulting binaries into a package and create a release tar with installer script, execute:
#./build.sh package release
#./build.sh build package release # Or combine
}

# Goverlay compilation
build_goverlay() {
sudo apt-get install -y libqt6pas-dev vulkan-tools mesa-utils vkbasalt
sudo apt install -y fpc lazarus-ide
cd /home/$USER/Downloads
git clone https://github.com/benjamimgois/goverlay.git
cd goverlay
sudo make
sudo chmod +x start_goverlay.sh
sudo make install
sudo apt purge -y fpc lazarus-ide
sudo apt autoremove -y
}

# For Steam games, you can add this as a launch option: mangohud %command%
# Or alternatively, add MANGOHUD=1 to your shell profile (Vulkan only).

# Proton GE compilation    https://github.com/GloriousEggroll/proton-ge-custom?tab=readme-ov-file#building
build_GE_proton() {
BUILD="GE-Proton9-27"
# build dependency podman
sudo apt-get update
sudo apt-get install podman   # podman --version = podman version 5.4.2
cd /home/$USER
git clone --recurse-submodules http://github.com/gloriouseggroll/proton-ge-custom

# Applying patches
cd proton-ge-custom
./patches/protonprep-valve-staging.sh &> patchlog.txt
# In the main proton-ge-custom directory.
# Open patchlog.txt and search for "fail" to make sure no patch failures occured. An easy way to do this is like so:
grep -i fail patchlog.txt
grep -i error patchlog.txt 

mkdir build && cd build
../configure.sh --build-name=$BUILD
# make redist &> log
make redist
# Build will be placed within the build directory as $BUILD.tar.gz
tar -xzf $BUILD.tar.gz
cd $BUILD
# ??? #    ./install.sh
proton-ge-custom --version
]

# Enabling
# Right click any game in Steam and click Properties.
# At the bottom of the Compatibility tab, Check Force the use of a specific Steam Play compatibility tool, then select the desired Proton version.
# Launch the game.


# Lutris
install_lutris() {
echo "deb [signed-by=/etc/apt/keyrings/lutris.gpg] https://download.opensuse.org/repositories/home:/strycore/Debian_12/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list > /dev/null
wget -q -O- https://download.opensuse.org/repositories/home:/strycore/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/lutris.gpg > /dev/null
sudo apt update
sudo apt install lutris
sudo mkdir -p ~/.local/share/lutris
sudo mkdir -p ~/.local/share/icons
sudo chown -R $USER:$USER ~/.local/share/lutris
sudo chown -R $USER:$USER ~/.local/share/icons
}

# Gamescope compilation
build_gamescope() {
sudo apt-get update
sudo apt-get install git meson ninja-build
git clone https://github.com/ValveSoftware/gamescope.git
cd gamescope
meson setup build/
ninja -C build/
sudo ninja -C build/ install
}

# Heroic game launcher
# HERO_VER="2.16.1"
install_heroic() {
wget https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.16.1/Heroic-2.16.1-linux-amd64.deb
sudo dpkg -i Heroic_*_amd64.deb
}



# Main script execution
install_steam
build_mangohud
build_goverlay











# Might be usefull info down the road:
# Concerning warning message "pv-adverb: W:  
# check if the locale is correctly set up by running the following command:
# LC_ALL=en_US.UTF-8 perl -e ''
# If the locale is correctly set up, the command should exit with status 0 and no output.
# Else select en_US.UTF-8 through: sudo dpkg-reconfigure locales 




#sudo apt install steam-libs-i386
#sudo mkdir -p ~/.local/share/Steam
#sudo chown -R $USER:$USER ~/.local/share/Steam

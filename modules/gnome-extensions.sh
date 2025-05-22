#!/bin/bash

# extensions.sh

# Enable extensions and customize
# ENABLE_EXTENSIONS=true
# If ENABLE_EXTENSIONS is set to false, the script will install the extensions without customizing and not enabling them.
# Could be enable manually after the install via the gnome-shell-extension-manager app.

# Freon extension
# FREON_EXTENSION_NAME="freon@UshakovVasilii_Github.yahoo.com"

timer_start() {
    BEGIN=$(date +%s)
}

timer_stop() {
    NOW=$(date +%s)
    DIFF=$((NOW - BEGIN))
    MINS=$((DIFF / 60))
    SECS=$((DIFF % 60))
    echo "Time elapsed: $MINS:$(printf %02d $SECS)"
}

# Handle errors
handle_error() {
    echo "Error occurred in the script. Exiting."
    exit 1
}

# Root_check
root_check() {
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi
}


dependencies() {
apt install -y gnome-shell-extension-prefs lm-sensors sassc make gettext || handle_error
}




gnome_check() {
    # Check if the user is running GNOME
    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
        echo "This script is designed for GNOME desktop environment."
        read -p "Press Enter to exit and return to the main menu..."
        handle_error
    fi
}



dash_to_panel() {
PANEL_EXTENSION_NAME="dash-to-panel@jderose9.github.com"
PANEL_EXTENSION_DIR="/home/$USR/.local/share/gnome-shell/extensions/$PANEL_EXTENSION_NAME"
    if [ -d "$PANEL_EXTENSION_DIR" ]; then
        echo "Dash to Panel extension is already installed."
    else
        echo "Installing Dash to Panel extension..."
        mkdir -p "$PANEL_EXTENSION_DIR" || handle_error
        git clone https://github.com/home-sweet-gnome/dash-to-panel.git "$PANEL_EXTENSION_DIR" || handle_error
        cd "$PANEL_EXTENSION_DIR" || handle_error
        make || handle_error
        make install || handle_error
        gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' || handle_error
        echo "Dash to Panel extension installed."
    fi


}



dash_to_dock() {
DOCK_EXTENSION_NAME="dash-to-dock@micxgx.gmail.com"
DOCK_EXTENSION_DIR="/home/$USR/.local/share/gnome-shell/extensions/$DOCK_EXTENSION_NAME"
    if [ -d "$DOCK_EXTENSION_DIR" ]; then
        echo "Dash to Dock extension is already installed."
    else
        echo "Installing Dash to Dock extension..."
        mkdir -p "$DOCK_EXTENSION_DIR" || handle_error
        git clone https://github.com/micheleg/dash-to-dock.git "$DOCK_EXTENSION_DIR" || handle_error
        cd "$DOCK_EXTENSION_DIR" || handle_error
        make || handle_error
        make install || handle_error
        gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' || handle_error
        echo "Dash to Dock extension installed."
    fi
}

freon() {
    echo "Setting up lm-sensors..."
    sensors-detect --auto || handle_error
    echo "Installing freon gnome-shell-extension"
    apt install -y gnome-shell-extension-freon || handle_error
    echo "freon gnome-shell-extension installed"

}


# Main script execution
root_check
timer_start
dependencies
#gnome_check
#dash_to_panel
dash_to_dock
freon
timer_stop

#!/bin/bash
set -euo pipefail #safety line

#gosetup.sh - written by bpm
#Generated by mkscript: 2017-10-17 10:17:16 BST
#VERSION=0.2.2

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [ ! -x "$(which whiptail)" ]; then
    echo "Couldn't find whiptail!"
    exit
fi
if [ ! -x "$(which git)" ]; then
    echo "Couldn't find git!"
    exit
fi

tmpdir="/tmp"
install="/usr/local"
binaries="/usr/local/bin"

function goinstall() {
    if [ -x "$install/go-"$1"/bin/go" ]; then
        whiptail --title "Skipping $1" --msgbox "Found existing Go $1 installation - skipping" 15 60
        return
    fi

    mkdir -p $install/go-"$1"
    wget -c -P $tmpdir https://storage.googleapis.com/golang/go"$1".linux-amd64.tar.gz
    tar x --keep-newer-files -f $tmpdir/go"$1".linux-amd64.tar.gz -C "$install"/go-"$1" --strip-components=1
    rm $tmpdir/go"$1".linux-amd64.tar.gz

    echo "Installed Go Version $1 to $install/go-$1"
    #whiptail --title "Success" --msgbox "Installed Go Version $1 to $install/go-$1" 15 60
}

##main program starts here

whiptail --title "Welcome" --yesno "This program downloads and installs Go binaries, and symlinks them.\n\nContinue?" 15 60
if [ "$?" != "0" ]; then exit; fi

if [ $TERM="xterm" ]; then #whiptail has a bug here
    clear
    echo "Retrieving list of Go versions - please wait."
else
    whiptail --title "Scraping" --infobox "Retrieving list of Go versions - please wait." 15 60
fi
goversions=$( git ls-remote -t https://go.googlesource.com/go | cut -d/ -f3 | grep -oP 'go\K\d(\.\d)+' | sort -rn | uniq )

list=""
for item in $goversions; do
    list+="$item OFF "
done

selected="$(whiptail --title "Versions"  --checklist --noitem --separate-output\
    "Select versions to install" 25 30 18 \
    $list \
    3>&1 1>&2 2>&3)"

if [ "$?" != "0" ]; then exit; fi

#install="$(whiptail --title "Install Location" --inputbox "Where would you like to install the go versions?" 15 60 \
#    "/usr/local" \
#    3>&1 1>&2 2>&3)"
#if [ "$?" != "0" ]; then exit; fi

list=""
for choice in $selected; do
    goinstall "$choice"
    list+="$choice notused "
done

chosen="$(whiptail --title "Version" --menu --noitem "Select version to symlink" 15 60 6 \
    $list \
    3>&1 1>&2 2>&3)" 

#binaries="$(whiptail --title "Binary Location" --menu "Where would you like to symlink the binaries?" 15 30 4 \
#    "1" "/usr/local/bin" \
#    "2" "/usr/bin" \
#    "3" "/bin" \
#    "4" "$HOME/bin"  \
#    3>&1 1>&2 2>&3)"

if [ -x "$binaries"/go ]; then
    whiptail --title "Success" --yesno "Found existing installation at $binaries/go\n\nOverwrite?" 15 60
    if [ "$?" != "0" ]; then exit; fi
fi

ln -sf "$install"/go-"$chosen" "$install"/go
ln -sf "$install"/go/bin/go "$install"/go/bin/godoc "$install"/go/bin/gofmt "$binaries"

if [ -x "$binaries"/go ]; then
    whiptail --title "Success" --msgbox "Symlinked $binaries/go to Go Version $chosen" 15 60
else
    whiptail --title "Error!" --msgbox "Symlink Failed!" 15 60
fi

##EOF##

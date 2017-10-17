#!/bin/bash
set -euo pipefail #safety line

#gosetup.sh - written by bpm
#Generated by mkscript: 2017-10-17 10:17:16 BST
#VERSION=0.2.1

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
#install="$(whiptail --title "Install Location" --inputbox "Where would you like to install the go versions?" 15 60 \
#    "/usr/local" \
#    3>&1 1>&2 2>&3)"
#if [ "$?" != "0" ]; then exit; fi

goversions=$( git ls-remote -t https://go.googlesource.com/go | cut -d/ -f3 | grep -oP 'go\K\d(\.\d)+' | sort -rn | uniq )

function goinstall() {
    mkdir -p $install/go-"$1"
    wget -P $tmpdir https://storage.googleapis.com/golang/go"$1".linux-amd64.tar.gz
    tar xvf $tmpdir/go"$1".linux-amd64.tar.gz -C "$install"/go-"$1" --strip-components=1
    rm $tmpdir/go"$1".linux-amd64.tar.gz
    #whiptail --title "Success" --msgbox "Installed Go Version $1 to $install/go-$1" 15 30 
}

list=""
for item in $goversions; do
    list+="$item OFF "
done

selected="$(whiptail --title "Versions"  --checklist --noitem --separate-output\
    "Select versions to install" 15 30 8 \
    "$list" \
    3>&1 1>&2 2>&3)" 

if [ "$?" != "0" ]; then exit; fi

list=""
for choice in $selected; do
    goinstall "$choice"
    list+="$choice $choice "
done

final="$(whiptail --title "Version" --menu --noitem "Select version to symlink" 15 30 6 \
    "$list" \
    3>&1 1>&2 2>&3)" 

binaries="/usr/local/bin"
#binaries="$(whiptail --title "Binary Location" --menu "Where would you like to symlink the binaries?" 15 30 4 \
#    "1" "/usr/local/bin" \
#    "2" "/usr/bin" \
#    "3" "/bin" \
#    "4" "$HOME/bin"  \
#    3>&1 1>&2 2>&3)"

echo ln -s "$install"/go-"$final" "$install"/go
echo ln -s "$install"/go/bin/go "$install"/go/bin/godoc "$install"/go/bin/gofmt "$binaries"

if [ -x "$binaries"/go ]; then
    whiptail --title "Success" --msgbox "Symlinked $binaries/go to Go Version $final" 15 30 
else
    whiptail --title "Error!" --msgbox "Symlink Failed!" 15 30 
fi
##EOF##

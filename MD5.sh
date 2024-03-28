#!/bin/bash

# Author : Dmytro Dzhusov ( dima.dgusov.gmail.com )
# Created On : 13.05.2023
# Last Modified By : Dmytro Dzhusov ( dima.dgusov.gmail.com )
# Last Modified On : 15.05.2023
# Version : 1.05
#
# Description : Script use MD5 sums of files to compare if they are the same
# or MD5 sums of files in the folder to chech if folders have the same content
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

# function to get MD5 sum of file
md5sum_file() {
    local file="$1"
    md5sum "$file" | awk '{ print $1 }'
}

# function to get MD5 sum of directory
md5sum_dir() {
    local dir="$1"
    md5sum $(find "$dir" -type f -print0 | sort -z | xargs -0) | awk '{ print $1 }'
}

# function to compare two files
compare_files() {
    local file1="$1"
    local file2="$2"
    local md5sum1="$(md5sum_file "$file1")"
    local md5sum2="$(md5sum_file "$file2")"
    if [[ "$md5sum1" == "$md5sum2" ]]; then
        zenity --info --text="Files $file1 and $file2 are the same"
    else
        zenity --info --text="Files $file1 and $file2 are different"
    fi
}

#function to compare two directories
compare_directories() {
    local dir1="$1"
    local dir2="$2"
    local md5sum1="$(md5sum_dir "$dir1")"
    local md5sum2="$(md5sum_dir "$dir2")"
    if [[ "$md5sum1" == "$md5sum2" ]]; then
        zenity --info --text="Directories $dir1 and $dir2 are the same"
    else
        zenity --info --text="Directories $dir1 and $dir2 are different"
    fi
}
# main loop of programm
compare() {
    while true; do
         option=$(zenity --list --text "Choose type of comparation" --column "" "Files" "Directories")
    case "$option" in
    "Files")
            # files comparation
            files=""
            while [ $(echo $files | wc -w) -lt 2 ]; do
                new_files=$(zenity --file-selection --title="Choose two files" --multiple --separator=' ')
                files="$files $new_files"
            done
            if [ $(echo $files | wc -w) -eq 2 ]; then
                compare_files $files
            else
                zenity --error --text="You need to choose exactly two files"
            fi
            ;;
        "Directories")
            # directories comparation
            dirs=""
            while [ $(echo $dirs | wc -w) -lt 2 ]; do
                new_dirs=$(zenity --file-selection --title="Choose two directories" --multiple --separator=' ' --directory)
                dirs="$dirs $new_dirs"
            done
            if [ $(echo $dirs | wc -w) -eq 2 ]; then
                compare_directories $dirs
            else
                zenity --error --text="You need to choose exactly two directories"
            fi
            ;;
        *)
            exit 0
            ;;
     esac
    done
}

# options of programm
while getopts hvf OPT; do

    case $OPT in
         h) echo "Programm check if two files or two directories are the same";;
         v) echo "Vesion 1.05";;
         f) compare;;
         *) echo "Unknown option";;

    esac

done

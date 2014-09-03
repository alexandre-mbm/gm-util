#!/bin/bash
#
# Copyright (c) 2014 Alexandre Magno <alexandre.mbm@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

GM_DIR=$(find ~/.mozilla/firefox/ | grep 'gm_scripts$')

function print_dir() {
    echo $GM_DIR
}

function create_link() {
    ln -s $GM_DIR ~/
}

function print_help() {
    echo
    echo " Syntax:  gm-util.sh [dir|link|get FILE| set FILE|diff FILE]"
    echo
    echo "   dir - Print gm_scripts absolute path "
    echo "  link - Create 'gm_scripts' symbolic link at HOME"
    echo "   get - Copy the browser's file to the current directory"
    echo "   set - Transform this file in the browser's file"
    echo "  diff - Do diff between file and the browser's file"
    echo
}

function name_of_file() {
    echo "$1" | sed -e "s/^.*\///g" -e "s/^\(.*\)\.user\.js$/\1/g"
}

function name_of_dir() {
    grep '^// @name ' "$1" | 
        sed \
            -e 's/^\/\/ @name[ \t]*//' \
            -e 's/[ \t]*$//' \
            -e 's/ /_/g' \
            -e "s/'//g"
}

function path_of_browser_file_for() {
    echo "$GM_DIR/"$(name_of_dir "$1")"/"$(name_of_file "$1")".user.js"
}

function diff_file() {
    diff -upN "$1" "$2" | colordiff  | less -R  # dependency
}

function equal_files() {
    #sum1=$(md5sum "$1" | cut -d" " -f1)
    #sum2=$(md5sum "$2" | cut -d" " -f1)
    #test $sum1 == $sum2
    diff_content=$(diff "$1" "$2")
    test -z "$diff_content"
}

function yes_or_no() { # http://stackoverflow.com/a/226724
    words="$1"
    while true; do
        read -p  "$words (yes|no) " yn
        case $yn in
            [Yy]|[Yy][Ee][Ss]) return 0; break;;
            [Nn]|[Nn][Oo]) return 1; break;;
            *) echo "Please answer yes or no.";;
        esac
    done
}

function copy_file_if_appropriate() {
    orig="$1"
    dest="$2"
    equal_files "$orig" "$dest" && echo "Equal files. No action." || (
        yes_or_no "Different files. Diff?" && diff_file "$orig" "$dest"
        yes_or_no "Continue and get the browser's file?" && cp "$orig" "$dest"
        return 0
    )    
}

function exits_if_no_file() {
    msg="Error: the browser's file does not exist"
    test -e "$1" || (echo "$msg" && return 1)
    test $? -eq 1 && exit 1
}

function fix_uFEFF() {  # character <U+FEFF> "Copy clipboard" (issue #5)
    sed -i "s/"$(echo -ne '\uFEFF')"//g" "$1"
}

function set_file() {
    orig="$1"
    dest=$(path_of_browser_file_for "$orig")
    exits_if_no_file "$dest"
    fix_uFEFF "$dest"
    copy_file_if_appropriate "$orig" "$dest"
}

function get_file() {
    dest="$1"
    orig=$(path_of_browser_file_for "$dest")
    exits_if_no_file "$orig"
    fix_uFEFF "$orig"
    copy_file_if_appropriate "$orig" "$dest"
}

function do_diff() {
    file="$1"
    target=$(path_of_browser_file_for "$file")
    exits_if_no_file "$target"
    fix_uFEFF "$target"
    diff_file "$file" "$target"
}

case $1 in
    dir)
        print_dir
        ;;
    link)
        create_link
        ;;
    get)
        test $2 && get_file "$2" || print_help
        ;;
    set)
        test $2 && set_file "$2" || print_help
        ;;
    diff)
        test $2 && do_diff "$2" || print_help
        ;;
    *)
        print_help
        ;;
esac

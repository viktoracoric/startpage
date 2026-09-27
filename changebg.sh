#!/bin/sh
PATH_DIR="/path/to/dir"

randPic=$(find "$PATH_DIR/pix" -type f | shuf -n1)
sed -i "s|.*ChangeWallpaper.*|            background-image: url('$randPic'); /* ChangeWallpaper */|" "$PATH_DIR/startpage.html"

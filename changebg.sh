#!/bin/sh
STARTPAGE_DIR="/path/to/dir"

randPic=$(find "$STARTPAGE_DIR/pix" -type f | shuf -n1)
sed -i "s|.*ChangeWallpaper.*|            background-image: url('$randPic'); /* ChangeWallpaper */|" "$STARTPAGE_DIR/startpage.html"

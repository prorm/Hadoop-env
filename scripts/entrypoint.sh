#!/bin/bash
# Container start: name the Hadoop folder after the student's USN, then keep running.
set -e
. /etc/bigdata-lab.env
cd "$HOME"

# The folder that currently holds Hadoop (USN on first start).
current=""
for d in "$HOME"/*/; do
    d="${d%/}"
    if [ -d "$d/$LAB_HADOOP_DIR" ]; then
        current="$(basename "$d")"
        break
    fi
done
[ -z "$current" ] && current="$(cat "$HOME/.lab_usn" 2>/dev/null || echo USN)"

wanted="${USN:-$current}"
if [ "$wanted" != "$current" ] && [ -d "$HOME/$current" ] && [ ! -e "$HOME/$wanted" ]; then
    mv "$HOME/$current" "$HOME/$wanted"
    current="$wanted"
fi
echo "$current" > "$HOME/.lab_usn"

# Folder shared with the laptop (Linux hosts may create it as root).
if [ -d "$HOME/shared" ] && [ ! -w "$HOME/shared" ]; then
    sudo chmod a+rwx "$HOME/shared" 2>/dev/null || true
fi

exec "$@"

#! /bin/sh
draft_path=$1
if [[ -f $draft_path ]]; then
    echo "[INFO] find $draft_path"
    draft_file=$(basename $draft_path)
    date_string=$(date +"%Y-%m-%d")
    post_file="$date_string-$draft_file"
    echo "[INFO] mv $draft_path _posts/$post_file"
    mv "$draft_path" "_posts/$post_file"
else
    echo "[ERROR] $draft_path not found!"
    exit 1
fi

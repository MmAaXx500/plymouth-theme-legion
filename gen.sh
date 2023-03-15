#!/bin/bash

set -e

RENDERDIR=render
TARGETDIR=legion

FRAME_THROBBER_START=1
FRAME_THROBBER_END=60
THROBBER_PFX=throbber-

FRAME_STARTUP_ANIM_START=61
FRAME_STARTUP_ANIM_END=150
STARTUP_ANIM_PFX=startup-animation-

FRAME_SHUTDOWN_ANIM_START=151
FRAME_SHUTDOWN_ANIM_END=240
SHUTDOWN_ANIM_PFX=shutdown-animation-

cd $RENDERDIR
RENDERDIR_LIST=(*.png)
cd -

for file in "${RENDERDIR_LIST[@]}"
do
  filenum=${file%.png}
  filenum=$((10#$filenum))

  if [ $FRAME_THROBBER_START -le "$filenum" ] && [ $FRAME_THROBBER_END -ge "$filenum" ]
  then
    target_filenum=$((filenum - FRAME_THROBBER_START + 1))
    target_filenum=$(printf "%04d" $target_filenum)
    target_filename="${THROBBER_PFX}${target_filenum}.png"
  elif [ $FRAME_STARTUP_ANIM_START -le "$filenum" ] && [ $FRAME_STARTUP_ANIM_END -ge "$filenum" ]
  then
    target_filenum=$((filenum - FRAME_STARTUP_ANIM_START + 1))
    target_filenum=$(printf "%04d" $target_filenum)
    target_filename="${STARTUP_ANIM_PFX}${target_filenum}.png"
  elif [ $FRAME_SHUTDOWN_ANIM_START -le "$filenum" ] && [ $FRAME_SHUTDOWN_ANIM_END -ge "$filenum" ]
  then
    target_filenum=$((filenum - FRAME_SHUTDOWN_ANIM_START + 1))
    target_filenum=$(printf "%04d" $target_filenum)
    target_filename="${SHUTDOWN_ANIM_PFX}${target_filenum}.png"
  else
    echo "Unknown file: $file"
    exit 1
  fi

  target="$TARGETDIR/$target_filename"

  magick "$RENDERDIR/$file" -background black -alpha background -quality 00 "$target"
  optipng --quiet "$target"

  echo "Saved $file to $target"
done

magick -delay 1x30 $TARGETDIR/$THROBBER_PFX*.png $TARGETDIR/$STARTUP_ANIM_PFX*.png -background black -alpha remove -gravity center -extent 1280x720 -layers optimize -loop 0 startup.gif

echo "Saved startup.gif"

magick -delay 1x30 $TARGETDIR/$THROBBER_PFX*.png $TARGETDIR/$SHUTDOWN_ANIM_PFX*.png -background black -alpha remove -gravity center -extent 1280x720 -layers optimize -loop 0 shutdown.gif

echo "Saved shutdown.gif"

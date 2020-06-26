#!/bin/bash
# Prepends silence to the beginning of audio files
# Originially written by Chris Brendel for Linux, adapted to OsX by Sandra Auderset
# you have to install grep via brew for this work

### Configuration ###
# Location of directory where audio files are (assuming no subfolders/recursion)
INDIR=/Users/auderset/Desktop/dicsound
# Where you want the new files to go. Must already be created and SHOULD BE DIFFERENT from input folder (files will be overwritten)
OUTDIR=/Users/auderset/Desktop/dicsound/withsilence
# File extension to search for (mp3 or wav are both fine; anything compatible with ffmpeg should be fine)
FILE_EXT=.wav
# How many seconds of silence to add to the beginning 
SILENCE_SECS=1
#####################

# Keep track of sample rate & audio channels from file to file so we can reduce number of new silent audio tracks regenerated
PREV_SAMP_RATE=44.1
PREV_CHANNELS=Mono

declare -i numComplete=0
for file in "$INDIR"/*"$FILE_EXT"; do

    # Determine sample rate & channels for current file so we can create appropriate silent stream
    finfo=$(ffprobe -v quiet -print_format flat -show_streams "$file")
    SAMP_RATE=$(echo $finfo | ggrep -Pio "(?<=streams.stream.0.sample_rate=\")\\d+" -)
    CHANNELS=$(echo $finfo | ggrep -Pio "(?<=streams.stream.0.channels=)\\d+" -)

    # On first run & if rate/channels are different from previous file (unlikely), create new silent audio track to prepose
    if [ "$SAMP_RATE" != "$PREV_SAMP_RATE" ] || [ "$CHANNELS" != "$PREV_CHANNELS" ]; then
        ffmpeg -v quiet -y -f lavfi -i anullsrc=channel_layout="$CHANNELS"c:sample_rate="$SAMP_RATE" -t "$SILENCE_SECS" "$(pwd)/ffmpeg-silence$FILE_EXT"
        PREV_SAMP_RATE=$SAMP_RATE
        PREV_CHANNELS=$CHANNELS
    fi;

    rawFilename=$(echo "$file" | ggrep -Pio "[^/]+\$" -) #

    # Create temp txt file for ffmpeg input (insanity that this is necessary...); should be in tempfs, so should still be fairly fast
    tmpfile="/tmp/$rawFilename.txt"
    echo "file '$(pwd)/ffmpeg-silence$FILE_EXT'" > $tmpfile
    echo "file '$file'" >> $tmpfile

    # Concatenate silent file with source file
    ffmpeg -v quiet -f concat -safe 0 -i $tmpfile -codec copy "$OUTDIR/$rawFilename"

    rm $tmpfile

    echo "Finished '$rawFilename' ($SAMP_RATE Hz, $CHANNELS channels)!"
    numComplete+=1
done;

echo "Added $SILENCE_SECS seconds at the beginning of $numComplete files"

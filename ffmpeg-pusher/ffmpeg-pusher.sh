#!/bin/bash

which ffmpeg

###########################
##### CONFIGURE THESE #####
###########################

# ADD YOUR STREAM KEY HERE:
STREAM_KEY=___my_twitch_stream_key___
# SET YOUR LONGITUDE AND LATITUDE HERE:
COORDS=0,0


trap "exit" INT TERM ERR
trap "kill \$(jobs -p)" EXIT

rm -f /tmp/audiopipe
mkfifo /tmp/audiopipe

# hold that pipe open
((while true; do sleep 1000; done) <>/tmp/audiopipe) &

(
# we take the playlist and separately shuffle the first and seconf halfs
PLAYLIST=$(find /mp3/BeansBlvd -type f | shuf)
sleep 1

while true; do
    while read LINE; do
        if [[ -e "$LINE" ]]; then
            echo "Playing $LINE"
            ffmpeg \
                    -nostdin \
                    -thread_queue_size 2048 \
                    -loglevel warning                   \
                            -re \
                    -i "$LINE" \
                    -f s16le \
                    -acodec pcm_s16le \
                    pipe:1 > /tmp/audiopipe
        else
            echo "$LINE not found... skipping/removing..."
            PLAYLIST=$(echo "$PLAYLIST" | grep -v "^${LINE}$")
        fi
    done < <(echo "${PLAYLIST}")

    echo "Shuffling playlist..."

    LINECOUNT=$(echo "$PLAYLIST" | wc -l)
    FIRSTHALFCOUNT=$((LINECOUNT / 2))
    FIRSTHALF=$(echo "${PLAYLIST}" | head -${FIRSTHALFCOUNT} | shuf)
    SECONDHALF=$(echo "${PLAYLIST}" | tail -$((LINECOUNT - FIRSTHALFCOUNT)) | shuf)
    PLAYLIST=$(echo -e "${FIRSTHALF}\n${SECONDHALF}")

    # add any new files to the head of the playlist
    NEW=$(grep -v -f <(echo "$PLAYLIST" | sort | sed -e 's/^/^/' -e 's/$/$/') <(find /mp3/BeansBlvd -type f) | shuf)
    if [[ -n $NEW ]]; then
        PLAYLIST=$(echo -e "${NEW}\n${PLAYLIST}")
    fi
done
) &
MP3PID=$?

# set a default broken weather png
curl wttr.in/${COORDS}.png?0Qn -o /weather.png
sleep 0.25

# loop that retrieves the weather image
(
while true; do
    curl -s wttr.in/${COORDS}.png?0Qn -o /tmp/weather.png
    convert \
            /tmp/weather.png \
            -transparent '#000000' \
            \( \
                +clone -background black -shadow 100x1+0+0 \
                -channel A -level 0,25% +channel \
            \) \
            +swap \
            -background none \
            -layers merge \
            +repage \
            /tmp/weather-transparent.png

    cat /tmp/weather-transparent.png > /weather.png
    sleep 600
done
)&



# WHAT IS RUNNING RIGHT NOW:
ffmpeg \
    -nostdin \
    -loglevel warning                   \
    -channel_layout stereo              \
    -thread_queue_size 2048             \
    -use_wallclock_as_timestamps 1      \
    -stream_loop -1                     \
    -f s16le                            \
    -i /tmp/audiopipe                   \
    -use_wallclock_as_timestamps 1      \
    -i http://10.1.1.52:8084            \
    -use_wallclock_as_timestamps 1      \
    -i http://10.1.1.52:8083            \
    -use_wallclock_as_timestamps 1      \
    -i http://10.1.1.52:8082            \
    -re                                 \
    -f image2                           \
    -stream_loop -1                     \
    -framerate 1                        \
    -i /weather.png                     \
    -filter_complex "
        nullsrc=size=1280x480,zmq [background];
        [1:v][2:v][3:v]        streamselect@left=inputs=3:map=0         [channel1];
        [1:v][2:v][3:v]        streamselect@right=inputs=3:map=1        [channel2];
        [4:v]                       fps=15                                   [weather];
        [channel1]                  fps=15                                   [left];
        [channel2]                  fps=15                                   [right];
        [background][left]          overlay=shortest=1                       [background+left];
        [background+left][right]    overlay=shortest=1:x=640, format=yuv420p [left+right];
        [left+right][weather]           overlay=shortest=1:x=1032:y=382, format=yuv420p [overlay1]
        " \
    -map "[overlay1]:v" \
    -map "0:a?" \
    -vsync cfr                          \
    -c:v libx264                        \
    -preset ultrafast                   \
    -tune zerolatency                   \
    -b:v 1984k                          \
    -maxrate 1984k                      \
    -bufsize 3968k                      \
    -g 60                               \
    -c:a aac                            \
    -b:a 128k                           \
    -ar 44100                           \
    -f flv                              \
    rtmp://live.twitch.tv/app/${STREAM_KEY}

echo ERROR: exit $?

exit 0


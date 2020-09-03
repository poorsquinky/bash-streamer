# bash-streamer

This is the Docker container we're using for our chicken coop live stream to Twitch.  It uses multiple
input channels to create a split screen, weather overlay, and streaming music, and allows external
processes to switch the cameras.

It assumes there is a `/srv/mp3` directory with the music that will be played, and for now assumes a
subdirectory called `BeansBlvd` (the name of our twitch channel).

## Changing cameras

Cron tasks can switch cameras on the stream at set times of day.  Here's a copy of `/etc/cron.d/cam_auto_change` we're using:

```
SHELL=/bin/bash

# cameras:
# 3 - IR inside
# 2 - IR front
# 1 - standard front
# 0 - standard rear

# evening: IR cameras
#0 20 * * * pi docker exec ffmpeg-pusher bash -c "echo streamselect@left  map 3 | /usr/local/bin/zmqsend"
0 20 * * * pi docker exec ffmpeg-pusher bash -c "echo streamselect@right map 2 | /usr/local/bin/zmqsend"

# daytime: standard cameras
0 6 * * * pi docker exec ffmpeg-pusher bash -c "echo streamselect@left  map 0 | /usr/local/bin/zmqsend"
0 6 * * * pi docker exec ffmpeg-pusher bash -c "echo streamselect@right map 1 | /usr/local/bin/zmqsend"

```

## Known Issues

Lots.  The thing isn't 100% stable.  A lot needs to be done to generalize some of the settings for
normal people to use.  This is enough to get started though.


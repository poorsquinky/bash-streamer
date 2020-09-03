
#FROM ubuntu:20.04
FROM ubuntu:18.04

# TODO FIXME XXX
# - manually compile tools/zmqsend.c
#   gcc -o /zmqsend zmqsend.c -I.. `pkg-config --libs --cflags libzmq libavutil`

## lololol building is for sux
#RUN \
#    apt-get update && \
#    apt-get -y install \
#        ffmpeg \
#        libtheora0 \
#        libvorbis0a \
#        libass9 \
#        libfreetype6 \
#        libgpac4 \
#        libx264-155 \
#        libmp3lame0 \
#        libopus0 \
#        libfdk-aac1 && \
#    apt-get autoclean && \
#    rm -rf /var/lib/apt/lists/*


# build mode is missing these:
# libass9 libfdk-aac1 libmp3lame0 libopus0 libtheora0 libvorbis0a libvorbisenc2 libx264-152 
#    cd /tmp/ffmpeg/sources && \
#    wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master && \
#    unzip fdk-aac.zip && \
#    cd mstorsjo-fdk-aac* && \
#    autoreconf -fiv && \
#    ./configure --disable-shared && \
#    make && \
#    make install && \
#    cd /tmp && \
#    rm -rf /tmp/ffmpeg/sources/*fdk-aac* && \

# FIXME: need to remove the build-dep for libzmq3
# FIXME: and all of the other shit I installed

# shamelessly stolen from https://gist.github.com/thenadz/c2791d74a9ec47e014a1
# this build is a beast.  fear it.
RUN \
    apt-get update && \
    apt-get -y -u dist-upgrade && \
    apt-get -y install software-properties-common && \
    add-apt-repository universe && \
    sed -i -e 's/^# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install \
      wget mercurial build-essential autoconf automake libtool yasm pkg-config texi2html cmake unzip devscripts \
      libx264-dev libx264-152 \
      libmp3lame-dev libmp3lame0 \
      libopus-dev libopus0 \
      libfdk-aac-dev libfdk-aac1 \
      libvorbis-dev libvorbis0a libvorbisenc2 \
      zlib1g-dev zlib1g \
      libass-dev libass9 \
      libfreetype6-dev libfreetype6 \
      libgpac-dev libgpac4 \
      libtheora-dev libtheora0 \
      libvpx-dev libvpx5 \
      libx265-dev libx265-146 \
      libczmq4 libczmq-dev \
      libasound2-dev libasound2 &&\
    mkdir -p /tmp/ffmpeg/sources /tmp/ffmpeg/build && \
    cd /tmp/ffmpeg/sources && \
    echo "=====BUILD DEP=====" && \
    apt-get -y build-dep libzmq3-dev && \
    echo "=====SOURCE=====" && \
    apt-get source libzmq3-dev && \
    cd zeromq3-4.2.5 && \
    echo "=====BUILDPACKAGE=====" && \
    dpkg-buildpackage -D && \
    cd .. && \
    dpkg -i libzmq3-dev_4.2.5-1ubuntu0.2_armhf.deb libzmq5_4.2.5-1ubuntu0.2_armhf.deb && \
    cd /tmp/ffmpeg/sources && \
    wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjf ffmpeg-snapshot.tar.bz2 && \
    cd /tmp/ffmpeg/sources/ffmpeg && \
    PKG_CONFIG_PATH="/tmp/ffmpeg/build/lib/pkgconfig" ./configure \
        --pkg-config-flags="--static" \
        --enable-gpl \
        --enable-alsa \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libzmq \
        --enable-nonfree \
        --disable-doc && \
    PATH="/tmp/bin:$PATH" make && \
    PATH="/tmp/bin:$PATH" make tools/zmqsend && \
    make install && \
    cp tools/zmqsend /usr/local/bin && \
    cp -rv tools /usr/share/ffmpeg-tools && \
    cd /tmp && \
    rm -rf ffmpeg* && \
    hash -r && \
    apt-get -y --purge remove \
        wget mercurial build-essential autoconf automake libfreetype6-dev libgpac-dev libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev yasm cmake unzip libx264-dev libmp3lame-dev libopus-dev libfdk-aac-dev libvpx-dev libx265-dev devscripts && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get -i install \
        curl \
        vim \
        imagemagick \
    && apt-get -u autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*


COPY ffmpeg-pusher.sh /

CMD /ffmpeg-pusher.sh



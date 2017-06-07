FROM debian:jessie

MAINTAINER mike brown <mike@mikebrown.org.uk>

ENV DEBIAN_FRONTEND noninteractive

# Microchip Tools Require i386 Compatability as Dependency

RUN dpkg --add-architecture i386 \
    && apt-get update -yq \
    && apt-get upgrade -yq \
    && apt-get install -yq --no-install-recommends build-essential bzip2 cpio curl python unzip wget \
    libc6:i386 libx11-6:i386 libxext6:i386 libstdc++6:i386 libexpat1:i386 \
    libxext6 libxrender1 libxtst6 libgtk2.0-0 libxslt1.1 libncurses5-dev

# Download and Install XC32 Compiler, Current Version

RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc32.run "http://www.microchip.com/mplabxc32linux" \
    && chmod a+x /tmp/xc32.run \
    && /tmp/xc32.run --mode unattended --unattendedmodeui none \
        --netservername localhost --LicenseType FreeMode --prefix /opt/microchip/xc32 \
    && rm /tmp/xc32.run

ENV PATH $PATH:/opt/microchip/xc32/bin

# Download and Install MPLABX IDE, Current Version

RUN curl -fSL -A "Mozilla/4.0" -o /tmp/mplabx-installer.tar "http://www.microchip.com/mplabx-ide-linux-installer" \
    && tar xf /tmp/mplabx-installer.tar && rm /tmp/mplabx-installer.tar \
    && USER=root ./*-installer.sh --nox11 \
        -- --unattendedmodeui none --mode unattended --installdir /opt/microchip/mplabx \
    && rm ./*-installer.sh

ENV PATH $PATH:/opt/microchip/mplabx/mplab_ide/bin

VOLUME /tmp/.X11-unix

# Container Developer User Ident

RUN useradd user \
    && mkdir -p /home/user/MPLABXProjects \
    && touch /home/user/MPLABXProjects/.directory \
    && chown user:user /home/user/MPLABXProjects

VOLUME /home/user/MPLABXProjects

# Container Tool Version Reports to Build Log

RUN [ -x /opt/microchip/xc32/bin/xc32-gcc ] && xc32-gcc --version


#!/usr/bin/env bash

# data shared between containers goes via these definitions:
DOCKERVOL_ROOT='/dv'

# configure container
IMGID='15'  # range from 2 .. 99; must be unique
export IMAGENAME="rhoerbe/squid${IMGID}"
export CONTAINERNAME="${IMGID}squid"
export CONTAINERUSER="squid${IMGID}"   # group and user to run container
export CONTAINERUID="80${IMGID}"     # gid and uid for CONTAINERUSER
export BUILDARGS="
    --build-arg "USERNAME=$CONTAINERUSER" \
    --build-arg "UID=$CONTAINERUID" \
"
export ENVSETTINGS="
"

export NETWORKSETTINGS="-P"
export VOLROOT="${DOCKERVOL_ROOT}/$CONTAINERNAME"  # container volumes on docker host
export VOLMAPPING="
    -v $VOLROOT/opt/etc/squid:/opt/etc/squid:Z
    -v $VOLROOT/var/log:/var/log/squid:Z
    -v $VOLROOT/var/run:/var/run:Z
    -v $VOLROOT/var/spool/:/var/spool/squid:Z
"
#export VOLMAPPING="%VOLMAPPING "

export STARTCMD='/start.sh'

# first start: create user/group/host directories
if [ $(id -u) -ne 0 ]; then
    sudo="sudo"
fi
if ! id -u $CONTAINERUSER &>/dev/null; then
    if [[ ${OSTYPE//[0-9.]/} == 'darwin' ]]; then
            $sudo sudo dseditgroup -o create -i $CONTAINERUID $CONTAINERUSER
            $sudo dscl . create /Users/$CONTAINERUSER UniqueID $CONTAINERUID
            $sudo dscl . create /Users/$CONTAINERUSER PrimaryGroupID $CONTAINERUID
    else
      source /etc/os-release
      case $ID in
        centos|fedora|rhel)
            $sudo groupadd --non-unique -g $CONTAINERUID $CONTAINERUSER
            $sudo adduser --non-unique -M --gid $CONTAINERUID --comment "" --uid $CONTAINERUID $CONTAINERUSER
            ;;
        debian|ubuntu)
            $sudo groupadd -g $CONTAINERUID $CONTAINERUSER
            $sudo adduser --gid $CONTAINERUID --no-create-home --disabled-password --gecos "" --uid $CONTAINERUID $CONTAINERUSER
            ;;
        *)
            echo "do not know how to add user/group for OS ${OSTYPE} ${NAME}"
            ;;
      esac
    fi
fi

# create dir with given user if not existing, relative to $HOSTVOLROOT
function chkdir {
    dir=$1; user=$2
    $sudo mkdir -p "$VOLROOT/$dir"
    $sudo chown -R $user:$user "$VOLROOT/$dir"
}

chkdir opt/etc/squid $CONTAINERUSER
chkdir var/log $CONTAINERUSER
chkdir var/run $CONTAINERUSER
chkdir var/spool $CONTAINERUSER

#!/bin/bash

# Colors definition
NC='\033[0m' # No Color
WHITE='\033[1;37m'
BLACK='\033[0;30m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'


if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

FORCE_HEADPHONES=false

 # fonte de como usar isso: https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
while (( "$#" )); do
  case "$1" in
    -f|--force-headphones)
      FORCE_HEADPHONES=true
      shift
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      echo "Error: this script take no arguments $1" >&2
      exit 1
      ;;
  esac
done

# snapclient setup

echo -e "\n${GREEN}installing snapcast client...${NC}"
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.22.0/snapclient_0.22.0-1_armhf.deb -o 'snapclient.deb' &&
sudo apt install ./snapclient.deb -y
sudo rm -f snapclient.deb

echo -e "\n${LIGHT_BLUE}configuring snapclient (only tested on raspberry pi 4 and pi zeroW)${NC}"

if $FORCE_HEADPHONES; then
    echo -e "${LIGHT_BLUE}setting 'Headphones' as the snapclient output device. For this to work 'Headphones' must be a listed device in \`$ aplay -l\` command"
    echo 'SNAPCLIENT_OPTS="${SNAPCLIENT_OPTS} -s Headphones"' | sudo tee -a /etc/default/snapclient
fi

echo -e "\n${CYAN}restarting snapcast client service${NC}"
sudo systemctl restart snapclient.service

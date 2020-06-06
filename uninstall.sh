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

echo -e "\n${YELLOW}removing ${LIGHT_BLUE}snapclient${NC}"
sudo apt remove --purge snapclient -y
echo -e "\n${YELLOW}removing ${LIGHT_BLUE}snapserver${NC}"
sudo apt remove --purge snapserver -y
echo -e "\n${YELLOW}removing ${LIGHT_BLUE}raspotify${NC}"
sudo apt remove --purge raspotify -y
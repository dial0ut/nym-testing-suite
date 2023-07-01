#!/bin/bash

## Colors variables for the script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT









# Function to check if a command is in PATH
check_in_path() {
  local cmd=$1
  if command -v $cmd > /dev/null; then
    echo -e "${YELLOW}$cmd${WHOTE} is in ${LBLUE}PATH.${WHITE} You can run the client as user:${LGREEN}$USER${NOCOLOR}"
  else
    echo -e "${RED}$cmd is not in PATH."
  fi
}
nym_init (){
nym-socks5-client init --id dialout_sp1 --provider 4V8euNmD7oBtvQ9RaVGBLK9s2jVDLT7vxkg4iHWfFqza.HGMiWr7zPFohiyFGLzP82jDnVXodLvpjvjKyVvNJ33Uv@Bkq5KLDMRiL9vAaHqwCN7LJ16ecvhU7WsJoeWqk6PYjG --gateway Bkq5KLDMRiL9vAaHqwCN7LJ16ecvhU7WsJoeWqk6PYjG || echo -e "${RED}ERROR WHILE INIT ! GO CHECK nym_init function in this script and fix the flags ! ${NOCOLOR}"
}

# Function to check if a directory exists and is owned by the current user
check_dir_exists() {
  local dir=$1
  if [ -d $dir ]; then
    if [ $(stat -c '%U' $dir) == $USER ]; then
      echo "Directory $dir exists and is owned by $USER."
    else
      echo "Directory $dir exists but is not owned by $USER."
    fi
  elif command -v $cmd > /dev/null; then
     echo
     echo -e "nym-socks5-client is in PATH $(which nym-socks5-client)."
     read -p" Would you like to init and run it?" yn
     echo
     case $yn in
      [Yy]* ) nym_init && echo -e "${WHITE}...${NOCOLOR}" && sleep 5 && nym-socks5-client run --id dialout_sp1 && echo -e "${YELLOW}..." && sleep 3;;
      [Nn]* ) ;;
      * ) echo "Please answer yes or no.";;
     esac
  else
    read -p "Directory $dir does not exist. Please enter the path of the .nym/ directory: " dir
  fi
}

# Function to check if port 1080 is occupied
check_port_occupied() {
  if ss -ltn | grep -q ':1080 '; then
    echo
    echo -e "${WHITE}Port 1080 is occupied ... Let's check what process it is.${NOCOLOR}"
    echo
    sleep 1
    id=$(pgrep -a nym-socks | grep id | cut -d\- --fields=5 | sed -r 's/^id\s+//g')
    echo -e "${WHITE}Runs with ${LBLUE}--id ${YELLOW} ${id} ${NOCOLOR}"
    echo
    echo -e "${WHITE}$(pgrep -a nym-sock) ... ${YELLOW}nym-socks5-client ${WHITE} is this process! ${NOCOLOR}" || echo "it is not nym-socks5-client.. make sure to kill that process or rewrite this script so it accepts other port :P" && exit 1 
  else
    echo -e "${WHITE}Port 1080 is free${NOCOLOR}."
    echo
    echo -e "${WHITE} Gonna try to start the client ... if you do not want this, press CTRL+C"
    echo -e "${WHITE}Here is a list of your ids ..."
    ls $HOME/.nym/socks5-clients/
    echo "------"
    read -p "id of the client?" client_id
    echo -e "${LGREEN} STARTING THE ${RED}NYM-SOCKS5-CLIENT !!!"
    echo
    echo -e "${WHITE} LOGS WILL BE SAVED TO ${YELLOW}nohup.out ..."
    echo
    echo ------------------------------------
    sleep 2
    echo -e "${NOCOLOR}"
    nohup nym-socks5-client run --id "$client_id" & 
  fi
}

# Function to download nym-socks5-client from the official Nymtech Github
download_nym_socks5_client() {
  local dir=$1
  if [ ! -d $dir ]; then
    read -p "$dir does not exist. Do you want to download nym-socks5-client from the official Nymtech Github? (y/n) " yn
    case $yn in
      [Yy]* ) wget https://github.com/nymtech/nym/releases/download/nym-binaries-v1.1.22/nym-socks5-client -P $dir;;
      [Nn]* ) ;;
      * ) echo "Please answer yes or no.";;
    esac
  fi
}

# Function to check if a directory exists for a given id
check_id_dir_exists() {
  local dir=$1
  local id=$2
  if [ ! -d $dir/$clients_dir ]; then

  echo -e "${WHITE}You can either ${LBLUE}init and run${WHITE} the new client as ${LBLUE}${USER} ${WHITE} or give PATH for the config file ...${NOCOLOR}"
  echo
  echo -e "${LGREEN}YES${WHITE} to init and run"
  echo
  echo -e "...OR..."
  echo
  echo -e "${RED}NO ${WHITE} to continue with ${LBLUE}custom directory?${RED}EXAMPLE: ${WHITE}/home/nym/"
  echo -e "${NOCOLOR}"
  echo
  read -p "Yes or no?" yn
  case $yn in
    [Yy]* ) nym_init && nym-socks5-client run --id dialout_sp1 ;;
    [Nn]* ) ;;
    * ) echo -e "${WHITE}Please answer yes or no.";;
  esac
  echo
  echo -e "${LBLUE} What is your custom id ?"
  read custom_id
#  read -p "Directory $dir/$id does not exist." 
  echo
  echo -e "${LGREEN}"
  read -p "Please enter the path for nym socks5-client id/config: " path
  echo   
     if [ ! -d ${path}${socks5_clients_custom}${custom_id} ]; then echo -e "${WHITE}This ${YELLOW}$path ${RED}does not exist!${NOCOLOR}"
     else 
	     echo -e "${WHITE}Launching ${YELLOW}}nym-socks5-client${WHITE} from ${LGREEN}$path ...${NOCOLOR}" && sudo -u $(ls -la /home/nym/.nym/socks5-clients/ | cut --characters=14- | cut --delimiter=' ' --fields=1 | tail -n 1) nym-socks5-client run --id ${path}/.nym/socks5-clients/${custom_id} 
     fi
  fi
}

# Variables
cmd="nym-socks5-client"
dir="$HOME/.nym"
clients_dir="$dir/socks5-clients"
socks5_clients_custom=".nym/socks5-clients/"
id=""
path=""
# Run checks
#check_running $cmd
##
## Check if client is in PATH
check_in_path $cmd
# run after port check 
#check_dir_exists $dir
##
## check if client is rnning or something else on port 1080
check_port_occupied
check_dir_exists $dir || check_id_dir_exists $clients_dir $id && exit 0
download_nym_socks5_client $clients_dir
#check_id_dir_exists $clients_dir $id

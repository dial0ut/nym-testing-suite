#!/bin/bash
#source ./check.sh

## Colors variables for the script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT

# Default values
target_host=""
time_limit=10
test_number=100
output_file=""
use_curl=false
use_ncat=false
use_iperf=false
PYTHON_CMD="python"

display_usage() {
cat 1>&2 <<EOF
nym_network_debugger.sh 0.0.1 (2023-29-06)
Framework of tools for debugging Nym mixnet and its clients

USAGE:
  -r: Run the socks5-client  
  -t: Set the target host
  -c: Use curl for the tests
  -n: Use ncat for the tests
  -i: Use iperf for the tests
  -l: Set a time limit for each test (default is 10 seconds)
  -n: Set the number of tests to run (default is 100)
  -o: Write the results to a file
  -h: Display this help message
  -i 	--install ##  checkpoint script for configs and other stuff

EOF
}

# display usage if the script is not run as root user
#if [[ $USER != "root" ]]; then
#    printf "%b\n\n\n" "${WHITE} This script must be run as ${YELLOW} root ${WHITE} or with ${YELLOW} sudo!${NOCOLOR}"
#    exit 1
#fi

# Function to check dependencies

check_dependencies() {
  for cmd in $@; do
    if ! command -v $cmd &> /dev/null; then
      read -p "$cmd could not be found. Would you like to install it? (y/n) " yn
      case $yn in
        [Yy]* ) sudo apt-get install $cmd; break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
      esac
    fi
  done
}

# Function to check Python version
check_python() {
  if command -v python &> /dev/null; then
    PYTHON_CMD="python"
    echo "Python found"
  elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3" 
    echo "Python3 found"
  else
    echo "Python is not installed"
    exit 1
  fi
}

# Function to run a test
run_test() {
  local cmd=$1

  for i in $(seq 1 "$test_number"); do
    echo "Running $cmd test number $i ..."
    start=$(date +%s.%N)
    eval $cmd
    status=$?
    end=$(date +%s.%N)
    runtime=$($PYTHON_CMD -c "print(${end} - ${start})")

    if [[ $status -ne 0 || $(echo "$runtime>$time_limit" | bc -l) -eq 1 ]]; then
      echo "Test $i failed ... moving to the next one."
    else
      echo "Test $i completed in $runtime seconds."
    fi
  done
}

# Check for arguments
if [ $# -eq 0 ]; then
  display_usage
  exit 1
fi

# Parse command-line options
while getopts "t:cni:l:n:o:h" opt; do
  case $opt in
t) target_host=$OPTARG ;;
c) use_curl=true ;;
n) use_ncat=true ;;
i) use_iperf=true ;;
l) time_limit=$OPTARG ;;
n) test_number=$OPTARG ;;
o) output_file=$OPTARG ;;
h) display_usage; exit 0 ;;
*) display_usage; exit 1 ;;
esac
done

#Check dependencies and Python

check_dependencies curl ncat iperf bc
check_python

#Run client if not running
if [[ "$?" = "-r" ]]; then check_port_ocupied; fi

#Redirect output to file if specified

if [[ -n $output_file ]]; then
exec > $output_file
fi
## checkpoint script for configs and other stuff
#if [[ $1 -eq "-i" || $1 -eq "--install" ]]; then source ./check.sh;fi
if [[ "$1" = "--install" ||  "$1" = "-i" ]]; then
    source ./check.sh
    check_in_path $2
    check_dir_exists $3
    check_port_occupied
    download_nym_socks5_client $4
    check_id_dir_exists $5 $6
fi
#if [[ ("$1" = "--install") ||  "$1" = "-i" ]]; then source ./check.sh;fi

#Run tests

if $use_curl; then
	run_test "curl -m $time_limit -vL -x socks5h://127.0.0.1:1080 $target_host >/dev/null 2>&1"
fi

if $use_ncat; then
run_test "dd if=/dev/urandom bs=1024 count=1 | ncat -d 1 -w $time_limit --proxy 127.0.0.1:1080 --proxy-type socks5 $target_host >/dev/null 2>&1" $test_number $time_limit $target_host
fi

if $use_iperf; then
run_test “iperf -c $target_host -t $time_limit >/dev/null 2>&1”
fi


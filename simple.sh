#!/bin/bash
#source ./check.sh
./check.sh
## Colors variables for the script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT

test_number=100
display_usage() {
  echo -e "${YELLOW}"
  cat 1>&2 <<EOF
nym_network_debugger.sh 0.0.1 (2023-29-06)
Framework of tools for debugging Nym mixnet and its clients

USAGE:
  <target_host> <test_type> 

  test_type:
    curl - Use curl for the tests
    ncat - Use ncat for the tests
EOF
  echo -e "${NOCOLOR}"
  echo ""
}
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


check_python() {
  if command -v python &> /dev/null; then
    PYTHON_CMD="python"
  elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
  fi
}
check_dependencies
check_python
# Check for arguments
if [ $# -lt 2 ]; then
  display_usage
  exit 1
fi

#Set the target host and the test type
target_host="$1"
test_type="$2"
extras="$3"
# ... your other code here ...

#Run tests
run_test() {
  local cmd=$1

  for i in $(seq 1 "$test_number"); do
    echo -e "${LBLUE}Running $cmd test number $i ...${NOCOLOR}"
    start=$(date +%s.%N)
    eval $cmd
    status=$?
    end=$(date +%s.%N)
    runtime=$($PYTHON_CMD -c "print(${end} - ${start})")

    if [[ $status -ne 0 || $(echo "$runtime>$time_limit" | bc -l) -eq 1 ]]; then
      echo -e "${RED}Test $i failed ... moving to the next one.${NOCOLOR}"
      echo ""
    else
      echo -e "${YELLOW}Test $i completed ${WHITE} in $runtime seconds.${NOCOLOR}"
      echo ""
    fi
  done
}
time_limit=10
if [[ "$test_type" = "curl" ]]; then
        run_test "curl -m $time_limit -vL -x socks5h://127.0.0.1:1080 $target_host >/dev/null 2>&1"
fi

if [[ "$test_type" = "ncat" ]]; then
        run_test "dd if=/dev/urandom bs=1024 count=1 | ncat -d 1 -w $time_limit --proxy 127.0.0.1:1080 --proxy-type socks5 $target_host >/dev/null 2>&1"
fi

if [[ "$@" -eq "--install" ||  "$@" -eq "-i" ]]; then
    source ./check.sh
    check_in_path $2
    check_dir_exists $3
    check_port_occupied
    download_nym_socks5_client $4
    check_id_dir_exists $5 $6
fi


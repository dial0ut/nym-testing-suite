#!/bin/bash

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
    echo "Python found"
  elif command -v python3 &> /dev/null; then
    echo "Python3 found"
  else
    echo "Python is not installed"
    exit 1
  fi
}

# Function to run a test
run_test() {
  local cmd=$1
  local test_number=$2
  local time_limit=$3
  local target_host=$4

 for i in $(seq 1 $test_number) 
 # for i in {1..$test_number}
 do
    echo "Running $cmd test number $i ..."
    start=$(date +%s.%N)
    eval $cmd
    status=$?
    end=$(date +%s.%N)
    runtime=$(python -c "print(${end} - ${start})")
    
    if [[ $status -ne 0 || $(echo "$runtime>$time_limit" | bc -l) -eq 1 ]]; then
      echo "Test $i failed ... moving to the next one."
    else
      echo "Test $i completed in $runtime seconds."
    fi
  done
}

# Check for arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-t target-host] [-c] [-n] [-i] [-l time-limit] [-n tests-number] [-o output-file]"
  echo "-t: Set the target host"
  echo "-c: Use curl for the tests"
  echo "-n: Use ncat for the tests"
  echo "-i: Use iperf for the tests"
  echo "-l: Set a time limit for each test (default is 10 seconds)"
  echo "-n: Set the number of tests to run (default is 100)"
  echo "-o: Write the results to a file"
  echo "-h: Display this help message"
  exit 0
fi

# Parse command-line options
while getopts "t:cni:l:n:o:h" opt; do
  case $opt in
    t)
      target_host=$OPTARG
      ;;
    c)
      use_curl=true
      ;;
    n)
      use_ncat=true
      ;;
    i)
      use_iperf=true
      ;;
    l)
      time_limit=$OPTARG
      ;;
    n)
      test_number=$OPTARG
      ;;
    o)
      output_file=$OPTARG
      ;;
    h)
      echo "Usage: $0 [-t target-host] [-c] [-n] [-i] [-l time-limit] [-n tests-number] [-o output-file]"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check dependencies and Python
check_dependencies curl ncat iperf bc
check_python

# Redirect output to file if specified
if [[ -n $output_file ]]; then
  exec > $output_file
fi

# Run tests
if $use_curl; then
run_test “curl -m $time_limit -vL -x socks5h://127.0.0.1:1080 $target_host >/dev/null 2>&1” $test_number $time_limit $target_host
fi

if $use_ncat; then
run_test “dd if=/dev/urandom bs=1024 count=1 | ncat -w $time_limit –proxy 127.0.0.1:1080 –proxy-type socks5 $target_host 13370 >/dev/null 2>&1” $test_number $time_limit $target_host
fi

if $use_iperf; then
run_test “iperf -c $target_host -t $time_limit >/dev/null 2>&1” $test_number $time_limit $target_host
fi

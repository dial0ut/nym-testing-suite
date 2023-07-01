# Nym testing suite
Testing shell script for measuring clients reliability and testing mixnet transfer speeds.

## Nym Network Debugger

Nym Network Debugger is a command-line tool designed for debugging Nym mixnet and its clients. It allows you to run specific tests using curl and ncat.

## Usage

The general command-line structure for using this tool is as follows:

```bash
./simple.sh <target_host> <test_type
# Arguments:

<target_host>: The target host you want to test.
<test_type>: The type of test you want to run. Two options are currently supported:
curl: Runs tests using curl
ncat: Runs tests using ncat

# For example, to run a curl test on https://www.example.com, you'd run:
```

```bash

./simple.sh https://www.example.com curl
## To run a ncat test on https://www.example.com you'd run:

./simple.sh https://www.example.com ncat 
```

## Installation

The script utilizes common Linux command-line tools like `curl, ncat, python, bc`. Please ensure that these are installed on your machine.

In case a required command is not found, the script will prompt you to install it.

## Additional Information

The script includes color highlighting to easily understand the output. It displays successful tests in green, highlights and numbers in light blue, warnings in red, and default text in white.

The script will run a test 100 times by default. This number can be adjusted by changing the test_number variable in the script. Each test is given a time limit of 10 seconds by default, which can be adjusted by changing the time_limit variable in the script.

Enjoy using the Nym Network Debugger!

Licensed under MIT 






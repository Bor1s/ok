#!/usr/bin/env bats

setup() {
  # Set up the test environment
  TEST_DIR="$(mktemp -d)"
  LOG_FILE="$TEST_DIR/install.log"
  export LOG_FILE

  # Source the function file
  source "$PWD/script/functions/check_and_install.sh"

  # Debug: Show the function definition
  echo "Function definition:"
  declare -f check_and_install
}

@test "check_and_install function exists" {
  [ "$(type -t check_and_install)" = "function" ]
}

@test "check_and_install installs a new tool" {
  # Mock command to simulate tool not installed
  function command() {
    if [ "$1" = "-v" ]; then
      return 1
    fi
    return 0
  }
  export -f command

  # Mock eval to capture command
  function eval() {
    echo "MOCK_EVAL: $*"
    return 0
  }
  export -f eval

  # Run the function
  run check_and_install "test-tool" "echo installing"
  
  # Print debug info
  echo "Status: $status"
  echo "Output: $output"
  
  # Check results
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing test-tool..."* ]]
  [[ "$output" == *"test-tool ... OK"* ]]
}

@test "check_and_install skips already installed tool" {
  # Mock command to simulate tool already installed
  function command() {
    if [ "$1" = "-v" ]; then
      return 0
    fi
    return 0
  }
  export -f command

  # Mock eval to capture command
  function eval() {
    echo "MOCK_EVAL: $*"
    return 0
  }
  export -f eval

  # Run the function
  run check_and_install "existing-tool" "echo installing"
  
  # Print debug info
  echo "Status: $status"
  echo "Output: $output"
  
  # Check results
  [ "$status" -eq 0 ]
  [[ "$output" == *"existing-tool is already installed ... OK"* ]]
  [[ "$output" != *"Installing existing-tool..."* ]]
} 
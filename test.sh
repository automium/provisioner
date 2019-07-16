#!/bin/bash
test() { echo 0; echo 1; false; echo 2; }
test2() { set -e; set -o pipefail; echo 0; echo 1; false; echo 2; }

#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
PROJECT_PATH="$( realpath $SCRIPT_PATH/../../ )"

sourcery \
 --sources $PROJECT_PATH/CombinableResults/CombinableResults \
 --templates $SCRIPT_PATH/Templates \
 --output $PROJECT_PATH/CombinableResults/CombinableResults/Generated
#! /usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

TESTABLE="SourceryPlayground"
AUTHOR="$( id -F )"
DATE="$( date "+%d.%m.%y" )"
YEAR="$( date "+%Y" )"

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
PROJECT_DIR_1="${SCRIPT_PATH}/SourceryPlayground"
TEMPLATES_DIR="${SCRIPT_PATH}/CodeGen/Templates"
OUTPUT_DIR="${SCRIPT_PATH}/CodeGen/Output"
INTERMEDIATES_DIR="${OUTPUT_DIR}/Intermediates"
TEST_ROOTDIR="${OUTPUT_DIR}/Tests"

sourcery \
    --sources "${PROJECT_DIR_1}" \
    --sources "${INTERMEDIATES_DIR}" \
    --templates "${TEMPLATES_DIR}" \
    --output "${OUTPUT_DIR}" \
    --args author="${AUTHOR}",date="${DATE}",year="${YEAR}",testable="${TESTABLE}",intermediates_dir="${INTERMEDIATES_DIR}",test_rootdir="${TEST_ROOTDIR}" \
    --force-parse generated \
    --verbose $1
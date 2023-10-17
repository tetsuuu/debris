#!/bin/bash
set -euC

function logger() {
    if [[ $? -ne 0 ]]; then
        echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]\t[ERROR]\t$*"
        exit 1
    fi
    echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]\t[INFO]\t$*"
}

function init() {
    if [[ $# -eq 0 ]]; then
        logger "Insufficient arguments"
        usage
    fi
    readonly CALLER="$1"
}

function usage() {
cat <<EOS
Usage:  $0 <String>
 e.g.)
    $0 "Hello"

EOS
    exit 1
}

function hello() {
    logger "Echo CALLER"
    echo "Hello, ${CALLER}!"
}

function main(){
    hello
}

if [[ "${BASH_SOURCE:-$0}" == "${0}" ]]; then
    init "$@"
    main
fi

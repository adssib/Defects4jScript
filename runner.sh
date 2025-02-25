#!/bin/bash

p_value=""
v_value=""
b_value=""
defects4j_path=""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

if ! command -v bzip2 &>/dev/null; then
    echo "ERROR: bzip2 is not installed. Please install it using:"
    echo "      sudo apt-get install bzip2 -y"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            p_value="$2"
            shift 2
            ;;
        -v)
            v_value="$2"
            shift 2
            ;;
        -b)
            b_value="$2"
            shift 2
            ;;
        -d)
            defects4j_path="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$p_value" || -z "$v_value" || -z "$b_value" || -z "$defects4j_path" ]]; then
    echo "Error: Missing required options or values!"
    echo "Usage: $0 -p <value> -v <value> -b <value> -d <defects4j_path>"
    exit 1
fi

echo "p_value: $p_value"
echo "v_value: $v_value"
echo "b_value: $b_value"
echo "defects4j_path: $defects4j_path"

defects4j_bin="${defects4j_path}/framework/bin"

if [ ! -x "${defects4j_bin}/defects4j" ]; then
    echo "ERROR: defects4j executable not found in ${defects4j_bin}."
    exit 1
fi

proj_dir="Proj_${p_value}"
echo "Creating project directory: $proj_dir"

pathToTests="RandTests/$p_value/randoop/11/${p_value}-${v_value}-randoop.11.tar.bz2"
echo "Path to Tests: $pathToTests"

mkdir -p "$proj_dir" && cd "$proj_dir" || { echo "ERROR: Failed to enter $proj_dir directory"; exit 1; }

"${defects4j_bin}/defects4j" checkout -p "$p_value" -v "$v_value" -w .
"${defects4j_bin}/defects4j" coverage
"${defects4j_bin}/defects4j" mutation
"${defects4j_bin}/gen_tests.pl" -g randoop -p "$p_value" -v "$v_value" -n 11 -o RandTests -b "$b_value" -D
"${defects4j_bin}/defects4j" coverage -s "$pathToTests"
"${defects4j_bin}/defects4j" mutation -s "$pathToTests"

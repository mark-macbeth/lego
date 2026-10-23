#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tmp-backup.sh --src FOLDER --dst FOLDER [--range DAYS] [--count COUNT] [--force]

Back up files modified within DAYS (default: 1), keeping at most COUNT
versions per file (default: 5), storing backups under the destination folder.

Options:
  -s, --src FOLDER   Folder to back up (required)
  -d, --dst FOLDER   Folder in which to store backups (required)
  -r, --range DAYS   Look back this many days
  -c, --count COUNT  Keep this many backups per file
  -f, --force        Delete excess backups without prompting
  -h, --help         Show this help
EOF
}

normalize_integer() {
  local value=$1
  while [[ ${#value} -gt 1 && $value == 0* ]]; do
    value=${value#0}
  done
  printf '%s' "$value"
}

expand_home_path() {
  case $1 in
    '~') printf '%s' "${HOME:?HOME must be set}" ;;
    '~/'*) printf '%s/%s' "${HOME:?HOME must be set}" "${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

range_days=1
keep_count=5
force_delete=false
source_folder=
destination_folder=

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--src)
      if [[ $# -lt 2 ]]; then
        printf 'Error: %s requires a folder path.\n' "$1" >&2
        exit 2
      fi
      if [[ -n $source_folder ]]; then
        printf 'Error: source folder was specified more than once.\n' >&2
        exit 2
      fi
      source_folder=$2
      shift 2
      ;;
    --src=*)
      if [[ -n $source_folder ]]; then
        printf 'Error: source folder was specified more than once.\n' >&2
        exit 2
      fi
      source_folder=${1#*=}
      shift
      ;;
    -d|--dst)
      if [[ $# -lt 2 ]]; then
        printf 'Error: %s requires a folder path.\n' "$1" >&2
        exit 2
      fi
      if [[ -n $destination_folder ]]; then
        printf 'Error: destination folder was specified more than once.\n' >&2
        exit 2
      fi
      destination_folder=$2
      shift 2
      ;;
    --dst=*)
      if [[ -n $destination_folder ]]; then
        printf 'Error: destination folder was specified more than once.\n' >&2
        exit 2
      fi
      destination_folder=${1#*=}
      shift
      ;;
    -r|--range)
      if [[ $# -lt 2 ]]; then
        printf 'Error: %s requires a number of days.\n' "$1" >&2
        exit 2
      fi
      range_days=$2
      shift 2
      ;;
    --range=*)
      range_days=${1#*=}
      shift
      ;;
    -c|--count)
      if [[ $# -lt 2 ]]; then
        printf 'Error: %s requires a backup count.\n' "$1" >&2
        exit 2
      fi
      keep_count=$2
      shift 2
      ;;
    --count=*)
      keep_count=${1#*=}
      shift
      ;;
    -f|--force)
      force_delete=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf 'Error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      printf 'Error: unexpected argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z $source_folder ]]; then
  printf 'Error: a source folder is required.\n' >&2
  usage >&2
  exit 2
fi
if [[ -z $destination_folder ]]; then
  printf 'Error: a destination folder is required.\n' >&2
  usage >&2
  exit 2
fi

if [[ ! $range_days =~ ^[0-9]+$ ]]; then
  printf 'Error: range must be a non-negative whole number of days.\n' >&2
  exit 2
fi
if [[ ! $keep_count =~ ^[0-9]+$ ]]; then
  printf 'Error: count must be a positive whole number.\n' >&2
  exit 2
fi

range_days=$(normalize_integer "$range_days")
keep_count=$(normalize_integer "$keep_count")
if [[ ${#range_days} -gt 9 ]]; then
  printf 'Error: range cannot exceed 999999999 days.\n' >&2
  exit 2
fi
if [[ ${#keep_count} -gt 9 || $keep_count == 0 ]]; then
  printf 'Error: count must be between 1 and 999999999.\n' >&2
  exit 2
fi

source_folder=$(expand_home_path "$source_folder")
destination_folder=$(expand_home_path "$destination_folder")

if [[ ! -d $source_folder ]]; then
  printf 'Error: folder does not exist or is not a directory: %s\n' "$source_folder" >&2
  exit 2
fi

source_folder=$(cd "$source_folder" && pwd -P)
mkdir -p "$destination_folder"
backup_root=$(cd "$destination_folder" && pwd -P)

if [[ $source_folder == "$backup_root" ]]; then
  printf 'Error: source and destination folders must be different.\n' >&2
  exit 2
fi

export LC_ALL=C
shopt -s nullglob

find "$source_folder" -path "$backup_root" -prune -o -type f ! -name '.*' -mtime "-$range_days" -print0 |
while IFS= read -r -d '' source_file; do
  modified_epoch=$(stat -f '%m' "$source_file")
  backup_timestamp=$(date -u -r "$modified_epoch" '+%Y-%m-%dT%H_%M_%SZ')
  source_name=${source_file##*/}
  backup_extension=
  if [[ $source_name == *.* && $source_name != .* ]]; then
    backup_extension=".${source_name##*.}"
  fi
  backup_directory="$backup_root${source_file}"
  backup_file="$backup_directory/$backup_timestamp$backup_extension"

  if [[ -f $backup_file ]]; then
    # printf 'Already backed up: %s\n' "$source_file"
    continue
  fi
  if [[ -e $backup_file || -L $backup_file ]]; then
    printf 'Error: backup destination already exists and is not a regular file: %s\n' "$backup_file" >&2
    exit 1
  fi

  mkdir -p "$backup_directory"
  cp -p "$source_file" "$backup_file"
  printf 'Backed up: %s\n' "$source_file"

  backups=()
  for candidate in "$backup_directory"/*; do
    if [[ -f $candidate ]]; then
      backups+=("$candidate")
    fi
  done

  while [[ ${#backups[@]} -gt keep_count ]]; do
    oldest_index=0
    oldest_epoch=$(stat -f '%m' "${backups[0]}")
    for index in "${!backups[@]}"; do
      candidate_epoch=$(stat -f '%m' "${backups[$index]}")
      if (( candidate_epoch < oldest_epoch )); then
        oldest_index=$index
        oldest_epoch=$candidate_epoch
      fi
    done
    if [[ $force_delete != true ]]; then
      if [[ ! -r /dev/tty ]]; then
        printf 'Error: cannot prompt to delete old backup without a terminal.\n' >&2
        exit 1
      fi
      if ! IFS= read -r -p "Delete old backup: '${backups[$oldest_index]}'? [y/N] " response </dev/tty; then
        printf '\nError: could not read deletion confirmation.\n' >&2
        exit 1
      fi
      if [[ ! $response =~ ^[Yy]([Ee][Ss])?$ ]]; then
        printf 'Keeping old backup: %s\n' "${backups[$oldest_index]}"
        break
      fi
    fi

    printf 'Removing old backup:  %s\n' "${backups[$oldest_index]}"
    rm "${backups[$oldest_index]}"
    unset 'backups[oldest_index]'
    backups=("${backups[@]}")
  done
done

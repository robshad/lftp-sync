#!/bin/bash
########################################################################
#
# lftp-sync:    A simple interface for using lftp to mirror remote data
#               structures based on file modification times.
# Author:       Rob Shad
# Contact:      <robertmshad@googlemail.com>
#
# Changelog (sorted newest -> oldest):
#   - 2015-11-04:   Based this script off of stemwinder/lftp-sync
#                   https://github.com/stemwinder/lftp-sync
#                   Modified for use of docker with unRAID
#
########################################################################

readlink_cmd='readlink'
date_cmd='date'

# set path and name variables
this_path=$("$readlink_cmd" -f $0)  ## Path of this file including filename
dir_name=`dirname ${this_path}`     ## Parent directory of this file WITHOUT trailing slash
myname=`basename ${this_path}`      ## file name of this script

# inlcude default config settings
if [ ! -f "$dir_name/lftp-sync.cfg" ] ; then
    echo "No config file was found. Exiting."
    exit 1
else
    source "$dir_name/lftp-sync.cfg"
fi

# define and display help info to the user
function help {
    echo "
    usage: lftp-sync.sh [options]
    -h      optional  Print this help message
    -s      required  Path to remote source.
            Adding or removing a trailing slash will affect the behaviour.
    -t      required  Path to local target.
            Adding or removing a trailing slash will affect the behaviour.
    -v      optional  Lftp mirror verbosity level
            default is 0, options are 1, 2 and 3
    -m      optional  Number of parallel downloads.
            Smaller files will benefit from more concurrent downloads.
            default is 15
    -n      optional  Number of pget segments per download.
            Larger files will benefit from higher segment counts.
            default is 10
    -u      optional  Total Upload limit
            default is 0 (unlimited)
            This argument is passed directly to lftp
    -d      optional  Total Download limit
            default is 0 (unlimited)
            This argument is passed directly to lftp
    -o      optional  Time override (--newer-than)
            Overrides the default time behaviour of script"
    exit 1
}

# write input to log file
function log {
    echo "[`date`] - ${*}" >> "$dir_name/$log_file"
}

# If no arguments are passed to this script, it should always show the usage info.
# The script will never perform any action unless the necessary parameters are explicitly used.
if [ $# == 0 ] ; then
  help
  exit 1;
fi

# get command line arguements
while getopts hs:t:v:m:n:u:d:o: opt; do
  case $opt in
  s)
      source_path=$OPTARG
      ;;
  t)
      target_path=$OPTARG
      ;;
  v)
      verbosity=$OPTARG
      ;;
  m)
      streams=$OPTARG
      ;;
  n)
      segments=$OPTARG
      ;;
  u)
      ul_limit=$OPTARG
      ;;
  d)
      dl_limit=$OPTARG
      ;;
  o)
      newer_than=$OPTARG
      ;;
  h)
      help
      ;;
  esac
done

# makes paramters accesible by arguement number (eg: $1, $2, ...)
shift $((OPTIND - 1))

# making sure we have both a source and target path
if [[ -z "$source_path" ]] || [[ -z "$target_path" ]]; then
  echo "Error: A source and target path must be specified."
  exit 1;
fi

echo "Running LFTP Sync"
log "Begin script execution"

# execute lftp command
log "Start lftp sync"
lftp_command="lftp -c \"connect -u $username,$password sftp://$server:$port; set net:limit-total-rate $dl_limit:$ul_limit; mirror $lftp_mirror_args --verbose=$verbosity --parallel=$streams --use-pget-n=$segments \\\"$source_path\\\" \\\"$target_path\\\"; quit\""
log $lftp_command
eval $lftp_command 2>&1

# exit script with success code
log "Script execution complete"

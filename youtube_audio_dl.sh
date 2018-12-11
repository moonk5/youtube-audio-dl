#!/bin/sh
#####################################################################
## youtube_audio_dl.sh
##  
#####################################################################

#####################################################################
## Variables
#####################################################################
# Version number
M_VERSION_MAJ=1
M_VERSION_MIN=0
M_VERSION_REV=0
# Variables
M_AUDIO_FILENAME='NEWFILE'
M_AUDIO_TEMPFILE=''
M_AUDIO_STARTTIME=''
M_AUDIO_ENDTIME=''
M_AUDIO_DURATION=''
M_AUDIO_FORMAT='m4a'
# Set the last argument as the target URL
M_URL="${@: -1}"

M_FFMPEG_SKIP=false
M_FFMPEG_OPTS=''

#####################################################################
## Functions
#####################################################################
print_usage() {
  printf 'Usage: youtube_audio_dl [OPTIONS] URL\r\n'
  printf 'Options:\n'
  printf '  -h help\tPrint this help text and exit\n'
  printf '  -f output\tOutput filename\n'
  printf '  -s start time\tSet start time offset\n'
  printf '  -e end time\tSet end time offset (warn: re-calculate duration)\n'
  printf '  -d duration\tSet duration of audio\n' 
}

# Convert end time offset to duration
# param1 ($1) - From time offset
# param2 ($2) - To time offset
calculate_duration() {
  m_from_time=$1
  m_to_time=$2
  m_from_time=$(date -u -d "$m_from_time" +"%s")
  m_to_time=$(date -u -d "$m_to_time" +"%s")
  
  M_AUDIO_DURATION=$(date -u \
    -d "0 $m_to_time sec - $m_from_time sec" +"%H:%M:%S")
}

#####################################################################
## Parse options
#####################################################################
if [ $# -eq 0 ]
then
  echo '[ERROR] missing an argument, URL'
  exit 1
fi

while getopts 'f:s:e:d:u:hv' flag; do
  case "${flag}" in
    f) M_AUDIO_FILENAME="${OPTARG}" ;;
    s) M_AUDIO_STARTTIME="${OPTARG}" ;;
    e) M_AUDIO_ENDTIME="${OPTARG}" ;;
    d) M_AUDIO_DURATION="${OPTARG}" ;;
    u) M_URL="${OPTARG}" ;;
    h) print_usage
      exit 1 ;;
    v) echo 'Version: '$M_VERSION_MAJ.$M_VERSION_MIN.$M_VERSION_REV
      exit 1 ;;
  esac
done

if [ -z "$M_AUDIO_STARTTIME" ] && [ -z "$M_AUDIO_DURATION" ]
then
  M_FFMPEG_SKIP=true
  M_AUDIO_TEMPFILE=$M_AUDIO_FILENAME.$M_AUDIO_FORMAT
else
  M_AUDIO_TEMPFILE=TEMP_$M_AUDIO_FILENAME.$M_AUDIO_FORMAT
fi

if [ -n "$M_AUDIO_ENDTIME" ]
then
  # calculate duration (overwrite duration if exists)
  if [ -n "$M_AUDIO_STARTTIME" ]
  then # case 1: start time offset exists
    calculate_duration $M_AUDIO_STARTTIME $M_AUDIO_ENDTIME
  else # case 2: replace the duration with end time offset
    M_AUDIO_DURATION=$M_AUDIO_ENDTIME
  fi
fi

#####################################################################
## youtube-dl - extract audio from the given url
#####################################################################
youtube-dl -x \
  --output $M_AUDIO_TEMPFILE \
  --audio-format $M_AUDIO_FORMAT \
  --audio-quality 0 \
  $M_URL

######################################################################
## ffmpeg - trim audio length 
######################################################################
if [ "$M_FFMPEG_SKIP" = false ]
then
  if [ -n "$M_AUDIO_STARTTIME" ]
  then
    M_FFMPEG_OPTS+=' -ss '$M_AUDIO_STARTTIME
  fi
  if [ -n "$M_AUDIO_DURATION" ]
  then
    M_FFMPEG_OPTS+=' -t '$M_AUDIO_DURATION
  fi

  ffmpeg -i \
    $M_AUDIO_TEMPFILE \
    $M_FFMPEG_OPTS \
    $M_AUDIO_FILENAME.$M_AUDIO_FORMAT

  # Delete temporary file
  if [ -e $M_AUDIO_TEMPFILE ]
  then
    rm $M_AUDIO_TEMPFILE
  fi
fi

echo "Thank you"
exit 0

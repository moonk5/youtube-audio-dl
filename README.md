# DESCRIPTION
**youtube_audio_dl** is a simple script to extract audio from Youtube.com by
using [youtube-dl](https://github.com/rg3/youtube-dl.git) and
[ffmpeg](https://github.com/FFmpeg/FFmpeg.git).
(Note: audio format is fixed to `m4a`)

    youtube_audio_dl [OPTIONS] URL

# OPTIONS
    -h, help                  Print this help text and exit
    -f, output                Output filename (default=NEWFILE)
    -s, start_time            Set start time offset
    -e, end_time              Set end time offset (warn: re-calculate duration)
    -d. duration              Set audio duration 

# EXAMPLES

```bash
# extract audio, starts from 31 seconds
$ youtube_audio_dl -f YesOrYes -s 00:00:31 https://www.youtube.com/watch?v=mAKsZ26SabQ

```

#!/bin/bash

usage() { echo "Usage: $0 [-l <song name>] [-p <file-name>] [-a <song name> ] [-v <song name>]" 1>&2; exit 1;}

while getopts ":l:p:a:v:" o; do
    case "${o}" in
        l)
            l=${OPTARG}
            lyrics "$l"
            ;;
        p)
            p=${OPTARG}
            ffplay -autoexit -nodisp -loglevel panic "$p"
            ;;
        a)
            a=${OPTARG}
            youtube-dl "ytsearch:$a" -f 141  --restrict-filenames -o '%(title)s.%(ext)s'
            ;;
        v)
            d=${OPTARG}
            youtube-dl "ytsearch:$v" -f 22  --restrict-filenames -o '%(title)s.%(ext)s'
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${l}" ] && [ -z "${p}" ] && [ -z "${a}" ] && [ -z "${v}" ]; then
    usage
fi


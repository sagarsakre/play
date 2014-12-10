#!/bin/bash
usage() { echo "Usage: $0 [-l <song name>] [-p <song name>] [-d <file-name> ]" 1>&2; exit 1;}

while getopts ":l:p:d:" o; do
    case "${o}" in
        l)
            l=${OPTARG}
           lyrics "$l"
            ;;
        p)
            p=${OPTARG}
            ffplay -autoexit -nodisp -loglevel panic "$p"
            ;;
        d)
            d=${OPTARG}
            youtube-dl "ytsearch:$d" -f 141  -o '%(title)s.%(ext)s'
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${l}" ] && [ -z "${p}" ] && [ -z "${d}" ]; then
    usage
fi


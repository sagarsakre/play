#!/bin/bash
#. godir.sh
function godir () {
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        exit
    fi
    T=$PWD
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index..."
        (\cd $T; find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > filelist)
        echo " Done"
        echo ""
    fi
lines=()
for each in $1
do
    lines+=($(\grep -i "$each" $T/filelist | sort | uniq))
done
#    lines=($(\grep -i "$1" $T/filelist | sort | uniq))
#    lines=($(\grep -i "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
#	echo $lines
    if [[ ${#lines[@]} = 0 ]]; then
        echo "$1 Not found in current playlist"
	read -p "Do you wish to download it[Y/n]?:" yn
	    case $yn in
	        [Yy]* ) return 187; break;;
	        [Nn]* ) exit;;
	        * ) echo "Please answer yes or no.";;
	    esac
    fi
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            index=1
                        for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            printf "%6s %s\n" "[$index]" "None of the above, download the song from internet"
            echo
            printf "%6s %s\n" "[$(($index + 1))]" "Nevermind, just exit"
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [ $choice -eq $index ]; then
                  return 187
	    fi
            if [ $choice -eq $(($index + 1)) ]; then
                  exit
	    fi
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi

ffplay -autoexit -nodisp -loglevel panic "$pathname" 
#echo `echo $T/$pathname | sed -e 's/\/[^/]*$//'`
}
usage() { echo "Usage: $0 [-l <song name>] [-p <file-name>] [-a <song name> ] [-v <song name>]" 1>&2; exit 1;}

while getopts ":l:p:a:v:" o; do
    case "${o}" in
        l)
            l=${OPTARG}
	echo "$l"
          lyrics "$l"
            ;;
        p)
            p=${OPTARG}
            godir ${p}
            if [ $? -eq 187 ];then
                ./play.sh -a "$p"
	    fi
#            ffplay -autoexit -nodisp -loglevel panic "$p"
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

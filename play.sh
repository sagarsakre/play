#!/bin/bash
#. godir.sh
function godir () {
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        exit
    fi
#    if [[ -z "$2" ]]; then
        file=".playlist"
#    else
#       file=".recently_played"
#    fi
    echo file=$file
    T=$HOME
    MUSIC_DIR=$T/Music
    list=($(find $MUSIC_DIR -type f -printf "%T@ %p\n" | sort -nr | cut -d\  -f2-))
    if test $T/$file -nt ${list[0]}; then
	echo
    else
	echo -n "Creating index..."
        (\cd $T; find $MUSIC_DIR -wholename ./out -prune -o -wholename ./.git -prune -o -type f > $file)
        echo " Done"
        echo ""
    fi
#    if [[ ! -f $T/.playlist ]]; then

#        echo -n "Creating index..."
#        (\cd $T; find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > .playlist)
#        echo " Done"
#        echo ""
#    fi
lines=()
for each in $1
do
    lines+=($(\grep -i "$each" $T/.playlist | sort | uniq))
done
#    lines=($(\grep -i "$1" $T/.playlist | sort | uniq))
#    lines=($(\grep -i "$1" $T/.playlist | sed -e 's/\/[^/]*$//' | sort | uniq))
#	echo $lines
    if [[ ${#lines[@]} = 0 ]]; then
        echo "$1 Not found in current playlist"
	read -p "Do you wish to download it[y/N]?:" yn
	    case $yn in
	        [Yy]* ) return 187; break;;
	        [Nn]* | * ) exit;;
#	        * ) echo "Please answer yes or no.";;
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
            printf "%6s %s\n" "[$index]" "Play all the above songs"
	    echo
            printf "%6s %s\n" "[$(($index + 1))]" "None of the above, download the song from internet"
            echo
            printf "%6s %s\n" "[$(($index + 2))]" "Nevermind, just exit"
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [ $choice -eq $index ]; then
                inx=1
                for line in ${lines[@]}; do
                echo "Now Playing:"  "${lines[$(($inx-1))]}"
        		notify-send "Now Playing" "$(find-song.py "$(echo ${lines[$(($inx-1))]} | rev | cut -d"/" -f1 | rev)")" -i /home/sagar/Music/icon.jpg &
		        sleep 1
                ffplay -autoexit -nodisp -loglevel panic "${lines[$(($inx-1))]}"
                echo "$pathname" >> ~/.recently_played
                inx=$(($inx + 1))
                done
                exit
            fi
            if [ $choice -eq $(($index + 1)) ]; then
                  return 187
            fi
            if [ $choice -eq $(($index + 2)) ]; then
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

#send graphical notification of playing song
notify-send "Now Playing" "$(find-song.py "$(echo ${pathname}| rev | cut -d"/" -f1 | rev)")" -i /home/sagar/Music/icon.jpg &

ffplay -autoexit -nodisp -loglevel panic "$pathname" 
#echo `echo $T/$pathname | sed -e 's/\/[^/]*$//'`
}
usage() { echo "Usage: $0 [-l <song name>] [-p <file-name>] [-a] [-v] [-u] [-d <song-name/url>" 1>&2; exit 1;}
T=$HOME
#Set audio as default download format
format=141
#Set default as string search on youtube
search="ytsearch:"
MUSIC_DIR=$T/Music

while getopts ":l:p:aud:vud:r" o; do
    case "${o}" in
        l)
            l=${OPTARG}
	echo "$l"
	if [ "$l" == "current" ]; then
	    echo "Showing current songs lyrics"
            #fetch the current running song and extract the song path
            current_song_path=$(ps aux |grep ffplay | awk {'print $16}')
            #extract only the file name
            current_song_name=$(echo ${current_song_path}| rev | cut -d"/" -f1 | rev)
            #find the lyrics of the song
            ./lyrics "$current_song_name"
	else
            ./lyrics "$l"
	fi
            ;;
        p)
            p=${OPTARG}
            godir "${p}"
            if [ $? -eq 187 ];then
                ./play.sh -ad "$p"
	    fi
#            ffplay -autoexit -nodisp -loglevel panic "$p"
            ;;
        a)
             format=bestaudio
            ;;
        v)
             format=best
            ;;
        u)
             search=
            ;;
        d)
            d=${OPTARG}
            youtube-dl "$search$d" -f ${format}   --no-mtime --restrict-filenames -o $MUSIC_DIR'/%(title)s.%(ext)s'
            ;;
        r)
            godir "_" "dummy"
            p="dummy"
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#if [ -z "${l}" ] && [ -z "${p}" ] && [ -z "${a}" ] && [ -z "${v}" ]; then
if [ -z "${l}" ] && [ -z "${p}" ] && [ -z "${d}" ]; then
    usage
fi

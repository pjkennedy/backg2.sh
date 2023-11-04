# Written by Patrick Kennedy
#
# PREREQUISITE: apt-get install sox (for "play" command)
# filename: backg2.sh

# Change desktop backgound with backg2.sh -- images download from Unsplashed.com when internet is up; 
# must make subdirectory structure for images to be saved. If offline, show downloaded images per menu 
# control; great way to control the room's ambiance. Could be adapted into a PowerPoint type application.

# Example /home/joe/sh/backg2.sh

# Must disable WAYLAND to make work
# https://jumpcloud.com/support/troubleshooting-remote-assist-disable-wayland-or-gpu-rendering-for-linux
#
# Must disable WAYLAND by editing /etc/gdm3/custom.conf or  /etc/gdm3/daemon.conf and restarting. 
# Namely, the easiest way is to uncomment "WaylandEnable=false" and then reboot system.

# MIT License

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.


BASE_PATH="/home/joe/sh"

# initalize screens
#xrandr --output HDMI-1 --auto
#xrandr --output eDP-1  --auto
#xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate normal --right-of XWAYLAND0
xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output eDP-1

tput clear  

# even or odd toggle counter to turn audio on or off
audioToggle=1
# audio effects are off by default
audio="false"

#### Query URL examples ####
#url="https://source.unsplash.com/1600x900/?{deep%20space},{solar%20system},{big%20bang}"
#url="https://source.unsplash.com/1600x900/?tropical,paradise,hawaii,hula"
#query='mountain,hill'
#query='tropical,paradise,hawaii,hula'

query='waves,surf,tropical,hawaii'
saveToDIR='waves'
mkdir -p $BASE_PATH/back_images/$saveToDIR 2> /dev/null

function flipRight {
  #xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate right --right-of XWAYLAND0
  xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output eDP-1 --rotate right

  if [ "$audio" = "true" ]; then
    play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4 \
    delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1 norm -1
  fi
}

function fix {
  # Doesn't always fix problems...FYI.
  # different HDTVs and cables can cause issues, such as the screen blacking out.
  #xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate normal --right-of XWAYLAND0
  xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output eDP-1 --rotate normal
}

function flipLeft {
  # left
  #xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate left --right-of XWAYLAND0
  xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output eDP-1 --rotate left

  if [ "$audio" = "true" ]; then  
    play -q -n synth sine F2 sine C3 remix - fade 0 4 .1 norm -4 bend 0.5,2477,2 fade 0 4.0 0.5  2> /dev/null
  fi
}

function flipDown {
  # invert screen

  #xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate inverted --right-of XWAYLAND0
  xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output eDP-1 --rotate inverted --auto

  if [ "$audio" = "true" ]; then
    play -n synth pl C3 trim 0 1.25 repeat 4
    #sleep 5
  fi

}

function flipUp {
  # back to normal
  #xrandr  --output XWAYLAND0 --auto --rotate normal --pos 0x0 --output XWAYLAND2 --rotate normal --right-of XWAYLAND0
  xrandr  --output eDP-1 --auto --rotate normal --pos 0x0 --output HDMI-1 --rotate normal --right-of eDP-1

  if [ "$audio" = "true" ]; then  
    play -n -c1 synth sin %-12 sin %-9 sin %-5 sin %-2 fade q 0.1 3 0.1
  fi
}

function getMenu {
  tput sc

  cols=$( tput cols )
  rows=$( tput lines )

  tput cup 0 $((cols - 20))
  echo "|    Menu    |"

  tput cup 1 $((cols - 20))
  echo "D - Flip Down"

  tput cup 2 $((cols - 20))
  echo "U - Flip Up"
  
  tput cup 3 $((cols - 20))
  echo "R - Flip Right"

  tput cup 4 $((cols - 20))
  echo "L - Flip Left"

  tput cup 5 $((cols - 20))
  echo "N - Next pic"

  tput cup 6 $((cols - 20))
  echo "P - Prev pic"

  tput cup 7 $((cols - 20))
  echo "M - Redraw menu"

  tput cup 8 $((cols - 20))
  echo "A - Toggle Audio"

  tput cup 9 $((cols - 20))
  echo "F - Fix Display"
 
  tput rc

}
trap getMenu WINCH
getMenu


function setWallpaper() {
    url_pic=$BASE_PATH/back_images/$saveToDIR/$1
    #echo $url_pic
    gsettings set org.gnome.desktop.background picture-uri "$url_pic"
}

function internetStatus { 
  wget -q --spider http://google.com

  if [ $? -eq 0 ]; then
      return 0   # set to zero (0) for normal mode; set to 1 to make it offline 
      # echo "Online"
  else
      return 1
      # echo "Offline"
  fi
}



while true
do
# do big loop with two sub-loops

##if [ $x -eq 1 ] ; then

# Loop 1
while true
do
  internetStatus
  status=$?
  #echo "status "  $status
  # If offline (1), break loop and goto the next loop -- live images loop

  if [ $status -eq 1 ]; then
    echo "internet is down; can't do live images loop -- switching to next loop"
    break
  fi


  current_time=$(date "+%Y.%m.%d-%H.%M.%S")
  url="https://source.unsplash.com/1600x900/?"$query


  cd $BASE_PATH/back_images/$saveToDIR
  echo ""
  echo "Downloading --> "$url
  curl --max-time 35 --connect-time 7 -L $url > pic.$current_time.jpg  # -s for silent
  exit_code=$?
  echo "curl status: " $exit_code

  #
  # FYI: Don't attempt to parse ls output -->
  # https://stackoverflow.com/questions/1447809/awk-print-9-the-last-ls-l-column-including-any-spaces-in-the-file-name
  # http://mywiki.wooledge.org/ParsingLs
  #
  if ! [ $exit_code -eq 28 ] > /dev/null || [ $exit_code -eq 0 ]; then
    file=`find pic.$current_time.jpg -maxdepth 1 -type f`
    #file=`ls -l | tail -1 | cut -f9 -d' '`  # old way
    echo "file: " $file  

    uri='file://'$BASE_PATH'/back_images/'$saveToDIR/$file
    echo "uri: " $uri

    gsettings set org.gnome.desktop.background picture-uri $uri
    sleep 60s
  fi
  sleep 15s
done


###########################################################
### echo saved images loop for when there's no internet ###
# using an array, we can get a fresh list of DIR entries
shopt -s dotglob
shopt -s nullglob
cd $BASE_PATH/back_images/$saveToDIR
array=(*.{jpg,png})

i=0  #image index
firstLoop=0

while true
do
#for f in $BASE_PATH/back_images/$saveToDIR/*{.jpg,png}; do
for f in ${array[$i]}; do
  internetStatus
  status=$?

  arr_length=${#array[@]}
  
  # if online again, break saved images loop and proceed to top loop // loop 1 of 2
  if [ $status -eq 0 ]; then
    echo "internet is back on; breaking out of saved images loop..."
    echo break do 1 of 2
    break
  fi
  #echo "status " $status
  
  # test for a user input key event here;

  echo Keyboard input...
  read -rsn1 -t 5 key

  if [ "$key" = "p" ]; then
    # need to test for ZERO
    i=$((i-1))
    if [ "$i" -lt 0 ]; then 
       i=$arr_length-1
       f=${array[$i]} 
    else
       f=${array[$i]} 
    fi

    setWallpaper $f
    getMenu
    continue

  fi

  # next
  if [ "$key" = "n" ]; then
  # this part of the code needs more streamlinig and improvement
 
        #echo top $i
	if [ "$i" -eq 0 ]; then
	   #echo zero zero zero
           f=${array[$i]}
           #echo First time $i
           i=1

        else

           if [ "$i" -gt 0 ] && [ "$i" -lt "$arr_length" ]; then
	     #echo Between one and length /// $i
             f=${array[$i]}  
	     #echo Subsequently $i and $f
	     
             i=$((i+1))  
	   fi
           if [ "$i" -eq "$arr_length" ]; then
             #echo It is equal......... 
             i=0	
           fi

	   #if [ "$i" -eq "$arr_length" ]; then
           #  f=${array[$i]}  
           #  echo At the top of the array --> $i

           #  i=0
             #continue
	   #fi
        fi

    setWallpaper $f
    getMenu
    continue
  fi

  if [ "$key" = "d" ]; then
    flipDown
  fi
  if [ "$key" = "u" ]; then
    flipUp
  fi
  if [ "$key" = "l" ]; then
    flipLeft
  fi
  if [ "$key" = "r" ]; then
    flipRight
  fi
  if [ "$key" = "f" ]; then
    fix
  fi
  if [ "$key" = "m" ]; then
    getMenu
    continue
  fi
  audioToggle=$audioToggle+1
  if [ "$key" = "a" ]; then
    if [ $((audioToggle%2)) -eq 0 ]; then
      echo Enabled audio effects...
      audio="true"
      getMenu
      continue
    else
      echo Disabled audio effects...
      audio="false"
      getMenu
      continue
    fi
  fi



  # main action to set wallpaper
  url_pic=$BASE_PATH/back_images/$saveToDIR/$f
  echo $url_pic
  getMenu
  gsettings set org.gnome.desktop.background picture-uri "$url_pic"
  sleep 12s

  
  i=$((i+1))
  if [ "$i" -ge "$arr_length" ]; then
    echo final loop :  ${array[$i]};
    i=0
    echo final loop2:  ${array[$i]};
 
  fi
done

# if online again, break saved images loop and proceed to top loop // loop 2 of 2
if [ $status -eq 0 ]; then
  echo break do 2 of 2
  break
fi
done

##fi

done
 

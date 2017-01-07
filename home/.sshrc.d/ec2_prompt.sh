#!/bin/bash
#Set colour prompt using the name, platform or instance id and avzone

if [ ! -f "$SSHHOME/AWS-INSTID" ]; then
        curl -s --fail --connect-timeout 1 http://169.254.169.254/latest/meta-data/instance-id > $SSHHOME/AWS-INSTID
fi
export INSTID=`cat $SSHHOME/AWS-INSTID`

if [[ -z "${INSTID// }" ]]; then
  export INSTID="-"
fi

if [ ! -f "$SSHHOME/AWS-AVZONE" ]; then
        curl -s --fail --connect-timeout 1 http://169.254.169.254/latest/meta-data/placement/availability-zone > $SSHHOME/AWS-AVZONE
fi
export AVZONE=`cat $SSHHOME/AWS-AVZONE`
if [[ -z "${AVZONE// }" ]]; then
  export AVZONE="-"
fi

PLATFORM=""
if [ -f "$SSHHOME/AWS-PLATFORM" ]; then
        PLATFORM=`cat $SSHHOME/AWS-PLATFORM`
fi
NAME=""
if [ -f "$SSHHOME/AWS-NAME" ]; then
        NAME=`cat $SSHHOME/AWS-NAME`
fi

# Define colours
RED=31
GREEN=32
ORANGE=33
BLUE=34
PURPLE=35
CYAN=36

# Use NAME and PLATFORM if defined - otherwise use the instance ID
# or the availability zone.  Set the platform colour according to the
# platform.

if [[ "$NAME" == "" ]]; then
        NAME=$INSTID
fi
export NAME

if [[ "$PLATFORM" != "" ]]; then
        PLAT=`echo $PLATFORM | tr '[a-z]' '[A-Z]'`
        case $PLAT in
                TEST*|STAGE*)   PLATCOL=$GREEN
                        NAMECOL=$CYAN
                        ;;
                UAT*|PREPROD*)  PLATCOL=$ORANGE
                        NAMECOL=$PURPLE
                        ;;
                LIVE*|PROD*)    PLATCOL=$RED
                        NAMECOL=$BLUE
                        ;;
                *)      PLATCOL=$BLUE
                        NAMECOL=$GREEN
                        ;;
        esac
else
        PLAT=$AVZONE
        PLATCOL=$CYAN
        NAMECOL=$ORANGE
fi
export PLAT
export PLATCOL
export NAMECOL

case $TERM in
    screen-256color)
      PS1="\[\033]0;[$PLAT] $NAME\007\]\[\033[0;${PLATCOL}m\][$PLAT]\[\033[0;38m\] \[\033[0;${NAMECOL}m\]$NAME\[\033[0;38m\] [\u:\W]$ "
      ;;
    vt100)
      PS1="\[\033]0;[$PLAT] $NAME\007\]\[\033[0;${PLATCOL}m\][$PLAT]\[\033[0;38m\] \[\033[0;${NAMECOL}m\]$NAME\[\033[0;38m\] [\u:\W]$ "
      ;;
    xtermc)
      export TERM=xterm
      PS1="\[\033]0;[$PLAT] $NAME\007\]\[\033[0;${PLATCOL}m\][$PLAT]\[\033[0;38m\] \[\033[0;${NAMECOL}m\]$NAME\[\033[0;38m\] [\u:\W]$ "
      ;;
    xterm*)
      PS1="\[\033]0;[$PLAT] $NAME\007\]\[\033[0;${PLATCOL}m\][$PLAT]\[\033[0;38m\] \[\033[0;${NAMECOL}m\]$NAME\[\033[0;38m\] [\u:\W]$ "
      ;;
    *)
      PS1="[\u@$INSTID \W]$ "
      ;;
esac
shopt -s checkwinsize
[ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
export PS1

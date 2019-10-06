#!/bin/bash

# Prepare the cleanup procedure for this script
function cleanup()
{
    kill $monitor_pid 2> /dev/null
    airmon-ng stop wlan0mon
    service network-manager restart

    echo 1 > /sys/class/leds/led0/brightness
    echo 1 > /sys/class/leds/led1/brightness
}


##
# Leds reference for Raspberry Pi 3B
# led1 = red
# led0 = green
##

# Clean led's state
echo none > /sys/class/leds/led0/trigger
echo none > /sys/class/leds/led1/trigger
echo 0 > /sys/class/leds/led0/brightness
echo 0 > /sys/class/leds/led1/brightness

# Turn both leds on and off to show the user that the script has started
echo 1 > /sys/class/leds/led0/brightness
echo 1 > /sys/class/leds/led1/brightness
sleep .5;
echo 0 > /sys/class/leds/led0/brightness
echo 0 > /sys/class/leds/led1/brightness
sleep .5;
echo 1 > /sys/class/leds/led0/brightness
echo 1 > /sys/class/leds/led1/brightness
sleep .5;
echo 0 > /sys/class/leds/led0/brightness
echo 0 > /sys/class/leds/led1/brightness
sleep .5;
echo 1 > /sys/class/leds/led0/brightness
echo 1 > /sys/class/leds/led1/brightness


# Get context info about the current execution
me=$$
start_time=`date +%Y-%m-%d--%H:%M:%S`
mac_local=`cat /sys/class/net/wlan0/address`

# Start a background process to signal us when the execution must stop
(
    sleep 1h
    kill -1 $me
) &

# Kill any applications that may interfere with the packet capturing
airmon-ng check kill

# Start the monitor interface
airmon-ng start wlan0

# Capture packets now
airodump-ng -w rasp-`echo $mac_local`-`echo $start_time` --output-format="pcap" wlan0mon &

# Grab the process ID of the airodump-ng running in the background
monitor_pid=$!

# If this script is killed, kill airodump-ng and restore the original network interface
trap cleanup EXIT

# While airodump-ng is running, blink the leds separately
while kill -0 $monitor_pid 2> /dev/null; do
    echo 1 > /sys/class/leds/led0/brightness;
    echo 0 > /sys/class/leds/led1/brightness;
    sleep 1;
    echo 1 > /sys/class/leds/led1/brightness;
    echo 0 > /sys/class/leds/led0/brightness;
    sleep 1;
done

# If the script gets here, it means that airodump-ng died
# Restore the network funcionality now
cleanup()
# Blink the leds together signaling that something is wrong
while true; do
    echo 1 > /sys/class/leds/led1/brightness;
    echo 1 > /sys/class/leds/led0/brightness;
    sleep 1;
    echo 0 > /sys/class/leds/led1/brightness;
    echo 0 > /sys/class/leds/led0/brightness;
    sleep 1;
done

# Disable the trap on a normal exit
trap - EXIT

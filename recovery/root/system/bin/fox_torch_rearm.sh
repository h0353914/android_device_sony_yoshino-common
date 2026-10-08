#!/system/bin/sh
# The qpnp flash driver clears led_on of every LED in the switch mask each time
# led:switch_0 is turned off, while sysfs still shows the old brightness.
# OrangeFox only writes led:torch_0 + led:switch_0, and with led:torch_1 not
# armed the PMIC reports a short/open fault (led_status1=2) and nothing lights.
# Re-arm led:torch_1 whenever the switch is off, so the next press works.
L=/sys/class/leds
while :; do
    read -r sw < $L/led:switch_0/brightness
    [ "$sw" = "0" ] && echo 120 > $L/led:torch_1/brightness
    sleep 0.2
done

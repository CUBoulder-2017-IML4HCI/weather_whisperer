#!/usr/bin/python

# library for time delay
import time;
# library for controlling pins (GPIO pins)
import RPi.GPIO as GPIO;

# set GPIO pin 7 as output
GPIO.setmode(GPIO.BCM);
GPIO.setup(7, GPIO.OUT);

# loop until user presses Ctrl + C
while True:
        GPIO.output(7, True);
        time.sleep(1);
        GPIO.output(7, False);
        time.sleep(1);



#! /usr/bin/python

# Import the libraries we need
import RPi.GPIO as GPIO
import time

# Set the GPIO mode
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# Set the LED GPIO number
blueLED = 21
greenLED = 20
redLED = 16

# Set the LED GPIO pin as an output
GPIO.setup(redLED, GPIO.OUT)
GPIO.setup(greenLED, GPIO.OUT)
GPIO.setup(blueLED, GPIO.OUT)

# Turn the GPIO pin on
GPIO.output(redLED,128)
time.sleep(2)
GPIO.output(redLED,False)
GPIO.output(greenLED,128)
time.sleep(2)
GPIO.output(greenLED,False)
GPIO.output(blueLED,128)
time.sleep(2)
GPIO.output(blueLED,False)

# Wait 5 seconds
time.sleep(5)

# Turn the GPIO pin off
GPIO.output(redLED,False)
GPIO.output(greenLED,False)
GPIO.output(blueLED,False)

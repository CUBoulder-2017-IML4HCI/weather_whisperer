#! /usr/bin/env python
#
# Fade an LED (or one color of an RGB LED) using GPIO's PWM capabilities.
#
# Usage:
#   sudo python colors.py 255 255 255
#
# @author Jeff Geerling, 2015

#!/usr/bin/python3
import csv
import sys

import numpy as np
from scipy import stats
from sklearn import tree
from sklearn import linear_model, datasets

import time

from collections import Counter
import math
from collections import defaultdict

import operator 
import json

import argparse
import time
#import RPi.GPIO as GPIO


import requests

# LED pin mapping.
red = 16
green = 20
blue = 21
'''
# GPIO setup.
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(red, GPIO.OUT)
GPIO.setup(green, GPIO.OUT)
GPIO.setup(blue, GPIO.OUT)

# Set up colors using PWM so we can control individual brightness.
RED = GPIO.PWM(red, 100)
GREEN = GPIO.PWM(green, 100)
BLUE = GPIO.PWM(blue, 100)
RED.start(0)
GREEN.start(0)
BLUE.start(0)
'''

def learn(features,target):

	X = np.matrix(features)
	print X
	Y = np.matrix(target)
	print Y
	clf = linear_model.LinearRegression()
	clf = clf.fit(X,Y)
	return clf

# Set a color by giving R, G, and B values of 0-255.
def setColor(red,green,blue):
    # Convert 0-255 range to 0-100.
    RED.ChangeDutyCycle(red)
    GREEN.ChangeDutyCycle(green)
    BLUE.ChangeDutyCycle(blue)

def give_me_data(request):
	v = request.json()
	temp = float(v['history']['observations'][0]['tempi'])
	humid = float(v['history']['observations'][0]['hum'])
	pressure = float(v['history']['observations'][0]['pressurei'])
	wind = float(v['history']['observations'][0]['wspdi'])
	print "temp: " + str(temp)
	print "wind: " + str(wind)
	print "pressure: " + str(pressure)
	print "humidity: " + str(humid)
	red = int(raw_input("Give me red value\n"))
	green = int(raw_input("Give me green value\n"))
	blue = int(raw_input("Give me blue value\n"))
	return ([temp,wind,pressure,humid],[red,green,blue])

def generate_data(city,state):
	target = []
	features = []
	#for i in range(1,13):
	for i in range(1,2):
		if i < 10:
			history1 = 'history_20160'+str(i)+'01'
			history2 = 'history_20160'+str(i)+'15'
			r1 = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/'+history1+'/q/'+state+'/'+city+'.json')
			r2 = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/'+history2+'/q/'+state+'/'+city+'.json')

		else:
			history1 = 'history_2016'+str(i)+'01'
			history2 = 'history_2016'+str(i)+'15'
			r1 = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/'+history1+'/q/'+state+'/'+city+'.json')
			r2 = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/'+history2+'/q/'+state+'/'+city+'.json')
		
		features_1, rgb_1 = give_me_data(r1)
		features_2, rgb_2 = give_me_data(r2)
		target.append(rgb_1)
		target.append(rgb_2)
		features.append(features_1)
		features.append(features_2)
		return features,target

def predict(reg_model,city,state):
	r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/'+state+'/'+city+'.json')
	values = r.json()
	temp = float(values["current_observation"]["temp_f"])
	wind = float(values["current_observation"]["wind_mph"])
	pressure = float(values["current_observation"]["pressure_in"])
	humid = float(values["current_observation"]["relative_humidity"].strip('%'))
	closest = reg_model.predict(np.matrix([[temp,wind,pressure,humid]]))
	red = int(np.round(closest[0][0]))
	green = int(np.round(closest[0][1]))
	blue = int(np.round(closest[0][2]))
	print(red,green,blue)
	#setColor(red,green,blue)


if __name__ == "__main__":
	city = raw_input("Give me a city\n")
	state = raw_input("Give me the state\n")
	features,target = generate_data(city,state)
	reg_model = learn(features,target)
	predict(reg_model,city,state) 
	
	'''
	GPIO.cleanup()
	'''

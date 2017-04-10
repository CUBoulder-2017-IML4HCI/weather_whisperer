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
import RPi.GPIO as GPIO
import pyrebase

import requests

#Firebase Configuration
config = {
  "apiKey": "apiKey",
  "authDomain": "weatherwhisperer.firebaseapp.com",
  "databaseURL": "https://weatherwhisperer.firebaseio.com",
  "storageBucket": "weatherwhisperer.appspot.com"
}

firebase = pyrebase.initialize_app(config)

#Firebase Database Intialization
db = firebase.database()

# LED pin mapping.
red = 16
green = 20
blue = 21

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


def learn(features,target):

	X = np.matrix(features)
	print(X)
	Y = np.matrix(target)
	print(Y)
	clf = linear_model.LinearRegression()
	clf = clf.fit(X,Y)
	return clf

# Set a color by giving R, G, and B values of 0-255.
def setColor(r,g,b):
    # Convert 0-255 range to 0-100.
    red = (r/255.0) * 100
    blue = (b/255.0)*100
    green = (g/255.0)*100
    print(red)
    print(green)
    print(blue) 
    RED.ChangeDutyCycle(red)
    GREEN.ChangeDutyCycle(green)
    BLUE.ChangeDutyCycle(blue)

def give_me_data(request,id_):
	v = request.json()
	temp = v['history']['observations'][0]['tempi']
	humid = float(v['history']['observations'][0]['hum'])
	pressure = float(v['history']['observations'][0]['pressurei'])
	wind = float(v['history']['observations'][0]['wspdi'])
	print("temp: " + str(temp))
	print("wind: " + str(wind))
	print("pressure: " + str(pressure))
	print("humidity: " + str(humid))
	db.child("training").child("ID"+str(id_)).update({"temp":temp,"red":-1,"green":-1,"blue":-1})
	'''
	red = int(input("Give me red value\n"))
	green = int(input("Give me green value\n"))
	blue = int(input("Give me blue value\n"))
	'''

def generate_data(city,state):
	target = []
	features = []
	#for i in range(1,13):
	j = 1
	for i in range(1,4):
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
		
		give_me_data(r1,j)
		j=j+1
		give_me_data(r2,j)
		j=j+1
		print("value: ",j)
		db.update({"count":j-1})
	
	time.sleep(5)
	while True:
		if db.child("training/ID"+str(j-1)+"/green").get().val()!=-1:
			print("getting training data")
			for i in range(1,j):
				temp = float(db.child("training/ID"+str(i)+"/temp").get().val())
				r = int(db.child("training/ID"+str(i)+"/red").get().val())
				g = int(db.child("training/ID"+str(i)+"/green").get().val())
				b = int(db.child("training/ID"+str(i)+"/blue").get().val())
				features.append([temp])
				target.append([r,g,b])
			break		
	return features,target

def hard_limits(color):
	if color > 255:
		return 255
	elif color < 0:
		return 0
	else:
		return color

def predict(reg_model,city,state):
	r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/'+state+'/'+city+'.json')
	values = r.json()
	temp = float(values["current_observation"]["temp_f"])
	#wind = float(values["current_observation"]["wind_mph"])
	#pressure = float(values["current_observation"]["pressure_in"])
	#humid = float(values["current_observation"]["relative_humidity"].strip('%'))
	#closest = reg_model.predict(np.matrix([[temp,wind,pressure,humid]]))
	closest = reg_model.predict(np.matrix([[temp]]))
	red = int(np.round(closest[0][0]))
	green = int(np.round(closest[0][1]))
	blue = int(np.round(closest[0][2]))
	red = hard_limits(red)
	green = hard_limits(green)
	blue = hard_limits(blue)
	print(red,green,blue)
	setColor(red,green,blue)


if __name__ == "__main__":
	'''
	city = input("Give me a city\n")
	state = input("Give me the state\n")
	'''
	city = db.child("info/city/city").get().val()
	state = db.child("info/state/state").get().val()
	if city=="Washington D.C." or city == "Washington, D.C." or city=="Washington DC" or city == "Washington, DC":
		city = "Washington"
		state = "DC"
	city = city.replace(" ","_")
	features,target = generate_data(city,state)
	reg_model = learn(features,target)
	on = True
	i = 0
	while on:	
		predict(reg_model,city,state) 
		time.sleep(10)
		if i > 6:
			on = False
		i+=1		
	GPIO.cleanup()
	

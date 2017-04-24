#! /usr/bin/env python
#
# Fade an LED (or one color of an RGB LED) using GPIO's PWM capabilities.
#
# Usage:
#   sudo python colors.py 255 255 255
#
# @author Jeff Geerling, 2015

import csv
import sys

import numpy as np
from scipy import stats
from sklearn import linear_model
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline

import time

from collections import Counter
import math
from collections import defaultdict

import operator 
import json

import argparse
import time
#import RPi.GPIO as GPIO
#import pigpio
import pyrebase

import requests

from collections import defaultdict



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
red = 17
green = 22
blue = 24
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

#pi = pigpio()

'''
Try five different models. Two kinds of linear regression plus polynomial regression with 
degree two, three, and four.
Use the R^2 value to pick the most accurate one
There are so few data points, We didn't want to hold any out for cross validation
and are aware that this makes us prone to overfitting. 
'''
def learn(features,target):
	best_score = 0
	best_model = 0
	X = np.matrix(features)
	Y = np.matrix(target)
	ml = -1

	for i in range(0,5):
		if i==0:
			clf = linear_model.LinearRegression()
			clf = clf.fit(X,Y)
		elif i==1:
			clf = linear_model.Ridge(alpha=0.5)
			clf = clf.fit(X,Y)	
		else:
			clf = make_pipeline(PolynomialFeatures(i), linear_model.Ridge())
			clf = clf.fit(X, Y)

		current_score = clf.score(X,Y)
		print(current_score)
		if abs(current_score)>abs(best_score):
			best_score = current_score
			best_model = clf
			ml = i

	print("Best model: ", ml)	
	return best_model

# Set a color by giving R, G, and B values of 0-255. with GPIO
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

def setColor_Pig(r,g,b):
	pi.set_PWM_dutycycle(red, r)
	pi.set_PWM_dutycycle(green, g)
	pi.set_PWM_dutycycle(blue, b)
	print("Red: ",r)
	print("Green: ",g)
	print("Blue: ",b)

def give_me_data(request,id_):
	v = request.json()
	temp = v['history']['observations'][0]['tempi']
	wind = v['history']['observations'][0]['wspdi']
	weather = v['history']['observations'][0]['conds']
	print("temp_f: " + str(temp))
	print("wind_mph: " + str(wind))
	print("weather: " + str(weather))
	#print("humidity: " + str(humid))
	db.child("training").child("ID"+str(id_)).update({"temp":temp,"wind": wind,\
		"weather": weather,"red":-1,"green":-1,"blue":-1})

def generate_data(city,state,weather_conditions):
	target = []
	features = []
	temps = []
	winds = []
	weathers = []
	#for i in range(1,13):
	j = 1
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
				wind = float(db.child("training/ID"+str(i)+"/wind").get().val())
				weather = weather_conditions[(db.child("training/ID"+str(i)+"/weather").get().val())]
				r = int(db.child("training/ID"+str(i)+"/red").get().val())
				g = int(db.child("training/ID"+str(i)+"/green").get().val())
				b = int(db.child("training/ID"+str(i)+"/blue").get().val())
				features.append([temp,wind,weather])
				temps.append(temp)
				winds.append(wind)
				weathers.append(weather)
				target.append([r,g,b])
			break		
	return features,target,temps,winds,weathers

def hard_limits(color):
	if color > 255:
		return 255
	elif color < 0:
		return 0
	else:
		return color

def test_sample(temp,wind,weather,temps,winds,weathers):
	confident_t = False
	confident_w = False
	confident_conds = False
	for t in temps:
		if abs(t-temp)<10:
			confident_t = True
	for w in winds:
		if abs(w-wind)<10:
			confident_w = True
	if weather in weathers:
		confident_conds = True

	confident = confident_t and confident_w and confident_conds
	return confident

def predict(reg_model,city,state,weather_conditions,temps,winds,weathers):
	
	r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/'+state+'/'+city+'.json')
	values = r.json()
	temp = float(values["current_observation"]["temp_f"])
	wind = float(values["current_observation"]["wind_mph"])
	weather = weather_conditions[values["current_observation"]["weather"]]
	print([temp,wind,weather])
	confident = test_sample(temp,wind,weather,temps,winds,weathers)
	print("Confidence: ", confident)
	if confident:
		closest = reg_model.predict(np.matrix([[temp,wind,weather]]))
		red = int(np.round(closest[0][0]))
		green = int(np.round(closest[0][1]))
		blue = int(np.round(closest[0][2]))
		red = hard_limits(red)
		green = hard_limits(green)
		blue = hard_limits(blue)
		print(red,green,blue)
		#setColor(red,green,blue)
	else:
		#add here about asking users for more info
		red = 0
		green = 0
		blue = 0
		print(red,green,blue)


#load weather descriptions
def load_conditions(filename):
	weather = defaultdict(float)
	conds = open(filename,'r')
	f = 0.2
	for c in conds:
		weather[c.strip('\n')]=f
		f+=0.2

	print(f)
	print(len(weather.keys()))
	return weather



if __name__ == "__main__":
	'''
	city = input("Give me a city\n")
	state = input("Give me the state\n")
	'''
	weather_conditions = load_conditions("weather_conditions.txt")
	#print(weather_conditions)
	#sys.exit()
	
	city = db.child("info/city/city").get().val()
	state = db.child("info/state/state").get().val()
	
	if city=="Washington D.C." or city == "Washington, D.C." or city=="Washington DC" or city == "Washington, DC":
		city = "Washington"
		state = "DC"
	city = city.replace(" ","_")
	features,target,temps,winds,weathers = generate_data(city,state,weather_conditions)
	
	reg_model = learn(features,target)
	predict(reg_model,city,state,weather_conditions,temps,winds,weathers) 
	sys.exit()
	on = True
	i = 0
	while on:	
		predict(reg_model,city,state,weather_conditions,temps,winds,weathers) 
		time.sleep(10)
		if i > 6:
			on = False
		i+=1	

	#pi.stop()	
	#GPIO.cleanup()
	


import time
import json
import requests
import numpy as np
from scipy import stats
from sklearn import tree
import operator 
import json

r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/CA/San_Francisco.json')
values = r.json()
temp_1 = values["current_observation"]["temp_f"]
wind_1 = values["current_observation"]["wind_mph"]
pressure_1 = values["current_observation"]["pressure_in"]
humid_1 = values["current_observation"]["relative_humidity"].strip('%')
red = 1

r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/AK/Fairbanks.json')
values = r.json()
temp_0 = values["current_observation"]["temp_f"]
wind_0 = values["current_observation"]["wind_mph"]
pressure_0 = values["current_observation"]["pressure_in"]
humid_0 = values["current_observation"]["relative_humidity"].strip('%')
blue = 0

X = [[temp_1,wind_1,pressure_1,humid_1],[temp_0,wind_0,pressure_0,humid_0]]
Y = [red,blue]
clf = tree.DecisionTreeClassifier()
clf = clf.fit(X,Y)

while True:
	city = raw_input("Give me a city\n")
	state = raw_input("Give me the state\n")
	print city
	print state
	r = requests.get('http://api.wunderground.com/api/8f5846f4c43e4050/conditions/q/'+state+'/'+city+'.json')
	values = r.json()
	temp = values["current_observation"]["temp_f"]
	wind = values["current_observation"]["wind_mph"]
	pressure = values["current_observation"]["pressure_in"]
	humid = values["current_observation"]["relative_humidity"].strip('%')
	closest = clf.predict([[temp,wind,pressure,humid]])
	if closest[0]==0:
		print "Like Fairbanks, AK"
		time.sleep(2)
	elif closest[0]==1:
		print "Like San Francisco, CA"
		time.sleep(2)

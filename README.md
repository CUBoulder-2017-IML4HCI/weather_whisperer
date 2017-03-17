# weather_whisperer
To run this project configure your Beaglebone Green Wireless board as described in Board Setup

Make sure the board is connected to wifi as describe [here](http://wiki.seeed.cc/SeeedStudio_BeagleBone_Green_Wireless/)

Install the below dependencies

Make sure you are the root user on the board by executing the command sudo su

Run: python led.py

Give me the name of a City

Enter the name of a city whose name does **NOT** contain any spaces (i.e. Portland, **but NOT** Los Angeles)

Give me the name of the State

Enter the two letter state abbreviation of the city you entered above (i.e. OR)

## Install Python Dependencies
sudo apt-get install python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose

sudo apt-get install build-essential python-dev python-setuptools

sudo apt-get install libatlas-dev libatlas3gf-base

sudo apt-get install python-sklearn

## Board Setup
See [this website](http://wiki.seeed.cc/SeeedStudio_BeagleBone_Green_Wireless/) for board diagram 

Red LED -> GPIO_50, P9_14

Blue LED -> GPIO_51, P9_16

Ground -> DGND, P8_2

Remember to include resistors with your LEDs to avoid burning out your LEDS
![alt text](https://github.com/CUBoulder-2017-IML4HCI/weather_whisperer/blob/master/IMG_2607.JPG "Board")

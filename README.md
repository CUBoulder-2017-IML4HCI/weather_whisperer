# weather_whisperer
This project uses machine learning to determine the color of an RGB LED strip controlled by an iPhone App and a Raspberry Pi.
We put the RGB LED strip inside a laser cut lamp (see below for pictures)
The user determines what color the lamp should be based on different temperatures, wind speends, and weather conditions (i.e. Partly Cloudy) by selecting different colors in the iPhone App. After the user has entered a small set of data points (currently 5) the lamp is ready to be turned on. The confidence of the color of the lamp is displayed to user as "Confident" or "Not Confident" depending on how similar the current weather is to weather in the training data. The user has the ability to add training points and retrain the algorithm. 

# Install Instructions 
First obtain a weather underground API key [here.](https://www.wunderground.com/weather/api/)

## Raspbery Pi
This code is written for Python 3 and assumes that the Pis are connected to internet via wifi

### Install the below dependencies
Install tool for python and various mathematical and machine learning libraries
~~~~ 
sudo apt-get install -y python3-pip 
sudo apt-get install python3-numpy python3-scipy python3-matplotlib
sudo apt-get install build-essential python3-dev python3-setuptools
sudo apt-get install libatlas-dev libatlas3gf-base
sudo pip3 install -U scikit-learn
~~~~
Pyrebase interfaces with Firebase's REST API
~~~~
sudo pip3 install Pyrebase
~~~~
The pigpio library which allows control of the GPIO on the Raspberry Pi
~~~~
wget abyz.co.uk/rpi/pigpio/pigpio.zip
unzip pigpio.zip
cd PIGPIO
make
sudo make install
~~~~

## iPhone

## Board Setup

# Instructions for Use
Once the install and assembly instructions above have been completed the system is ready to be run. 
Log into the Pi controlling the weather station and the Pi controlling the RGB LED strip. In the following
code snippet in ~~~ wunderground_pi_firebase.py ~~~ update the host to be the ip address of the Pi controlling
the weather station and make sure that the port is the same as the port in the simple_server.py file on the Pi
controlling the weather station.

```python
def get_local_temp():
	s = socket.socket()        
	host = '192.168.20.100'# ip of raspberry pi 
	port = 12345               
	s.connect((host, port))
	temp = s.recv(1024)
	print(temp)
	s.close()
	return temp.decode('utf-16')
 ```
 
In Firebase, change pi_command to 'off' and led_state to 'OFF'
 ## Pi Controlling Weather Station
 Run the following command ~~~ python3 simple_server.py ~~~
 ## Pi Controllng RGB LED Strip
 Run the following commands to access the GPIO pins and start the program
 ~~~
 sudo pigpiod
 python3 wunderground_pi_firebase.py [API KEY]
 ~~~
 ## iPhone App
 1. Enter the name of a city in the United States making sure to capitalize the first letter of each word in the city name 
 2. Enter the two letter state abbreviation
 3. Press the save button
 4. Press to the color button select the color to display for the given weather data
 5. Press the save button
 6. Repeat steps 4 and 5 until the 'Add Color' text changes to 'Ready to Train'
 7. Press the 'ON/OFF' button
 8. The RGB LED Strip should now turn on
 9. If the lamp is not confident in the predict color 'Not Confident' will be displayed
 10. Add the current data as a training point as described in Steps 4 and 5
 11. Enjoy customizing the lamp
 

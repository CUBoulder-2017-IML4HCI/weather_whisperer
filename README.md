# weather_whisperer
This project uses machine learning to determine the color of an RGB LED strip controlled by an iPhone App and a Raspberry Pi.
We put the RGB LED strip inside a laser cut lamp (see below for pictures)
The user determines what color the lamp should be based on different temperatures, wind speends, and weather conditions (i.e. Partly Cloudy) by selecting different colors in the iPhone App. After the user has entered a small set of data points (currently 5) the lamp is ready to be turned on. The confidence of the color of the lamp is displayed to user as "Confident" or "Not Confident" depending on how similar the current weather is to weather in the training data. The user has the ability to add training points and retrain the algorithm. 

# Install Instructions 
First obtain a weather underground API key [here.](https://www.wunderground.com/weather/api/)
Next create a database in [firebase](https://firebase.google.com/) copying the below format. 
Make sure the names of the fields are the same.

![alt text][firebase]

[firebase]: https://github.com/CUBoulder-2017-IML4HCI/weather_whisperer/blob/master/firebase.png "Firebase Picture"

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
The current edition of this app is for IOS and is built using Xcode. Xcode can be downloaded for free on all Apple computers. Xcode is not available for non-apple devices. 
First, if you do not already have xcode downloaded on your computer, go to the app store and download the program or go to this link https://itunes.apple.com/us/app/xcode/id497799835?mt=12

After you have downloaded Xcode, download the application named 'ww_app' by cloning or downloading this repository. After this is finished, go into the ww_app folder and open the file called 'ww_app.xcworkspace'. At this point you are ready to run the app! In the top left corner of Xcode, you will see a play button and stop button. Next to this you can see what simulator is currently being used and have the option to switch to a new simulator. Hit the play arrow button when you are ready to run the app.
If you would like to make changes to the app, all files can be found in the project navigator column on the left side of Xcode. Layout changes can be made using 'Main.storyboard' and changes to the code can be made by editing any of the '.swift' files.


## Board Setup

# Instructions for Use
Once the install and assembly instructions above have been completed the system is ready to be run. 
Log into the Pi controlling the weather station and the Pi controlling the RGB LED strip. In the following
code snippet in *wunderground_pi_firebase.py* update the host to be the ip address of the Pi controlling
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
In the following code snippet in *wunderground_pi_firebase.py* update the Firebase API configuration to that of your Firebase
```python
#Firebase Configuration
config = {
  "apiKey": "apiKey",
  "authDomain": "weatherwhisperer.firebaseapp.com",
  "databaseURL": "https://weatherwhisperer.firebaseio.com",
  "storageBucket": "weatherwhisperer.appspot.com"
}
```
In Firebase, change pi_command to 'off' and led_state to 'OFF'
 ## Pi Controlling Weather Station
 Run the following command 
 ~~~ 
 python3 simple_server.py 
 ~~~
 
 ## Pi Controllng RGB LED Strip
 Run the following commands to access the GPIO pins and start the program
 ~~~
 sudo pigpiod
 python3 wunderground_pi_firebase.py [API KEY]
 ~~~
 
 ## Hardware for RGB LED Strip

 ![alt text](https://github.com/CUBoulder-2017-IML4HCI/weather_whisperer/blob/master/circuit_pi.jpg "Schematic")


To understand these instructions you will have to understand the shcematic and pictures shown above. It is best you use a breadboard first to connect everything then solder to a perfboard. Please read through these instructions first before attempting to build this. 

Power Supply and Potentiometer:
 1. The ideal voltage for a RGB LED strip is 10 volts/9volts. If you have one of these skip to the P-Mosfets instructions.
 2. With a voltage supply 11 volts and above continue reading. Anything lower than 8 volts will reduce brightness of the LED       strip. 
 3. You will need a potentiometer that will need to be adjusted to 9.8 kΩ.
 4. If you use resistors instead, they will melt! 
 5. Connect the power and the ground to the potentiometer. 
 6. Then connect the input to the RGB power wire. 

P-Mosfets: 
 1. Make sure that these are P-Mosfets, if they are N-Mosfets the PWM signals will be switched.
 	ex: Green = 0 for a P-Mosfet then it would be Green = 255 for an N Mosfet.
 2. Check the datasheet for your specific Mosfet.
 3. Wiring:
 	Each gate is connected to one of the colored RGB wires.
	Each source is connected to each GPIO pin (corresponding to a color) connected to the raspberry pi.
	Each drain is connected to ground.
 4. If mosfets heat up something is wired wrong. 
 
LED strip:
 1. The power wire is connected to power.
 2. The red wire is connected to the gate of a mosfet.
 3. The blue wire is connected to the gate of a different mosfet.
 4. The green wire is connected to the gate of another different mosfet.

Raspberry Pi:
 1. Red wire = GPIO 20
 2. Blue wire = GPIO 21
 3. Green wire = GPIO 26
 4. Ground = GPIO 6
 
Check coloring:
 1. Run sudo pigpiod
 2. Then type
 3. pigs p 20 255 (Red ON)
 4. pigs p 20 0   (Red OFF)
 5. pigs p 21 255 (Blue ON)
 6. pigs p 21 0   (Blue OFF)
 7. pigs p 26 255 (Green ON)
 8. pigs p 20 0   (Green OFF)

Soldering:
 1. You will need solder, a soldering iron and a perf board.
 2. Follow the schematic and solder it to a perf board.

Debugging:
 1. Check that you did not solder something wrong.
 2. Check that the power is at the desired voltage.
 3. Check that the potentiometer is at 9.8 kΩ.
 4. Check everything is in the right GPIO pin.
 5. Check coloring through the terminal.
 
Tips:
 1. If you have a larger perfboard and want to use a small part of it use pliers to snap it.
 2. Use wirestrippers or your teeth instead of scissors to strip wires. 
 3. Practice soldering before you try it on a perfboard. If wires are mixed with solder the the project will not work and you       may fry your raspberry pi.
 4. Have something that the led strip can wrap around for better lighting inside the lamp. 

 
 ## iPhone App
 If you enter Boulder, CO the temperature will be taken from Pi Weather Station instead of Weather Underground
 1. Enter the name of a city in the United States making sure to capitalize the first letter of each word in the city name 
 2. Enter the two letter state abbreviation
 3. Press the save button, weather information for that city will now appear on the main page of the app
 4. Press the color button select the color to display for the given weather data
 5. Press the save button
 6. Repeat steps 4 and 5 until the 'Add Color' text changes to 'Ready to Train'
 7. Press the 'ON/OFF' button
 8. The RGB LED Strip should now turn on
 9. If the lamp is not confident in the predict color 'Not Confident' will be displayed
 10. Add the current data as a training point as described in Steps 4 and 5
 11. Enjoy customizing the lamp
 

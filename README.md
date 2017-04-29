# weather_whisperer
This project uses machine learning to determine the color of an RGB LED strip controlled by an iPhone App and a Raspberry Pi.
We put the RGB LED strip inside a laser cut lamp (see below for pictures)
The user determines what color the lamp should be based on different temperatures, wind speends, and weather conditions (i.e. Partly Cloudy) by selecting different colors in the iPhone App. After the user has entered a small set of data points (currently 5) the lamp is ready to be turned on. The confidence of the color of the lamp is displayed to user as "Confident" or "Not Confident" depending on how similar the current weather is to weather in the training data. The user has the ability to add training points and retrain the algorithm. 

# Install Instructions 

## Raspbery Pi
This code is written for Python 3. 

### Install the below dependencies
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

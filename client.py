
import os
from time import sleep
from sense_hat import SenseHat
import socket

host = '192.168.20.101'
port = 5569

# The CPU temperature
fake_temp = 10
sense = SenseHat()

def setupSocket():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    return s

def sendReceive(s, message):
    s.send(str.encode(message))
    reply = s.recv(1024)
    print("We have received a reply")
    print("Send closing message.")
    s.send(str.encode("EXIT"))
    s.close()
    reply = reply.decode('utf-8')
    return reply

def transmit(message):
    s = setupSocket()
    response = sendReceive(s, message)
    return response

def get_cpu_temp():
    res = os.popen("vcgencmd measure_temp").readline()
    t = float(res.replace("temp=","").replace("'C\n",""))
    return(t)

# The averag eof readings
def average_temp(x):
    if not hasattr(average_temp, "t"):
     average_temp.t = [x,x,x]
    average_temp.t[2] = average_temp.t[1]
    average_temp.t[1] = average_temp.t[0]
    average_temp.t[0] = x
    xs = (average_temp.t[0]+average_temp.t[1]+average_temp.t[2])/3
    return(xs)

def getTemp() :
    t1 = sense.get_temperature_from_humidity()
    t2 = sense.get_temperature_from_pressure()
    cpu = get_cpu_temp()
    humidity = sense.get_humidity()
    pressure = sense.get_pressure()

  # calculates the real temperature compesating CPU heating
    t_av = (t1+t2)/2
    temperature = t_av - ((cpu-t_av)/1.5)
    temperature = average_temp(temperature)
    return (temperature)

def temp_reading():
    print("Reading")
    temp = float(getTemp())
    #temp_send = temp.read(1024)
    #s.send(str.encode("temp"))
    print("Temperature:" + str(temp))
    if temp > float(fake_temp):
        message = ("Temperature:" + str(temp))
        #print(message)       
        #message = temp
        print("DATA reading")
        response = transmit(message)
        print(response)

  #print(" temperature: %.1f  humidity(): = %.1f  pressure(inHg): %.1f" % (temperature, humidity, press$
  #time.sleep(5)

  #command = input("temperature: %.1f  humidity(): = %.1f  pressure(inHg): %.1f" % (temperature, humidi$

  #s.send(str.encode(command))
  #reply = s.recv(1024)
  #print(reply.decode('utf-8'))

#s.close()

while True:
     try:
        temp_reading()
        sleep(5)
     except:
        break

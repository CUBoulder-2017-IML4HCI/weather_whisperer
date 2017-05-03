mport socket
import os
import time
from sense_hat import SenseHat

s = socket.socket()
host = '' #ip of raspberry pi
port = 5568
s.bind((host, port))

s.listen(5)

# The CPU temperature
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


sense = SenseHat()

def actual_temperature():
  t1 = sense.get_temperature_from_humidity()
  t2 = sense.get_temperature_from_pressure()
  cpu = get_cpu_temp()
  humidity = sense.get_humidity()
  pressure = sense.get_pressure()

  # calculates the real temperature compesating CPU heating
  t_av = (t1+t2)/2
  temperature = t_av - ((cpu-t_av)/1.5)
  celcius = average_temp(temperature)
  temperature = 9.0/5.0 * celcius + 32
  temperature = round(temperature)
  print(" temperature: %.1f  humidity(): = %.1f  pressure(inHg): %.1f" % (temperature, humidity, pressure))
  time.sleep(5)
  return str(temperature)
    
    

while True: 
  c, addr = s.accept()
  print ('Got connection from',addr)
  temp = actual_temperature()
  c.send(temp.encode('utf-16'))
  c.close()


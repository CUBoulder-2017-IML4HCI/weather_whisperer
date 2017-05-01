import socket

s = socket.socket()
host = '10.0.0.178' #ip of raspberry pi
port = 12345
s.bind((host, port))

s.listen(5)

def get_temp():
  return "68"

while True:
  c, addr = s.accept()
  print ('Got connection from',addr)
  temp = get_temp()
  c.send(temp.encode('utf-8'))
  c.close()

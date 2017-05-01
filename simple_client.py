import socket               

s = socket.socket()        
host = '10.0.0.178'# ip of raspberry pi, change this the ip of the server pi
port = 12345               
s.connect((host, port))
temp = s.recv(1024)
temp = temp.decode('utf-8')
print(temp)
s.close()
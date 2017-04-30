
import socket
import RPi.GPIO as GPIO;
#from Fading import checkKey
#from blink import blink

host = ''
port = 5569

GPIO.setmode(GPIO.BCM);
GPIO.setup(7, GPIO.OUT);

storedValue = "Yo, what's up?"


def blink():
        GPIO.output(7, True);
        time.sleep(1);
        GPIO.output(7, False);
        time.sleep(1)

def setupServer():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print("Socket created.")
    try:
        s.bind((host, port))
    except socket.error as msg:
        print(msg)
    print("Socket bind complete.")
    return s

def setupConnection():
    s.listen(1) # Allows one connection at a time.
    conn, address = s.accept()
    print("Connected to: " + address[0] + ":" + str(address[1]))
    return conn

def GET():
    reply = storedValue
    return reply

def REPEAT(dataMessage):
    reply = dataMessage[1]
    return reply

def dataTransfer(conn):
    # A big loop that sends/receives data until told not to.
    while True:
        # Receive the data
        data = conn.recv(1024) # receive the data
        data = data.decode('utf-8')
        print(data)
        # Split the data such that you separate the command
        # from the rest of the data.
        dataMessage = data.split(' ', 1)
        command = dataMessage[0]
        if command == 'GET':
            reply = GET()
        elif command == 'REPEAT':
            reply = REPEAT(dataMessage)
           # blink()
        elif command == 'blink':
            blink()
           # checkKey() 
            reply = 'LED was on'
        elif command == 'EXIT':
            print("Our client has left us :(")
            break
        elif command == 'KILL':
            print("Our server is shutting down.")
            s.close()
            break
        else:
            reply = 'Unknown Command'
        # Send the reply back to the client
        #conn.sendall(str.encode('ascii'))
        conn.sendall(str.encode(reply))
        print("Data has been sent!")
    conn.close()


s = setupServer()



while True:
     try:
        conn = setupConnection()
        dataTransfer(conn)
        #print(message)
        sleep(5)
        #blink()
        #checkKey()
     except:
        break


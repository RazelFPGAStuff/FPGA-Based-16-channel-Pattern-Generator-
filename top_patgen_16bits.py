import serial
import time

ser =serial.Serial(port='COM15',timeout=3)
#ser = serial.Serial('/dev/ttyUSB0')  # open serial port
print(ser.name)         # check which port was really used
ser.baudrate = 115200

ser.write(b'\x80') #STOP
ser.write(b'\x04') #STOP
time.sleep(0.3)

ser.write(b'\x00') #SET CLOCK
ser.write(b'\x51')

ser.write(b'\x80') #LOAD
ser.write(b'\x02')

ser.write(b'\x00') #vector number -1 is the last data
ser.write(b'\x05')

ser.write(b'\x55')
ser.write(b'\x55')
time.sleep(0.3)

ser.write(b'\xAA')
ser.write(b'\xAA')
time.sleep(0.3)

ser.write(b'\x0F')
ser.write(b'\x0F')
time.sleep(0.3)

ser.write(b'\xF0')
time.sleep(0.3)
ser.write(b'\x01')
time.sleep(0.3)

ser.write(b'\xF0')
time.sleep(0.3)
ser.write(b'\x5A')
time.sleep(0.3)

ser.write(b'\x80') #RUN
ser.write(b'\x03') #RUN
time.sleep(0.3)




# for i in range(124):

    # i_bytes = i.to_bytes(1,byteorder='big')
    # time.sleep(0.3)
    # print (i_bytes)
    # ser.write(i_bytes)
    # time.sleep(0.3)
   

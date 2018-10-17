##############################################################################
#EEE3096S lab 6
#Group 2A
#David Fransch (FRNDAV011)
#Richard Powrie (PWRRIC001)
#due 23 Oct 2018
##############################################################################

import RPi.GPIO as GPIO
import time

import spidev
import os
import sys

##############################################################################
#Define
##############################################################################
####BCM numbering
#switches
button1  = 4  #reset

#ADC
SPICLK   = 11          #connected to ADC pin 13
SPIMOSI  = 10          #connected to ADC pin 11
SPIMISO  = 9           #connected to ADC pin 12
SPICS    = 8           #select ADC by pulling low, default high for no comms
"""ADC set up as follows:
Channel Peripheral ADC pin Selection bits
CH0     Pot        1       1000
   Set up in single ended mode (common ground between them)
DGND    GND        9
   connected to ground
   http://www.hit.bme.hu/~papay/edu/Acrobat/GndADCs.pdf explains why they're connected together
CS/SHDN ADCselect  10
   selected by pulling low
Din     MOSI       11
Dout    MISO       12
CLK     SCLK       13
AGND    GND        14
   connected to ground
VREF    3v3        15
   equation: V_in = digital_output_code*V_ref/1024
                  = digital_output_code*3.3/1024
VDD     3v3        16
"""
#channels
pot = 0

#delay
t1       = 0.5   #every 500ms

#output
outHeading = "Time      Timer     Pot    \n"#format: 2 spaces between columns
outLines   = "---------------------------"
outString  = outHeading+outLines

decimal_places = 3
delay = t1
timerStart = time.time()

##############################################################################
#SPI setup
##############################################################################
spi = spidev.SpiDev()
spi.open(0,0)#bus #0 and device #0
spi.max_speed_hz=1000000

##############################################################################
#GPIO setup
##############################################################################
#use GPIO BCM pin numbering
GPIO.setmode(GPIO.BCM)              

#set up buttons as digital inputs, using pull-up resistors
GPIO.setup(button1, GPIO.IN, pull_up_down=GPIO.PUD_UP)

##############################################################################
#functions
##############################################################################
def GetData(channel):#channel = integer 0-7
    adc = spi.xfer2([1,(8+channel)<<4,0])#send three bits with single ended mode selected
    data = ((adc[1]&3)<<8) + adc[2]
    return data

# function to convert data to voltage level, 
# places: number of decimal places needed 
def ConvertVolts(data,places): 
    volts = (data * 3.3) / float(1023)
    volts = round(volts,places)
    return volts

#threaded callbacks
def callback1(button1):#reset
    global timerStart
    timerStart = time.time()#reset timer
    os.system("clear")
    print("Reset pressed")
    print(outString)
    
    
GPIO.add_event_detect(button1, GPIO.FALLING, callback=callback1,bouncetime=400)
    
##############################################################################
#main
##############################################################################
print(outString)


timerStart = time.time()
while True:
    try:
        
        
        #read pot
        pot_data = GetData(pot)
        Vpot = ConvertVolts(pot_data,decimal_places)
        
        #create output string
        currentTime = time.strftime("%H:%M:%S",time.localtime())        
        timer = time.strftime("%H:%M:%S",time.gmtime(time.time()-timerStart))
        output_string = currentTime + "  " + timer+"  " +("%3.1f V" % Vpot)
        
        print(output_string)
                    
        #delay
        time.sleep(delay)
        
    except KeyboardInterrupt:
        spi.close()
        break
    
    
        
#release GPIO pins from operation
GPIO.cleanup()

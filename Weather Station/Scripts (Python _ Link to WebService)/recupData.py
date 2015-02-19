#!/usr/bin/python

import serial
import MySQLdb
import time
import urllib
import urllib2

DEVICE = '/dev/ttyACM0'
BAUD = 9600
db = MySQLdb.connect("localhost", "root", "daweather", "daweather")
curs=db.cursor()
ser = serial.Serial(DEVICE, BAUD, timeout = 2.0)
print(ser)

#Url à contacter pour les requetes http des alertes
url = 'http://daweather.ovh/webservice/station/alert'

alertTemp = 0
alertPre = 0
alertHumi = 0
alertSpeed = 0
alertRain = 0

while 1:
    donnee=str(ser.readline())
    #print(donnee)

    curs.execute ("SELECT email,private_key from station;")
    elems = curs.fetchone()
    email = elems[0]
    private_key = elems[1]

    #Recuperation des donnees
    try:
        ardString = donnee.split(";")
        temp = ardString[0]
        humi = ardString[1]
        pre = ardString[2]
        speed = ardString[3]
        direct = ardString[4]
        rain = ardString[5]

        #Conversion en float
        try:
            tempFloat = float(temp)
            humiFloat = float(humi)
            preFloat = float(pre)
            speedFloat = float(speed)
            directFloat = float(direct)
            rainFloat = float(rain)
        except:
            print "conversion exception"

        #Requetes HTTP des alertes
        if (tempFloat < -80 or tempFloat > 80):
            if (alertTemp == 0):
                alertTemp = 1
                try:
                    arg = {'email':email, 'privatekey':private_key, 'alert':'temperature'}
                    data = urllib.urlencode(arg)
                    request = urllib2.Request(url,data)
                    response = urllib2.urlopen(request)
                    print response.read()
                except:
                    print("temperature http request exception")
        else:
            alertTemp = 0

        if (preFloat < 870 or preFloat > 1100):
            if (alertPre == 0):
                alertPre = 1
                try:
                    arg = {'email':email, 'privatekey':private_key, 'alert':'pressure'}
                    data = urllib.urlencode(arg)
                    request = urllib2.Request(url,data)
                    urllib2.urlopen(request)
                except:
                    print("pression http request exception")
        else:
            alertPre = 0

        if (humiFloat < 0 or humiFloat > 100):
            if (alertHumi == 0):
                alertHumi = 1
                try:
                    arg = {'alert':'humidity'}
                    data = urllib.urlencode(arg)
                    request = urllib2.Request(url,data)
                    urllib2.urlopen(request)
                except:
                    print("humidity http request exception")
        else:
            alertHumi = 0

        if (speedFloat < 0 or speedFloat > 300):
            if (alertSpeed == 0):
                alertSpeed = 1
                try:
                    arg = {'alert':'speed'}
                    data = urllib.urlencode(arg)
                    request = urllib2.Request(url,data)
                    urllib2.urlopen(request)
                except:
                    print("wind speed http request exception")
        else:
            alertSpeed = 0

        if (rainFloat < 0 or rainFloat > 50):
            if (alertRain == 0):
                alertRain = 1
                try:
                    arg = {'alert':'rain'}
                    data = urllib.urlencode(arg)
                    request = urllib2.Request(url,data)
                    urllib2.urlopen(request)
                except:
                    print("rain http request exception")
        else:
            alertRain = 0

        #Affichage
        print("temperature: ", temp)
        print("humidite: ", humi)
        print("pression: ", pre)
        print("vitesse: ", speed)
        print("direction: ", direct)
        print("pluie: ", rain)
        print("==========================")

        #Insertion dans BDD
        try:
            curs.execute ("INSERT INTO s_data_temp(date,valeur,STATION_idStation) VALUES(NOW(), "+temp+", 1);")
            curs.execute ("INSERT INTO s_data_hum(date,valeur,STATION_idStation) VALUES(NOW(), "+humi+", 1);")
            curs.execute ("INSERT INTO s_data_pre(date,valeur,STATION_idStation) VALUES(NOW(), "+pre+", 1);")
            curs.execute ("INSERT INTO s_data_vent(date,valeur,direction,STATION_idStation) VALUES(NOW(), "+speed+", "+direct+", 1);")
            curs.execute ("INSERT INTO s_data_pluie(date,valeur,STATION_idStation) VALUES(NOW(), "+rain+", 1);")
            
            #simulation des données
            #curs.execute ("INSERT INTO s_data_temp(date,valeur,STATION_idStation) VALUES(NOW(),RAND()*10, 1);")
            #curs.execute ("INSERT INTO s_data_hum(date,valeur,STATION_idStation) VALUES(NOW(), RAND()*10, 1);")
            #curs.execute ("INSERT INTO s_data_pre(date,valeur,STATION_idStation) VALUES(NOW(), RAND()*10, 1);")
            #curs.execute ("INSERT INTO s_data_vent(date,valeur,direction,STATION_idStation) VALUES(NOW(), (RAND()*10)*3.6, RAND()*100, 1);")
            #curs.execute ("INSERT INTO s_data_pluie(date,valeur,STATION_idStation) VALUES(NOW(), RAND()*10, 1);")
            db.commit()
        except:
            print "insertion exception"
    except:
            print "En attente de donnees"

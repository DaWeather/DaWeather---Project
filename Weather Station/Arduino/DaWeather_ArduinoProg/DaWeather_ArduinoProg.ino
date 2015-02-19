#include <LiquidCrystal.h>   // Importation de la librairie de l'ecran LCD
#include <SFE_BMP180.h>     // Importation de la librairie du capteur BMP180 (humidite et temperature)
#include <dht.h>           // Importation de la librairie du capteur DHT (pression atmospherique)
#include <Wire.h>         // Importation de la librairie des connecteurs de l'Arduino pour le capteurs de pression

#define DHT22_PIN       8      // Pin Digital 8 - Pression
#define PIN_ANEMOMETER  2      // Pin Digital 2 - Anemometre
#define PIN_RAINGAUGE   3      // Pin Digital 3 - Pluviometre
#define PIN_VANE        0      // Pin Analog 0 - Direction du vent

#define ALTITUDE 40.00         // Definition de l'altitude pour calcul de la pression atmospherique

// Definition des constantes necessaires aux calculs des valeurs meteorologiques
#define MSECS_CALC_WIND_SPEED 1000
#define MSECS_CALC_WIND_DIR   1000
#define MSECS_CALC_RAIN_FALL  1000

#define uint  unsigned int
#define ulong unsigned long

volatile int numRevsAnemometer = 0; // Incremented in the interrupt
volatile int numDropsRainGauge = 0; // Incremented in the interrupt
ulong nextCalcSpeed;                // When we next calc the wind speed
ulong nextCalcDir;                  // When we next calc the direction
ulong nextCalcRain;                 // When we next calc the rain drop
ulong time;                         // Millis() at each start of loop().

// ADC readings:
#define NUMDIRS 8
ulong   adc[NUMDIRS] = {26, 45, 77, 118, 161, 196, 220, 256};

// Definition des directions du vent en fonction de la valeur trouvee
char *strVals[NUMDIRS] = {"W","NW","N","SW","NE","S","SE","E"};
byte dirOffset=0;

// Declaration des variables utiles aux capteurs
dht DHT;
SFE_BMP180 pressure;

double baseline; // baseline pressure

//const int switchPin = 6;
int switchState = 0;
int prevSwitchState = 0;
int reply;

char status;
double T,P,p0,a;

//
// Initialization
//
void setup() {
  Serial.begin(9600);
  attachInterrupt(0, countAnemometer, FALLING);
  attachInterrupt(1, countRainGauge, FALLING);
}

//
// Main loop
//
void loop() { 
  float windSpeed;
  float windDirect;
  float rain;
  float pre;
  int chk = DHT.read22(DHT22_PIN);
  
  // Calculating the speed and wind direction + rain + pressure
  pre = pression();
  windSpeed = calcWindSpeed();
  windDirect = calcWindDir();
  rain = calcRainFall();
  
  // Envoi des données sur le port USB
  Serial.print(DHT.temperature);
  Serial.print(";");
  Serial.print(DHT.humidity);
  Serial.print(";");
  Serial.print(pre);
  Serial.print(";");
  Serial.print(windSpeed);
  Serial.print(";");
  Serial.print(windDirect);
  Serial.print(";");
  Serial.print(rain);
  Serial.println();
  
  // Délai de 2 secondes
  delay(2000);
}


//=======================================================
// Calcul de la pression
//=======================================================
double pression(){
  pressure.begin();
  status = pressure.startTemperature();
  if (status != 0)
  {
    delay(status);
    status = pressure.getTemperature(T); // calculating the temperature
    if (status != 0)
    {
      status = pressure.startPressure(3);
      if (status != 0)
      {
        // Wait for the measurement to complete:
        delay(status);
        status = pressure.getPressure(P,T); 
        if (status != 0)
        {
          p0 = pressure.sealevel(P,ALTITUDE); // calculating the pressure with sealevel and altitude
          a = pressure.altitude(P,p0); // retrieving the actual altitude with the pressure
        }
        else Serial.println("error retrieving pressure measurement\n");
      }
      else Serial.println("error starting pressure measurement\n");
    }
    else Serial.println("error retrieving temperature measurement\n");
  }
  else Serial.println("error starting temperature measurement\n");
  
  return p0;
}

//=======================================================
// Interrupt handler for anemometer. Called each time the reed
// switch triggers (one revolution).
//=======================================================
void countAnemometer() {
   numRevsAnemometer++;
}

//=======================================================
// Interrupt handler for rain gauge. Called each time the reed
// switch triggers (one drop).
//=======================================================
void countRainGauge() {
   numDropsRainGauge++;
}

//=======================================================
// Calcul de la direction du vent
//=======================================================
float calcWindDir() {
   int val;
   byte x, reading;
   float result;

   val = analogRead(PIN_VANE);
   val >>=2;      // Shift to 255 range
   reading = val;

   for (x=0; x<NUMDIRS; x++) {
      if (adc[x] >= reading)
         break;
   }
   x = (x + dirOffset) % 8;   // Adjust for orientation
   result = x;
   return result;
}


//=======================================================
// Calcul de la vitesse du vent
// 1 rev/sec = 1.492 mph = 2.40114125 kph
//=======================================================
float calcWindSpeed() {
   int x, iSpeed;
   // This will produce kph * 10
   long speed = 24011;
   speed *= numRevsAnemometer;

   speed /= MSECS_CALC_WIND_SPEED;
   iSpeed = speed;      // Need this for formatting below
   x = iSpeed / 10;
   x = iSpeed % 10;

   numRevsAnemometer = 0;        // Reset counter
   
   return iSpeed;
}

//=======================================================
// Calcul de la pluviometrie
// 1 bucket = 0.2794 mm
//=======================================================
float calcRainFall() {
   int x, iVol;
   float result;
   
   // This will produce mm * 10000
   long vol = 2794; // 0.2794 mm
   vol *= numDropsRainGauge;
   
   vol /= MSECS_CALC_RAIN_FALL;
   iVol = vol;         // Need this for formatting below

   x = iVol / 10000;
   x = iVol % 10000;

   result = x;
   result = result / 100;
   
   numDropsRainGauge = 0;        // Reset counter
   
   return result;
}

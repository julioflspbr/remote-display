#ifndef ARDUINO_H
#define ARDUINO_H

#define INVALID			 -1

#define INPUT 				0
#define OUTPUT 				1
#define INPUT_PULLUP 	2

#define LOW						0
#define HIGH					1

//
// Mocked Arduino methods
//
void pinMode(int pin, int mode);
void digitalWrite(int pin, int value, bool force = false);
int digitalRead(int pin, bool force = false);
void delay(int);

//
// Spies
//
int getPinMode(int pin);
int getDelay(void);

#endif


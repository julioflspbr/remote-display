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
// Mock Arduino registers
//
extern unsigned char PINA;
extern unsigned char PORTA;
extern unsigned char DDRA;

extern unsigned char PINB;
extern unsigned char PORTB;
extern unsigned char DDRB;

extern unsigned char PINC;
extern unsigned char PORTC;
extern unsigned char DDRC;

extern unsigned char PIND;
extern unsigned char PORTD;
extern unsigned char DDRD;

extern unsigned char PINE;
extern unsigned char PORTE;
extern unsigned char DDRE;

extern unsigned char PINF;
extern unsigned char PORTF;
extern unsigned char DDRF;

extern unsigned char PING;
extern unsigned char PORTG;
extern unsigned char DDRG;

extern unsigned char PINH;
extern unsigned char PORTH;
extern unsigned char DDRH;

extern unsigned char PINJ;
extern unsigned char PORTJ;
extern unsigned char DDRJ;

extern unsigned char PINK;
extern unsigned char PORTK;
extern unsigned char DDRK;

extern unsigned char PINL;
extern unsigned char PORTL;
extern unsigned char DDRL;

//
// Spies
//
int getPinMode(int pin);
int getDelay(void);

#endif


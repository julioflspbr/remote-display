#include "Arduino.h"
#include <map>

using namespace std;

unsigned char PINA;
unsigned char PORTA;
unsigned char DDRA;

unsigned char PINB;
unsigned char PORTB;
unsigned char DDRB;

unsigned char PINC;
unsigned char PORTC;
unsigned char DDRC;

unsigned char PIND;
unsigned char PORTD;
unsigned char DDRD;

unsigned char PINE;
unsigned char PORTE;
unsigned char DDRE;

unsigned char PINF;
unsigned char PORTF;
unsigned char DDRF;

unsigned char PING;
unsigned char PORTG;
unsigned char DDRG;

unsigned char PINH;
unsigned char PORTH;
unsigned char DDRH;

unsigned char PINJ;
unsigned char PORTJ;
unsigned char DDRJ;

unsigned char PINK;
unsigned char PORTK;
unsigned char DDRK;

unsigned char PINL;
unsigned char PORTL;
unsigned char DDRL;

struct Pin {
	int mode;
	int value;
}; 
int desiredDelay = -1;
static map<int, Pin> pins;

void pinMode(int pin, int mode) {
	int value = arc4random() % 2;
	pins[pin] = {mode, value};
}

int getPinMode(int pinNumber) {
	auto pin = pins.find(pinNumber);
	if (pin == pins.end()) {
		return INVALID;
	}
	return pin->second.mode;
}

void digitalWrite(int pin, int value, bool force) {
	auto match = pins.find(pin);
	if (match == pins.end()) {
		return;
	}

	if (force) {
		match->second.value = value;
	} else {
		switch (match->second.mode) {
			case OUTPUT:
				match->second.value = value;
				break;
			default:
				break;
		}
	}
}

int digitalRead(int pin, bool force) {
	auto match = pins.find(pin);
	if (match == pins.end()) {
		return arc4random() % 2;
	}

	if (force) {
		return match->second.value;
	} else {
		switch (match->second.mode) {
			case INPUT:
			case INPUT_PULLUP:
				return match->second.value;
			default:
				return INVALID;
		}
	}
}

void delay(int desired) {
	desiredDelay = desired;
}

int getDelay() {
	return desiredDelay;
}


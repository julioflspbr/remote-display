#include "Arduino.h"
#include <map>

using namespace std;

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


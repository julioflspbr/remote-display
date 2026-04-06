#include "Arduino.h"

#include <map>
#include <stdlib.h>

struct Pin {
	PinMode mode;
	PinValue value;
}; 

using namespace std;

static map<int, Pin> pins;

void pinMode(int pin, PinMode mode) {
	PinValue value = static_cast<PinValue>(arc4random() % 2);
	pins.insert({pin, {mode, value}});
}

void digitalWrite(int pin, PinValue value) {
	auto match = pins.find(pin);
	if (match == pins.end()) {
		return;
	}
	switch (match->second.mode) {
		case INPUT:
		case INPUT_PULLUP:
			match->second.value = value;
			break;
		default:
			break;
	}
}

PinValue digitalRead(int pin) {
	auto match = pins.find(pin);
	if (match == pins.end()) {
		return (PinValue)(arc4random() % 2);
	}
	return match->second.value;
}


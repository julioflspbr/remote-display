#include <iostream>

#include "test.h"
#include "Arduino.h"

using namespace std;

bool compare(unsigned short int value, array<int, 8> pins) {
	for (int i = 7; i >= 0; --i) {
		int pin = pins[i];
		bool pinValue = (digitalRead(pin) == HIGH);
		bool comparison = (value & 0x1);
		if (pinValue != comparison) {
			return false;
		}
		value = value >> 1;
	}
	return true;
}

void assert(bool condition, string message) {
	if (!condition) {
		cerr << message << endl;
		exit(-1);
	}
}


#ifndef ARDUINO_H
#define ARDUINO_H

enum PinMode {
	INPUT, INPUT_PULLUP, OUTPUT
};

enum PinValue {
	LOW, HIGH
};

void pinMode(int, PinMode);
void digitalWrite(int, PinValue);
PinValue digitalRead(int);

#endif


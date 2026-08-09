#include <Arduino.h>
#include <Display/Adapter.h>

using namespace Display;
using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

//
// Definitions
//
#define BUSY_FLAG_DATA_BIT 7

//
// Helper definitions
//
void setPinModes(const Pin data[BYTE_SIZE], int pinMode);
void setDataPins(const Pin data[BYTE_SIZE], Byte byte);
inline void clear(const Pin data[BYTE_SIZE]);
inline void setEntryMode(const Pin data[BYTE_SIZE], CursorDirection direction, bool autoShift);
inline void setDisplayControl(const Pin data[BYTE_SIZE], bool isDisplayOn, bool isCursorOn, bool isBlinkOn);
inline void set(const Pin data[BYTE_SIZE], FunctionSet::DataLength dataLength, FunctionSet::Lines lines, FunctionSet::FontSize fontSize);
inline void setDDRAMAddress(const Pin data[BYTE_SIZE], Line line);
inline void writeCharacter(char character);

//
// Display::Adapter implementation
//
Adapter::Adapter::Adapter(const Pins& pins): pins(pins) {
	pinMode(pins.rs, OUTPUT);
	pinMode(pins.rw, OUTPUT);
	pinMode(pins.e, OUTPUT);
}

void Adapter::Adapter::sleep(int milliseconds) {
	delay(milliseconds);
}

void Adapter::Adapter::setRegisterSelect(RegisterSelect registerSelect) {
	int pinValue;

	switch (registerSelect) {
		case RegisterSelect::Command:
			pinValue = LOW;
			break;
		case RegisterSelect::Data:
			pinValue = HIGH;
			break;
	}

	digitalWrite(this->pins.rs, pinValue);
}

void Adapter::Adapter::setReadWrite(ReadWrite readWrite) {
	int pinValue;

	switch (readWrite) {
		case ReadWrite::Write:
			pinValue = LOW;
			setPinModes(pins.data, OUTPUT);
			break;
		case ReadWrite::Read:
			pinValue = HIGH;
			setPinModes(pins.data, INPUT);
			break;
	}

	digitalWrite(this->pins.rw, pinValue);
}

void Adapter::Adapter::setReadyToExecute(bool isEnabled) {
	int pinValue = isEnabled ? HIGH : LOW;
	digitalWrite(this->pins.e, pinValue);
}

void Adapter::Adapter::setCommand(Command command) {
	this->setCommand(command, {});
}

void Adapter::Adapter::setCommand(Command command, Parameters parameters) {
	switch (command) {
		case Command::Clear: {
			clear(this->pins.data);
			break;
		}
		case Command::EntryMode: {
			auto entryMode = parameters.entryMode;
			setEntryMode(this->pins.data, entryMode.direction, entryMode.autoShift);
			break;
		}
		case Command::DisplayControl: {
			auto displayControl = parameters.displayControl;
			setDisplayControl(this->pins.data, displayControl.isDisplayOn, displayControl.isCursorOn, displayControl.isBlinkOn);
			break;
		}
		case Command::FunctionSet: {
			auto functionSet = parameters.functionSet;
			set(this->pins.data, functionSet.dataLength, functionSet.lines, functionSet.fontSize);
			break;
		}
		case Command::DDRAMAddress: {
			auto ddramAddress = parameters.ddramAddress;
			setDDRAMAddress(this->pins.data, ddramAddress.line);
			break;
		}
	}
}

void Adapter::Adapter::setCharacter(char character) {
	setDataPins(this->pins.data, static_cast<Byte>(character));
}

bool Adapter::Adapter::isBusy() const {
	return digitalRead(this->pins.data[BUSY_FLAG_DATA_BIT]) == HIGH;
}

//
// Helper implementations
//

void setPinModes(const Pin data[BYTE_SIZE], int mode) {
	for (int i = 0; i < BYTE_SIZE; ++i) {
		pinMode(data[i], mode);
	}
}

void setDataPins(const Pin data[BYTE_SIZE], Byte byte) {
	for (int i = 0; i < BYTE_SIZE; ++i) {
		bool value = byte & 0x1;
		int pinValue = value ? HIGH : LOW;
		byte = byte >> 1;
		digitalWrite(data[i], pinValue);
	}
}

void clear(const Pin data[BYTE_SIZE]) {
	setDataPins(data, 0x1);
}

void setEntryMode(const Pin data[BYTE_SIZE], CursorDirection d, bool autoShift) {
	Byte byte = 0x4;
	int direction = static_cast<int>(d);
	byte = byte | (autoShift 			<< 0);
	byte = byte | (direction			<< 1);
	setDataPins(data, byte);
}

void setDisplayControl(const Pin data[BYTE_SIZE], bool isDisplayOn, bool isCursorOn, bool isBlinkOn) {
	Byte byte = 0x8;
	byte = byte | (isBlinkOn 			<< 0);
	byte = byte | (isCursorOn 		<< 1);
	byte = byte | (isDisplayOn 		<< 2);
	setDataPins(data, byte);
}

void set(const Pin data[BYTE_SIZE], FunctionSet::DataLength dl, FunctionSet::Lines l, FunctionSet::FontSize fs) {
	Byte byte = 0x20;
	int dataLength = static_cast<int>(dl);
	int lines = static_cast<int>(l);
	int fontSize = static_cast<int>(fs);

	byte = byte | (fontSize 			<< 2);
	byte = byte | (lines 					<< 3);
	byte = byte | (dataLength 		<< 4);
	setDataPins(data, byte);
}

void setDDRAMAddress(const Pin data[BYTE_SIZE], Line line) {
	Byte byte = 0x80;
	int address = static_cast<int>(line);
	byte = byte | address;
	setDataPins(data, byte);
}


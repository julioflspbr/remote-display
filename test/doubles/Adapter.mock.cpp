#include "Adapter.mock.h"

using namespace std;
using namespace Display;

using Pins = Adapter::Pins;
using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

struct BitMask {
	static constexpr unsigned long long HighPin = 0x8000000000000000;
	static constexpr unsigned long long LowPin = 0x7FFFFFFFFFFFFFFF;
	static constexpr unsigned long long DataPins = 0xFF00000000000000;
};

//
// Private definitions
//

void markPin(unsigned long long& pinState, int pin, bool value);
void setDataPins(unsigned long long& pinState, const Pin data[BYTE_SIZE], Byte byte);
inline void clear(unsigned long long& pinState, const Pin data[BYTE_SIZE]);
inline void setEntryMode(unsigned long long& pinState, const Pin data[BYTE_SIZE], CursorDirection direction, bool autoShift);
inline void setDisplayControl(unsigned long long& pinState, const Pin data[BYTE_SIZE], bool isDisplayOn, bool isCursorOn, bool isBlinkOn);
inline void set(unsigned long long& pinState, const Pin data[BYTE_SIZE], FunctionSet::DataLength, FunctionSet::Lines, FunctionSet::FontSize);
inline void setDDRAMAddress(unsigned long long& pinState, const Pin data[BYTE_SIZE], Line line);

//
// Public implementations
//

Adapter::Adapter::Adapter(const Pins& pins): _pins(pins) {
}

void Adapter::Adapter::sleep(int milliseconds) {
	if (_isEnabled) {
		_pinLog.push(_pinState);
	}

	// 0x40 not used by us, so we're reusing it to store and load delay
	// caveat: delays have to be less than 48; that's fine, sine we're testing very low sleep times
	Byte byte = 0x40;
	byte |= (0x3F & milliseconds);
	_pinState = static_cast<unsigned long long>(byte) << ((sizeof(_pinState) - sizeof(char)) * 8 - (*_pins.data - 1));
	_isEnabled = false; // by the fact that in the line above we are clearing the Execution flag
	_pinLog.push(_pinState);
}

void Adapter::Adapter::setRegisterSelect(RegisterSelect registerSelect) {
	bool pinValue;

	switch (registerSelect) {
		case RegisterSelect::Command:
			pinValue = false;
			break;
		case RegisterSelect::Data:
			pinValue = true;
			break;
	}

	markPin(_pinState, _pins.rs, pinValue);
}

void Adapter::Adapter::setReadWrite(ReadWrite readWrite) {
	bool pinValue;

	switch (readWrite) {
		case ReadWrite::Write:
			pinValue = false;
			break;
		case ReadWrite::Read:
			pinValue = true;
			break;
	}

	markPin(_pinState, _pins.rw, pinValue);
}

void Adapter::Adapter::setReadyToExecute(bool isEnabled) {
	if (_isEnabled != isEnabled) {
		_pinLog.push(_pinState);
	}

	markPin(_pinState, _pins.e, isEnabled);
	_isEnabled = isEnabled;
}

void Adapter::Adapter::setCommand(Command command) {
	this->setCommand(command, {});
}

void Adapter::Adapter::setCommand(Command command, Parameters parameters) {
	switch (command) {
		case Command::Clear: {
			clear(_pinState, _pins.data);
			break;
		}
		case Command::EntryMode: {
			auto entryMode = parameters.entryMode;
			setEntryMode(_pinState, _pins.data, entryMode.direction, entryMode.autoShift);
			break;
		}
		case Command::DisplayControl: {
			auto displayControl = parameters.displayControl;
			setDisplayControl(_pinState, _pins.data, displayControl.isDisplayOn, displayControl.isCursorOn, displayControl.isBlinkOn);
			break;
		}
		case Command::FunctionSet: {
			auto functionSet = parameters.functionSet;
			set(_pinState, _pins.data, functionSet.dataLength, functionSet.lines, functionSet.fontSize);
			break;
		}
		case Command::DDRAMAddress: {
			auto address = parameters.ddramAddress;
			setDDRAMAddress(_pinState, _pins.data, address.line);
			break;
		}
	}
}

void Adapter::Adapter::setCharacter(char character) {
	setDataPins(_pinState, _pins.data, character);
}

bool Adapter::Adapter::isBusy() const {
	Adapter& adapter = const_cast<Adapter&>(*this);
	return adapter._busyCount-- > 0;
}

queue<unsigned long long> Adapter::Adapter::flushLog() {
	_pinLog.push(_pinState);
	auto copy = _pinLog;
	_pinLog = queue<unsigned long long>();
	return copy;
}

int Adapter::Adapter::delay(queue<unsigned long long>& pinLog) {
	if (pinLog.empty()) {
		return 0;
	}
	auto pinState = pinLog.front();
	Byte byte = (pinState & (BitMask::DataPins >> (*_pins.data - 1))) >> ((sizeof(pinState) - sizeof(Byte)) * 8 - (*_pins.data - 1));
	pinLog.pop();

	// let's test the delay command bit flag
	if (!(byte & 0x40)) {
		return 0;
	}

	// remove the delay bit flag from the number
	return (byte & 0x3F);
}

void Adapter::Adapter::setBusyCount(int count) {
	_busyCount = count;
}

//
// Private implementations
//
unsigned long long rotateRight(unsigned long long source, int shift) {
	return (source << ((sizeof(source) * 8) - (shift - 1))) | (source >> (shift - 1));
}

void markPin(unsigned long long& pinState, int pin, bool value) {
	if (value) {
		pinState |= rotateRight(BitMask::HighPin, pin);
	} else {
		pinState &= rotateRight(BitMask::LowPin, pin);
	}
}

void setDataPins(unsigned long long& pinState, const Pin data[BYTE_SIZE], Byte byte) {
	for (int i = 0; i < BYTE_SIZE; ++i) {
		bool pinValue = byte & 0x1;
		markPin(pinState, data[i], pinValue);
		byte >>= 1;
	}
}

void clear(unsigned long long& pinState, const Pin data[BYTE_SIZE]) {
	setDataPins(pinState, data, 0x1);
}

void setEntryMode(unsigned long long& pinState, const Pin data[BYTE_SIZE], CursorDirection d, bool autoShift) {
	Byte byte = 0x4;
	int direction = static_cast<int>(d);
	byte |= (autoShift 			<< 0);
	byte |= (direction			<< 1);
	setDataPins(pinState, data, byte);
}

void setDisplayControl(unsigned long long& pinState, const Pin data[BYTE_SIZE], bool isDisplayOn, bool isCursorOn, bool isBlinkOn) {
	Byte byte = 0x8;
	byte |= (isBlinkOn 			<< 0);
	byte |= (isCursorOn 		<< 1);
	byte |= (isDisplayOn 		<< 2);
	setDataPins(pinState, data, byte);
}

void set(unsigned long long& pinState, const Pin data[BYTE_SIZE], FunctionSet::DataLength dl, FunctionSet::Lines l, FunctionSet::FontSize fs) {
	Byte byte = 0x20;
	int dataLength = static_cast<int>(dl);
	int lines = static_cast<int>(l);
	int fontSize = static_cast<int>(fs);

	byte |= (fontSize 			<< 2);
	byte |= (lines 					<< 3);
	byte |= (dataLength 		<< 4);
	setDataPins(pinState, data, byte);
}

void setDDRAMAddress(unsigned long long& pinState, const Pin data[BYTE_SIZE], Line line) {
	Byte byte = 0x80;
	int address = static_cast<int>(line);
	byte |= address;
	setDataPins(pinState, data, byte);
}


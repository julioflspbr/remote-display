#include "Adapter.mock.h"

using namespace std;
using namespace Display;

using Pins = Adapter::Pins;
using Port = Adapter::Port;
using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

//
// Private definitions
//

void markPin(unsigned short& pinState, int pin, bool value);
void setData(unsigned short& pinState, Byte byte);
inline void clear(unsigned short& pinState);
inline void setEntryMode(unsigned short& pinState, CursorDirection direction, bool autoShift);
inline void setDisplayControl(unsigned short& pinState, bool isDisplayOn, bool isCursorOn, bool isBlinkOn);
inline void set(unsigned short& pinState, FunctionSet::DataLength, FunctionSet::Lines, FunctionSet::FontSize);
inline void setDDRAMAddress(unsigned short& pinState, Line line);

//
// Public implementations
//

template<Port P> Adapter::Adapter<P>::Adapter(const Pins& pins): _pins(pins) {
}

template<Port P> void Adapter::Adapter<P>::sleep(int milliseconds) {
	// 0x40 not used by us, so we're reusing it to store and load delay
	// caveat: delays have to be less than 48; that's fine, sine we're testing very low sleep times
	Byte byte = 0x40;
	byte |= (0x3F & milliseconds);
	setData(_pinState, byte);
	_pinLog.push(_pinState);
}

template<Port P> void Adapter::Adapter<P>::setRegisterSelect(RegisterSelect registerSelect) {
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

template<Port P> void Adapter::Adapter<P>::setReadWrite(ReadWrite readWrite) {
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

template<Port P> void Adapter::Adapter<P>::setReadyToExecute(bool isEnabled) {
	if (_isEnabled != isEnabled) {
		_pinLog.push(_pinState);
	}

	markPin(_pinState, _pins.e, isEnabled);
	_isEnabled = isEnabled;
}

template<Port P> void Adapter::Adapter<P>::setCommand(Command command) {
	this->setCommand(command, {});
}

template<Port P> void Adapter::Adapter<P>::setCommand(Command command, Parameters parameters) {
	switch (command) {
		case Command::Clear: {
			clear(_pinState);
			break;
		}
		case Command::EntryMode: {
			auto entryMode = parameters.entryMode;
			setEntryMode(_pinState, entryMode.direction, entryMode.autoShift);
			break;
		}
		case Command::DisplayControl: {
			auto displayControl = parameters.displayControl;
			setDisplayControl(_pinState, displayControl.isDisplayOn, displayControl.isCursorOn, displayControl.isBlinkOn);
			break;
		}
		case Command::FunctionSet: {
			auto functionSet = parameters.functionSet;
			set(_pinState, functionSet.dataLength, functionSet.lines, functionSet.fontSize);
			break;
		}
		case Command::DDRAMAddress: {
			auto address = parameters.ddramAddress;
			setDDRAMAddress(_pinState, address.line);
			break;
		}
	}
}

template<Port P> void Adapter::Adapter<P>::setCharacter(char character) {
	setData(_pinState, character);
}

template<Port P> bool Adapter::Adapter<P>::isBusy() const {
	Adapter& adapter = const_cast<Adapter&>(*this);
	return adapter._busyCount-- > 0;
}

template<Port P> queue<unsigned short> Adapter::Adapter<P>::flushLog() {
	_pinLog.push(_pinState);
	auto copy = _pinLog;
	_pinLog = queue<unsigned short>();
	return copy;
}

template<Port P> void Adapter::Adapter<P>::setBusyCount(int count) {
	_busyCount = count;
}

//
// Private implementations
//
void markPin(unsigned short& pinState, int pin, bool value) {
	unsigned short mask = (1 << (sizeof(unsigned char) * 8 + pin - 1));
	if (value) {
		pinState |= mask;
	} else {
		pinState &= ~mask;
	}
}

void setData(unsigned short& pinState, Byte byte) {
	pinState = (pinState & 0xFF00) | (0x00FF & byte);
}

void clear(unsigned short& pinState) {
	setData(pinState, 0x1);
}

void setEntryMode(unsigned short& pinState, CursorDirection d, bool autoShift) {
	Byte byte = 0x4;
	int direction = static_cast<int>(d);
	byte |= (autoShift 			<< 0);
	byte |= (direction			<< 1);
	setData(pinState, byte);
}

void setDisplayControl(unsigned short& pinState, bool isDisplayOn, bool isCursorOn, bool isBlinkOn) {
	Byte byte = 0x8;
	byte |= (isBlinkOn 			<< 0);
	byte |= (isCursorOn 		<< 1);
	byte |= (isDisplayOn 		<< 2);
	setData(pinState, byte);
}

void set(unsigned short& pinState, FunctionSet::DataLength dl, FunctionSet::Lines l, FunctionSet::FontSize fs) {
	Byte byte = 0x20;
	int dataLength = static_cast<int>(dl);
	int lines = static_cast<int>(l);
	int fontSize = static_cast<int>(fs);

	byte |= (fontSize 			<< 2);
	byte |= (lines 					<< 3);
	byte |= (dataLength 		<< 4);
	setData(pinState, byte);
}

void setDDRAMAddress(unsigned short& pinState, Line line) {
	Byte byte = 0x80;
	int address = static_cast<int>(line);
	byte |= address;
	setData(pinState, byte);
}

template struct Adapter::Adapter<Port::A>;
template struct Adapter::Adapter<Port::B>;
template struct Adapter::Adapter<Port::C>;
template struct Adapter::Adapter<Port::D>;
template struct Adapter::Adapter<Port::E>;
template struct Adapter::Adapter<Port::F>;
template struct Adapter::Adapter<Port::G>;
template struct Adapter::Adapter<Port::H>;
template struct Adapter::Adapter<Port::J>;
template struct Adapter::Adapter<Port::K>;
template struct Adapter::Adapter<Port::L>;

#include <Arduino.h>
#include <Display/Adapter.h>

using namespace Display;
using Port = Adapter::Port;
using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

//
// Helper definitions
//
template<Port P> inline void setPortMode(int pinMode);
template<Port P> inline Byte data(void);
template<Port P> inline void setData(Byte byte);
template<Port P> inline void clear(void);
template<Port P> inline void setEntryMode(CursorDirection direction, bool autoShift);
template<Port P> inline void setDisplayControl(bool isDisplayOn, bool isCursorOn, bool isBlinkOn);
template<Port P> inline void set(FunctionSet::DataLength dataLength, FunctionSet::Lines lines, FunctionSet::FontSize fontSize);
template<Port P> inline void setDDRAMAddress(Line line);

//
// Display::Adapter implementation
//
template<Port P> Adapter::Adapter<P>::Adapter(const Pins& pins): pins(pins) {
	pinMode(pins.rs, OUTPUT);
	pinMode(pins.rw, OUTPUT);
	pinMode(pins.e, OUTPUT);
}

template<Port P> void Adapter::Adapter<P>::sleep(int milliseconds) {
	delay(milliseconds);
}

template<Port P> void Adapter::Adapter<P>::setRegisterSelect(RegisterSelect registerSelect) {
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

template<Port P> void Adapter::Adapter<P>::setReadWrite(ReadWrite readWrite) {
	int pinValue;

	switch (readWrite) {
		case ReadWrite::Write:
			pinValue = LOW;
			setPortMode<P>(OUTPUT);
			break;
		case ReadWrite::Read:
			pinValue = HIGH;
			setPortMode<P>(INPUT);
			break;
	}

	digitalWrite(this->pins.rw, pinValue);
}

template<Port P> void Adapter::Adapter<P>::setReadyToExecute(bool isEnabled) {
	int pinValue = isEnabled ? HIGH : LOW;
	digitalWrite(this->pins.e, pinValue);
}

template<Port P> void Adapter::Adapter<P>::setCommand(Command command) {
	this->setCommand(command, {});
}

template<Port P> void Adapter::Adapter<P>::setCommand(Command command, Parameters parameters) {
	switch (command) {
		case Command::Clear: {
			clear<P>();
			break;
		}
		case Command::EntryMode: {
			auto entryMode = parameters.entryMode;
			setEntryMode<P>(entryMode.direction, entryMode.autoShift);
			break;
		}
		case Command::DisplayControl: {
			auto displayControl = parameters.displayControl;
			setDisplayControl<P>(displayControl.isDisplayOn, displayControl.isCursorOn, displayControl.isBlinkOn);
			break;
		}
		case Command::FunctionSet: {
			auto functionSet = parameters.functionSet;
			set<P>(functionSet.dataLength, functionSet.lines, functionSet.fontSize);
			break;
		}
		case Command::DDRAMAddress: {
			auto ddramAddress = parameters.ddramAddress;
			setDDRAMAddress<P>(ddramAddress.line);
			break;
		}
	}
}

template<Port P> void Adapter::Adapter<P>::setCharacter(char character) {
	setData<P>(static_cast<Byte>(character));
}

template<Port P> bool Adapter::Adapter<P>::isBusy() const {
	return data<P>() & 0x80;
}

//
// Helper implementations
//

template<> void setPortMode<Port::A>(int mode) {
	DDRA = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::B>(int mode) {
	DDRB = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::C>(int mode) {
	DDRC = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::D>(int mode) {
	DDRD = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::E>(int mode) {
	DDRE = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::F>(int mode) {
	DDRF = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::G>(int mode) {
	DDRG = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::H>(int mode) {
	DDRH = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::J>(int mode) {
	DDRJ = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::K>(int mode) {
	DDRK = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> void setPortMode<Port::L>(int mode) {
	DDRL = (mode == OUTPUT ? 0xFF : 0x00);
}

template<> Byte data<Port::A>() {
	return PINA;
}

template<> Byte data<Port::B>() {
	return PINB;
}

template<> Byte data<Port::C>() {
	return PINC;
}

template<> Byte data<Port::D>() {
	return PIND;
}

template<> Byte data<Port::E>() {
	return PINE;
}

template<> Byte data<Port::F>() {
	return PINF;
}

template<> Byte data<Port::G>() {
	return PING;
}

template<> Byte data<Port::H>() {
	return PINH;
}

template<> Byte data<Port::J>() {
	return PINJ;
}

template<> Byte data<Port::K>() {
	return PINK;
}

template<> Byte data<Port::L>() {
	return PINL;
}

template<> void setData<Port::A>(Byte byte) {
	PORTA = byte;
}

template<> void setData<Port::B>(Byte byte) {
	PORTB = byte;
}

template<> void setData<Port::C>(Byte byte) {
	PORTC = byte;
}

template<> void setData<Port::D>(Byte byte) {
	PORTD = byte;
}

template<> void setData<Port::E>(Byte byte) {
	PORTE = byte;
}

template<> void setData<Port::F>(Byte byte) {
	PORTF = byte;
}

template<> void setData<Port::G>(Byte byte) {
	PORTG = byte;
}

template<> void setData<Port::H>(Byte byte) {
	PORTH = byte;
}

template<> void setData<Port::J>(Byte byte) {
	PORTJ = byte;
}

template<> void setData<Port::K>(Byte byte) {
	PORTK = byte;
}

template<> void setData<Port::L>(Byte byte) {
	PORTL = byte;
}

template<Port P> void clear() {
	setData<P>(0x1);
}

template<Port P> void setEntryMode(CursorDirection d, bool autoShift) {
	Byte byte = 0x4;
	int direction = static_cast<int>(d);
	byte = byte | (autoShift 			<< 0);
	byte = byte | (direction			<< 1);
	setData<P>(byte);
}

template<Port P> void setDisplayControl(bool isDisplayOn, bool isCursorOn, bool isBlinkOn) {
	Byte byte = 0x8;
	byte = byte | (isBlinkOn 			<< 0);
	byte = byte | (isCursorOn 		<< 1);
	byte = byte | (isDisplayOn 		<< 2);
	setData<P>(byte);
}

template<Port P> void set(FunctionSet::DataLength dl, FunctionSet::Lines l, FunctionSet::FontSize fs) {
	Byte byte = 0x20;
	int dataLength = static_cast<int>(dl);
	int lines = static_cast<int>(l);
	int fontSize = static_cast<int>(fs);

	byte = byte | (fontSize 			<< 2);
	byte = byte | (lines 					<< 3);
	byte = byte | (dataLength 		<< 4);
	setData<P>(byte);
}

template<Port P> void setDDRAMAddress(Line line) {
	Byte byte = 0x80;
	int address = static_cast<int>(line);
	byte = byte | address;
	setData<P>(byte);
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

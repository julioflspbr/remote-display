#include <test.h>
#include <Arduino.h>
#include <Display/Adapter.h>

#include "AdapterTests.h"

using namespace Display;

using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

void expect(int pins[8], char value, std::string&& message);

Tests* Tests::sut = new AdapterTests;

static Display::Adapter::Pins testPins = {1, 2, 3, {4, 5, 6, 7, 8, 9, 10, 11}};

AdapterTests::AdapterTests() : Tests("Display::Adapter") {
}

void AdapterTests::run() {
	this->testAdapterConstruction();
	this->testSleep();
	this->testSetRegisterSelect();
	this->testSetReadWrite();
	this->testSetReadyToExecute();
	this->testClear();
	this->testSetEntryMode();
	this->testSetDisplayControl();
	this->testFunctionSet();
	this->testSetDDRAMAddress();
	this->testWriteCharacter();
	this->testIsBusy();
}

void AdapterTests::testAdapterConstruction() {	
	// given
	int mode;

	pinMode(1, INPUT);
	pinMode(2, INPUT_PULLUP);
	pinMode(3, INPUT);

	// when
	(Adapter::Adapter(testPins));

	// then
	mode = getPinMode(1); expect(mode == OUTPUT, "Pin 1 is not OUTPUT");
	mode = getPinMode(2); expect(mode == OUTPUT, "Pin 2 is not OUTPUT");
	mode = getPinMode(3); expect(mode == OUTPUT, "Pin 3 is not OUTPUT");
}

void AdapterTests::testSleep() {
	// given
	int waitTime = 20;
	Adapter::Adapter adapter(testPins);

	// when
	adapter.sleep(waitTime);

	// then
	expect(getDelay() == waitTime, "The sleep and delay times don't match");
}

void AdapterTests::testSetRegisterSelect() {
	// given
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);
	digitalWrite(testPins.rs, HIGH, true); // initial state, inverted from the first expectation
	
	// when
	adapter.setRegisterSelect(RegisterSelect::Command);
	// then
	expect(digitalRead(testPins.rs, true) == LOW, "RS pin is not correctly set, COMMAND should be LOW");

	// when
	adapter.setRegisterSelect(RegisterSelect::Data);
	// then
	expect(digitalRead(testPins.rs, true) == HIGH, "RS pin is not correctly set, COMMAND should be HIGH");
}

void AdapterTests::testSetReadWrite() {
	// given
	int mode;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	pinMode(4, INPUT_PULLUP);
	pinMode(5, INPUT);
	pinMode(6, INPUT_PULLUP);
	pinMode(7, INPUT);
	pinMode(8, INPUT_PULLUP);
	pinMode(9, INPUT);
	pinMode(10, INPUT_PULLUP);
	pinMode(11, INPUT);

	digitalWrite(testPins.rw, HIGH, true); // initial state, inverted from the first expectation
	
	// when
	adapter.setReadWrite(ReadWrite::Write);
	// then
	expect(digitalRead(testPins.rw, true) == LOW, "RW pin is not correctly set, WRITE should be LOW");
	mode = getPinMode(4); expect(mode == OUTPUT, "Pin 4 is not OUTPUT");
	mode = getPinMode(5); expect(mode == OUTPUT, "Pin 5 is not OUTPUT");
	mode = getPinMode(6); expect(mode == OUTPUT, "Pin 6 is not OUTPUT");
	mode = getPinMode(7); expect(mode == OUTPUT, "Pin 7 is not OUTPUT");
	mode = getPinMode(8); expect(mode == OUTPUT, "Pin 8 is not OUTPUT");
	mode = getPinMode(9); expect(mode == OUTPUT, "Pin 9 is not OUTPUT");
	mode = getPinMode(10); expect(mode == OUTPUT, "Pin 10 is not OUTPUT");
	mode = getPinMode(11); expect(mode == OUTPUT, "Pin 11 is not OUTPUT");

	// when
	adapter.setReadWrite(ReadWrite::Read);
	// then
	expect(digitalRead(testPins.rw, true) == HIGH, "RW pin is not correctly set, WRITE should be HIGH");
	mode = getPinMode(4); expect(mode == INPUT, "Pin 4 is not OUTPUT");
	mode = getPinMode(5); expect(mode == INPUT, "Pin 5 is not OUTPUT");
	mode = getPinMode(6); expect(mode == INPUT, "Pin 6 is not OUTPUT");
	mode = getPinMode(7); expect(mode == INPUT, "Pin 7 is not OUTPUT");
	mode = getPinMode(8); expect(mode == INPUT, "Pin 8 is not OUTPUT");
	mode = getPinMode(9); expect(mode == INPUT, "Pin 9 is not OUTPUT");
	mode = getPinMode(10); expect(mode == INPUT, "Pin 10 is not OUTPUT");
	mode = getPinMode(11); expect(mode == INPUT, "Pin 11 is not OUTPUT");
}

void AdapterTests::testSetReadyToExecute() {
	// given
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);
	digitalWrite(testPins.e, LOW, true); // initial state, inverted from the first expectation

	// when
	adapter.setReadyToExecute(true);
	// then
	expect(digitalRead(testPins.e, true) == HIGH, "E pin is not correctly set, it should become HIGH");

	// when
	adapter.setReadyToExecute(false);
	// then
	expect(digitalRead(testPins.e, true) == LOW, "E pin is not correctly set, it should become LOW");
}

void AdapterTests::testClear() {
	// given
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	// when
	adapter.setCommand(Command::Clear);
	// then
	expect(testPins.data, 0x1, "The CLEAR command byte is not correctly set");
}

void AdapterTests::testSetEntryMode() {
	// given
	Parameters params;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	// when setting cursor decrement and no display shift
	params.entryMode = { CursorDirection::Increment, false };
	adapter.setCommand(Command::EntryMode, params);
	// then
	expect(testPins.data, 0x6, "Entry Mode set wrong for cursor direction INCREMENT and NO DISPLAY AUTO SHIFT");
}

void AdapterTests::testSetDisplayControl() {
	// given
	Parameters params;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	// when setting diplay on
	params.displayControl = { true, false, false };
	adapter.setCommand(Command::DisplayControl, params);
	// then
	expect(testPins.data, 0xC, "Display Control set wrong for DISPLAY ON");

	// when setting cursor on and display on
	params.displayControl = { true, true, false };
	adapter.setCommand(Command::DisplayControl, params);
	// then
	expect(testPins.data, 0xE, "Display Control set wrong for CURSOR ON");
}

void AdapterTests::testFunctionSet() {
	// given
	Parameters params;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	// when
	params.functionSet = { FunctionSet::DataLength::EightBits, FunctionSet::Lines::OneLine, FunctionSet::FontSize::TenPixels };
	adapter.setCommand(Command::FunctionSet, params);
	// then
	expect(testPins.data, 0x34, "Function Set is wrong for 8 BITS of data, display 1 LINE and font size 10 PIXELS");

	// when
	params.functionSet = { FunctionSet::DataLength::EightBits, FunctionSet::Lines::TwoLines, FunctionSet::FontSize::EightPixels };
	adapter.setCommand(Command::FunctionSet, params);
	// then
	expect(testPins.data, 0x38, "Function Set is wrong for 8 BITS of data, display 2 LINES and font size 8 PIXELS");
}

void AdapterTests::testSetDDRAMAddress() {
	// given
	Parameters params;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);

	// when
	params.ddramAddress = { Line::First };
	adapter.setCommand(Command::DDRAMAddress, params);

	// then
	expect(testPins.data, 0x80, "Set DDRAM position to First line should set data bus to address 0x80");

	// when
	params.ddramAddress = { Line::Second };
	adapter.setCommand(Command::DDRAMAddress, params);

	// then
	expect(testPins.data, 0xC0, "Set DDRAM position to Second line should set data bus to address 0xC0");
}

void AdapterTests::testWriteCharacter() {
	// given
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Write);
	char character = 'Z'; // arbitrarily chosen

	// when
	adapter.setCharacter(character);
	// then
	expect(testPins.data, character, "The given char to WRITE is not correctly set");
}

void AdapterTests::testIsBusy() {
	// given
	bool isBusy;
	Adapter::Adapter adapter(testPins);
	adapter.setReadWrite(ReadWrite::Read);
	
	// when
	constexpr int BUSY_FLAG_DATA_BIT = 7;
	digitalWrite(testPins.data[BUSY_FLAG_DATA_BIT], HIGH, true);
	// then
	isBusy = adapter.isBusy();
	expect(isBusy, "The adapter said NOT isBusy, but BF pin is HIGH");

	// when
	digitalWrite(testPins.data[BUSY_FLAG_DATA_BIT], LOW, true);
	// then
	isBusy = adapter.isBusy();
	expect(!isBusy, "The adapter said isBusy, but BF pin is LOW");
}

void expect(int pins[8], char value, std::string&& message) {
	for (int i = 0; i < 8; ++i) {
		int pin = pins[i];
		bool pinValue = (digitalRead(pin, true) == HIGH);
		bool comparison = (value & 0x1);
		expect(pinValue == comparison, std::move(message));
		value = value >> 1;
	}
}

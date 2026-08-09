#include <string>
#include <test.h>
#include <Display/Device.h>

#include "DeviceTests.h"
#include "Adapter.mock.h"

using namespace std;
using namespace Display;

Tests* Tests::sut = new DeviceTests;

static Display::Adapter::Pins testPins = {1, 2, 3, {4, 5, 6, 7, 8, 9, 10, 11}};

//
// Private method declarations
//
bool isPinSet(unsigned long long pinState, int pin);
char extractData(unsigned long long pinState, int firstDataPin);
void checkExecuteCommand(const string& funcName, struct Adapter::Adapter& spy, char value, const string& representation);
void checkWriteCommand(const string& funcName, queue<unsigned long long>& pinLog, char value, const string& representation);
void checkWriteData(const string& funcName, queue<unsigned long long>& pinLog, char value, const string& representation);
void checkExecutionRise(const string& funcName, queue<unsigned long long>& pinLog);
void checkExecutionFall(const string& funcName, queue<unsigned long long>& pinLog);
void checkBusyFlag(const string& funcName, queue<unsigned long long>& pinLog);
void checkCleanState(const string& funcName, queue<unsigned long long>& pinLog);

//
// Public method implementations
//
DeviceTests::DeviceTests() : Tests("Display::Device") {
}

void DeviceTests::run() {
	this->testInit();
	this->testClear();
	this->testEntryMode();
	this->testWrite();
	this->testBreakLine();
	this->testDisplayOn();
	this->testCursorVisible();
	this->testCursorBlinking();
}

void DeviceTests::testInit() {
	// given
	Adapter::Adapter spy(testPins);

	// when
	Device sut(spy);

	// then
	auto pinLog = spy.flushLog();

	// initialisation: following datasheet instruction
	expect(spy.delay(pinLog) > 15, "The first delay during the display initialisation needs to wait for at least 15ms");
	checkWriteCommand("display initialisation", pinLog, 0x38, "0x38");
	checkExecutionRise("display initialisation", pinLog);
	expect(spy.delay(pinLog) >= 5, "The first delay during the display initialisation needs to wait for at least 4.1ms");
	checkWriteCommand("display initialisation", pinLog, 0x38, "0x38");
	checkExecutionRise("display initialisation", pinLog);
	checkWriteCommand("display initialisation", pinLog, 0x38, "0x38");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisation", pinLog);
	checkExecutionRise("display initialisation", pinLog);

	// function set - data length: 8 bits, lines: 2 lines, font size: 8 pixels
	checkWriteCommand("display initialisation", pinLog, 0x38, "0x38");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisation", pinLog);
	checkExecutionRise("display initialisation", pinLog);

	// display: off
	checkWriteCommand("display initialisation", pinLog, 0x8, "0x8");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisationion", pinLog);
	checkExecutionRise("display initialisationion", pinLog);

	// clear
	checkWriteCommand("display initialisationion", pinLog, 0x1, "0x1");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisation", pinLog);
	checkExecutionRise("display initialisation", pinLog);

	// entry mode: increment
	checkWriteCommand("display initialisation", pinLog, 0x6, "0x6");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisation", pinLog);
	checkExecutionRise("display initialisation", pinLog);

	// display: off
	checkWriteCommand("display initialisation", pinLog, 0xC, "0xC");
	checkExecutionRise("display initialisation", pinLog);
	checkBusyFlag("display initialisationion", pinLog);
	checkExecutionRise("display initialisationion", pinLog);

	// verify clean after init
	checkExecutionFall("display initialisation", pinLog);
	checkCleanState("display initialisation", pinLog);
}

void DeviceTests::testClear() {
	// given
	queue<unsigned long long> pinLog;
	Adapter::Adapter spy(testPins);
	Device sut(spy);
	spy.flushLog();
	spy.setBusyCount(2);

	// when
	sut.clear();

	// then
	pinLog = spy.flushLog();
	checkWriteCommand("clear()", pinLog, 0x1, "0x1");
	checkExecutionRise("clear()", pinLog);

	// check read the busy flag (first attempt, busy count is 2)
	checkBusyFlag("clear()", pinLog);
	checkExecutionRise("clear()", pinLog);

	// check read the busy flag (second attempt, busy count is 1)
	checkBusyFlag("clear()", pinLog);
	checkExecutionRise("clear()", pinLog);

	// check read the busy flag (third attempt, busy is clear)
	checkBusyFlag("clear()", pinLog);
	checkExecutionRise("clear()", pinLog);

	// exit clean
	checkExecutionFall("clear()", pinLog);
	checkCleanState("clear()", pinLog);
}

void DeviceTests::testEntryMode() {
	// given
	Adapter::Adapter spy(testPins);
	Device sut(spy);
	spy.flushLog();

	// when
	sut.setEntryMode(CursorDirection::Increment);
	// then
	checkExecuteCommand("setEntryMode(CursorDirection::Increment)", spy, 0x6, "0x6");

	// when
	sut.setEntryMode(CursorDirection::Decrement);
	// then
	checkExecuteCommand("setEntryMode(CursorDirection::Decrement)", spy, 0x4, "0x4");
}

void DeviceTests::testWrite() {
	// given
	string funcName = "write('Ola')";
	queue<unsigned long long> pinLog;
	Adapter::Adapter spy(testPins);
	Device sut(spy);
	spy.flushLog();

	// when
	sut.write("Ola");

	// then
	pinLog = spy.flushLog();

	// check write 'O' in 'Ola'
	checkWriteData(funcName, pinLog, 'O', "'O'");
	checkExecutionRise(funcName, pinLog);
	checkBusyFlag(funcName, pinLog);
	checkExecutionRise(funcName, pinLog);

	// check write 'l' in 'Ola'
	checkWriteData(funcName, pinLog, 'l', "'l'");
	checkExecutionRise(funcName, pinLog);
	checkBusyFlag(funcName, pinLog);
	checkExecutionRise(funcName, pinLog);

	// check write 'a' in 'Ola'
	checkWriteData(funcName, pinLog, 'a', "'a'");
	checkExecutionRise(funcName, pinLog);
	checkBusyFlag(funcName, pinLog);
	checkExecutionRise(funcName, pinLog);

	// check Enabled pin fall to complete the operation
	checkExecutionFall(funcName, pinLog);
	checkCleanState(funcName, pinLog);
}

void DeviceTests::testBreakLine() {
	// given
	Adapter::Adapter spy(testPins);
	Device sut(spy);
	spy.flushLog();

	// when
	sut.breakLine();
	// then
	checkExecuteCommand("breakLine()", spy, 0xC0, "0xC0");
}

void DeviceTests::testDisplayOn() {
	// given
	Adapter::Adapter spy(testPins);
	Device sut(spy);

	sut.setCursorVisible(false);
	sut.setCursorBlinking(false);
	spy.flushLog();

	// when
	sut.setDisplayOn(true);
	// then
	checkExecuteCommand("setDisplayOn(true)", spy, 0xC, "0xC");

	// when
	sut.setDisplayOn(false);
	// then
	checkExecuteCommand("setDisplayOn(false)", spy, 0x8, "0x8");
}

void DeviceTests::testCursorVisible() {
	// given
	Adapter::Adapter spy(testPins);
	Device sut(spy);

	sut.setDisplayOn(false);
	sut.setCursorBlinking(false);
	spy.flushLog();

	// when
	sut.setCursorVisible(true);
	// then
	checkExecuteCommand("setCursorVisible(true)", spy, 0xA, "0xA");

	// when
	sut.setCursorVisible(false);
	// then
	checkExecuteCommand("setCursorVisible(false)", spy, 0x8, "0x8");
}

void DeviceTests::testCursorBlinking() {
	// given
	Adapter::Adapter spy(testPins);
	Device sut(spy);

	sut.setDisplayOn(false);
	sut.setCursorVisible(false);
	spy.flushLog();

	// when
	sut.setCursorBlinking(true);
	// then
	checkExecuteCommand("setCursorBlinking(true)", spy, 0x9, "0x9");

	// when
	sut.setCursorBlinking(false);
	// then
	checkExecuteCommand("setCursorBlinking(false)", spy, 0x8, "0x8");
}

//
// Private method implementations
//
bool isPinSet(unsigned long long pinState, int pin) {
	return pinState & (0x8000000000000000 >> (pin - 1));
}

char extractData(unsigned long long pinState, int firstDataPin) {
	unsigned long long data = (pinState & (0xFF00000000000000 >> (firstDataPin - 1)));
	char x = (char)(data >> ((sizeof(unsigned long long) - sizeof(char)) * 8 - firstDataPin + 1));
	x = (x & 0x7E) | ((x & 0x80) >> 7) | ((x & 0x01) << 7);
	x = (x & 0xBD) | ((x & 0x40) >> 5) | ((x & 0x02) << 5);
	x = (x & 0xDB) | ((x & 0x20) >> 3) | ((x & 0x04) << 3);
	x = (x & 0xE7) | ((x & 0x10) >> 1) | ((x & 0x08) << 1);
	return x;
}

void checkExecuteCommand(const string& funcName, struct Adapter::Adapter& spy, char value, const string& representation) {
	auto pinLog = spy.flushLog();
	checkWriteCommand(funcName, pinLog, value, representation);
	checkExecutionRise(funcName, pinLog);
	checkBusyFlag(funcName, pinLog);
	checkExecutionRise(funcName, pinLog);
	checkExecutionFall(funcName, pinLog);
	checkCleanState(funcName, pinLog);
}

void checkWriteCommand(const string& funcName, queue<unsigned long long>& pinLog, char value, const string& representation) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to run " + funcName);
		return;
	}

	unsigned long long pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting command pins for " + funcName);
	expect(!isPinSet(pinState, testPins.rs), "For " + funcName + ", RegisterSelect needs to be clear (Command)");
	expect(!isPinSet(pinState, testPins.rw), "For " + funcName + ", ReadWrite needs to be clear (Write)");
	expect(extractData(pinState, *testPins.data) == value, "For " + funcName + ", the data bus must be " + representation);
	pinLog.pop();
}

void checkWriteData(const string& funcName, queue<unsigned long long>& pinLog, char value, const string& representation) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to run " + funcName);
		return;
	}

	unsigned long long pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting command pins for " + funcName);
	expect(isPinSet(pinState, testPins.rs), "For " + funcName + ", RegisterSelect needs to be set (Data)");
	expect(!isPinSet(pinState, testPins.rw), "For " + funcName + ", ReadWrite needs to be clear (Write)");
	expect(extractData(pinState, *testPins.data) == value, "For " + funcName + ", the data bus must be " + representation);
	pinLog.pop();
}


void checkExecutionRise(const string& funcName, queue<unsigned long long>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check Execution Rise for " + funcName);
		return;
	}

	unsigned long long pinState = pinLog.front();
	expect(isPinSet(pinState, testPins.e), "After configuring the bus for " + funcName + ", Execution needs to rise");
	pinLog.pop();
}

void checkExecutionFall(const string& funcName, queue<unsigned long long>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check Execution Fall for " + funcName);
		return;
	}

	unsigned long long pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution hasn't fallen for " + funcName);
	pinLog.pop();
}

void checkBusyFlag(const string& funcName, queue<unsigned long long>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check busy flag for " + funcName);
		return;
	}

	unsigned long long pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting up a status read");
	expect(!isPinSet(pinState, testPins.rs), "To check busy flag, RegisterSelect needs to be clear (Command)");
	expect(isPinSet(pinState, testPins.rw), "To check busy flag, ReadWrite needs to be set (Read)");
	pinLog.pop();
}

void checkCleanState(const string& funcName, queue<unsigned long long>& pinLog) {
	expect(pinLog.empty(), funcName + " should've been done by now, there is no need to execute further commands");
}


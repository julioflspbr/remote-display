#include <string>
#include <test.h>
#include <Display/Device.h>

#include "DeviceTests.h"
#include "Adapter.mock.h"

using namespace std;
using namespace Display;
using Port = Adapter::Port;

Tests* Tests::sut = new DeviceTests;

static Display::Adapter::Pins testPins = {1, 2, 3};

//
// Private method declarations
//
bool isPinSet(unsigned short pinState, int pin);
char extractData(unsigned short pinState);
void checkDelay(const string& funcName, queue<unsigned short>& pinLog, int delay, const string& delayText);
void checkExecuteCommand(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation);
void checkWriteCommand(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation);
void checkWriteData(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation);
void checkExecutionRise(const string& funcName, queue<unsigned short>& pinLog);
void checkExecutionFall(const string& funcName, queue<unsigned short>& pinLog);
void checkBusyFlag(const string& funcName, queue<unsigned short>& pinLog);
void checkCleanState(const string& funcName, queue<unsigned short>& pinLog);

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
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::A> spy(testPins);
	Device<decltype(spy)> sut(spy);

	// when
	sut.begin();

	// then
	pinLog = spy.flushLog();

	// initialisation: following datasheet instruction
	checkDelay("begin()", pinLog, 15, "15");
	checkWriteCommand("begin()", pinLog, 0x30, "0x30");
	checkExecutionRise("begin()", pinLog);
	checkDelay("begin()", pinLog, 5, "5");
	checkWriteCommand("begin()", pinLog, 0x30, "0x30");
	checkExecutionRise("begin()", pinLog);
	checkDelay("begin()", pinLog, 1, "1");
	checkWriteCommand("begin()", pinLog, 0x30, "0x30");
	checkExecutionRise("begin()", pinLog);

	// function set - data length: 8 bits, lines: 2 lines, font size: 8 pixels
	checkWriteCommand("begin()", pinLog, 0x38, "0x38");
	checkExecutionRise("begin()", pinLog);

	// display: off
	checkWriteCommand("begin()", pinLog, 0x8, "0x8");
	checkExecutionRise("begin()", pinLog);
	checkBusyFlag("begin()ion", pinLog);
	checkExecutionRise("begin()ion", pinLog);

	// clear
	checkWriteCommand("begin()ion", pinLog, 0x1, "0x1");
	checkExecutionRise("begin()", pinLog);
	checkBusyFlag("begin()", pinLog);
	checkExecutionRise("begin()", pinLog);

	// entry mode: increment
	checkWriteCommand("begin()", pinLog, 0x6, "0x6");
	checkExecutionRise("begin()", pinLog);
	checkBusyFlag("begin()", pinLog);
	checkExecutionRise("begin()", pinLog);

	// display: off
	checkWriteCommand("begin()", pinLog, 0xC, "0xC");
	checkExecutionRise("begin()", pinLog);
	checkBusyFlag("begin()ion", pinLog);
	checkExecutionRise("begin()ion", pinLog);

	// verify clean after init
	checkExecutionFall("begin()", pinLog);
	checkCleanState("begin()", pinLog);
}

void DeviceTests::testClear() {
	// given
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::B> spy(testPins);
	Device<decltype(spy)> sut(spy);
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
	
}

void DeviceTests::testEntryMode() {
	// given
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::C> spy(testPins);
	Device<decltype(spy)> sut(spy);

	// when
	sut.setEntryMode(CursorDirection::Increment);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setEntryMode(CursorDirection::Increment)", pinLog, 0x6, "0x6");

	// when
	sut.setEntryMode(CursorDirection::Decrement);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setEntryMode(CursorDirection::Decrement)", pinLog, 0x4, "0x4");
}

void DeviceTests::testWrite() {
	// given
	string funcName = "write('Ola')";
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::D> spy(testPins);
	Device<decltype(spy)> sut(spy);

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
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::E> spy(testPins);
	Device<decltype(spy)> sut(spy);

	// when
	sut.breakLine();
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("breakLine()", pinLog, 0xC0, "0xC0");
}

void DeviceTests::testDisplayOn() {
	// given
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::F> spy(testPins);
	Device<decltype(spy)> sut(spy);

	sut.setCursorVisible(false);
	sut.setCursorBlinking(false);
	spy.flushLog();

	// when
	sut.setDisplayOn(true);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setDisplayOn(true)", pinLog, 0xC, "0xC");

	// when
	sut.setDisplayOn(false);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setDisplayOn(false)", pinLog, 0x8, "0x8");
}

void DeviceTests::testCursorVisible() {
	// given
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::G> spy(testPins);
	Device<decltype(spy)> sut(spy);

	sut.setDisplayOn(false);
	sut.setCursorBlinking(false);
	spy.flushLog();

	// when
	sut.setCursorVisible(true);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setCursorVisible(true)", pinLog, 0xA, "0xA");

	// when
	sut.setCursorVisible(false);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setCursorVisible(false)", pinLog, 0x8, "0x8");
}

void DeviceTests::testCursorBlinking() {
	// given
	queue<unsigned short> pinLog;
	Adapter::Adapter<Port::H> spy(testPins);
	Device<decltype(spy)> sut(spy);

	sut.setDisplayOn(false);
	sut.setCursorVisible(false);
	spy.flushLog();

	// when
	sut.setCursorBlinking(true);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setCursorBlinking(true)", pinLog,  0x9, "0x9");

	// when
	sut.setCursorBlinking(false);
	// then
	pinLog = spy.flushLog();
	checkExecuteCommand("setCursorBlinking(false)", pinLog, 0x8, "0x8");
}

//
// Private method implementations
//
bool isPinSet(unsigned short pinState, int pin) {
	return pinState & (1 << (sizeof(unsigned char) * 8 + pin - 1));
}

char extractData(unsigned short pinState) {
	return (char)pinState;
}

void checkExecuteCommand(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation) {
	checkWriteCommand(funcName, pinLog, value, representation);
	checkExecutionRise(funcName, pinLog);
	checkBusyFlag(funcName, pinLog);
	checkExecutionRise(funcName, pinLog);
	checkExecutionFall(funcName, pinLog);
	checkCleanState(funcName, pinLog);
}

void checkWriteCommand(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to run " + funcName);
		return;
	}

	unsigned short pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting command pins for " + funcName);
	expect(!isPinSet(pinState, testPins.rs), "For " + funcName + ", RegisterSelect needs to be clear (Command)");
	expect(!isPinSet(pinState, testPins.rw), "For " + funcName + ", ReadWrite needs to be clear (Write)");
	expect(extractData(pinState) == value, "For " + funcName + ", the data bus must be " + representation);
	pinLog.pop();
}

void checkWriteData(const string& funcName, queue<unsigned short>& pinLog, char value, const string& representation) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to run " + funcName);
		return;
	}

	unsigned short pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting command pins for " + funcName);
	expect(isPinSet(pinState, testPins.rs), "For " + funcName + ", RegisterSelect needs to be set (Data)");
	expect(!isPinSet(pinState, testPins.rw), "For " + funcName + ", ReadWrite needs to be clear (Write)");
	expect(extractData(pinState) == value, "For " + funcName + ", the data bus must be " + representation);
	pinLog.pop();
}


void checkExecutionRise(const string& funcName, queue<unsigned short>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check Execution Rise for " + funcName);
		return;
	}

	unsigned short pinState = pinLog.front();
	expect(isPinSet(pinState, testPins.e), "After configuring the bus for " + funcName + ", Execution needs to rise");
	pinLog.pop();
}

void checkExecutionFall(const string& funcName, queue<unsigned short>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check Execution Fall for " + funcName);
		return;
	}

	unsigned short pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution hasn't fallen for " + funcName);
	pinLog.pop();
}

void checkBusyFlag(const string& funcName, queue<unsigned short>& pinLog) {
	if (pinLog.empty()) {
		fail("There are no remaining commands to check busy flag for " + funcName);
		return;
	}

	unsigned short pinState = pinLog.front();
	expect(!isPinSet(pinState, testPins.e), "Execution needs to be low when setting up a status read");
	expect(!isPinSet(pinState, testPins.rs), "To check busy flag, RegisterSelect needs to be clear (Command)");
	expect(isPinSet(pinState, testPins.rw), "To check busy flag, ReadWrite needs to be set (Read)");
	pinLog.pop();
}

void checkDelay(const string& funcName, queue<unsigned short>& pinLog, int expectedDelay, const string& delayText) {
	constexpr int delayFakeCommandFlag = 0x40;
	unsigned short pinState = pinLog.front();
	int delay = extractData(pinState) - delayFakeCommandFlag;
	expect(delay < delayFakeCommandFlag, "The delay in " + funcName + " is invalid");
	expect(delay >= expectedDelay, "The delay in " + funcName + " needs to wait for at least " + delayText + "ms");
	pinLog.pop();
}

void checkCleanState(const string& funcName, queue<unsigned short>& pinLog) {
	expect(pinLog.empty(), funcName + " should've been done by now, there is no need to execute further commands");
}


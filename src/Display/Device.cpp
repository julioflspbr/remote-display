#include <Display/Device.h>
#include <Display/Adapter.h>

using namespace Display;

using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

static constexpr int ROW = 0;
static constexpr int CHAR = 1;
static constexpr short MAX_ROWS = 2;
static constexpr short MAX_CHARS = 16;

inline void wait(struct Adapter::Adapter& adapter);

Device::Device(struct Adapter::Adapter& adapter) : _adapter(adapter) {
	Parameters p;
	p.functionSet = { FunctionSet::DataLength::EightBits, FunctionSet::Lines::TwoLines, FunctionSet::FontSize::EightPixels };

	// initialisation protocol according to the data sheet

	_adapter.sleep(20);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	_adapter.sleep(5);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	wait(_adapter);

	// set 8 bits, two lines, font size 8 pixels
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	wait(_adapter);

	// set display off, cursor invisible, cursor not blink
	p.displayControl = { false, false, false };
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);
	wait(_adapter);

	// clear any mess left by the initialisation
	this->clear();

	// automatically increment the memory address by one when writing a character
	this->setEntryMode(CursorDirection::Increment);

	// ready to show the display
	this->setDisplayOn(true);
}

void Device::write(const char* text) {
	if (_cursor[ROW] >= MAX_ROWS) {
		return;
	}

	char current;
	while ((current = *(text++))) {
		if (current == '\n') {
			this->breakLine();
			continue;
		}

		if (_cursor[CHAR] >= MAX_CHARS) {
			this->breakLine();
		}

		if (_cursor[ROW] >= MAX_ROWS) {
			break;
		}

		_adapter.setReadyToExecute(false);
		_adapter.setRegisterSelect(RegisterSelect::Data);
		_adapter.setReadWrite(ReadWrite::Write);
		_adapter.setCharacter(current);
		_adapter.setReadyToExecute(true);

		_cursor[CHAR] += 1;
		wait(_adapter);
	}
}

void Device::breakLine() {
	if (_cursor[ROW] > 0) {
		return;
	}

	Parameters p;
	p.ddramAddress = { Line::Second };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DDRAMAddress, p);
	_adapter.setReadyToExecute(true);

	_cursor[ROW] += 1;
	_cursor[CHAR] = 0;
	wait(_adapter);
}

void Device::clear() {
	Parameters p;

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::Clear, p);
	_adapter.setReadyToExecute(true);

	_cursor[ROW] = 0;
	_cursor[CHAR] = 0;
	wait(_adapter);
}

void Device::setEntryMode(CursorDirection direction) {
	Parameters p;
	p.entryMode = { direction, false };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::EntryMode, p);
	_adapter.setReadyToExecute(true);

	wait(_adapter);
}

void Device::setDisplayOn(bool isOn) {
	Parameters p;
	p.displayControl = { isOn, _isCursorVisible, _isCursorBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isDisplayOn = isOn;
	wait(_adapter);
}

void Device::setCursorVisible(bool isVisible) {
	Parameters p;
	p.displayControl = { _isDisplayOn, isVisible, _isCursorBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isCursorVisible = isVisible;
	wait(_adapter);
}

void Device::setCursorBlinking(bool isBlinking) {
	Parameters p;
	p.displayControl = { _isDisplayOn, _isCursorVisible, isBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isCursorBlinking = isBlinking;
	wait(_adapter);
}

void wait(struct Adapter::Adapter& adapter) {
	adapter.setReadyToExecute(false);
	adapter.setRegisterSelect(RegisterSelect::Command);
	adapter.setReadWrite(ReadWrite::Read);

	bool isBusy = true;
	while (isBusy) {
		adapter.setReadyToExecute(true);
		isBusy = adapter.isBusy();
		adapter.setReadyToExecute(false);
	}
}


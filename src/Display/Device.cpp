#include <Display/Device.h>
#include <Display/Adapter.h>

using namespace Display;

using Command = Adapter::Command;
using Parameters = Adapter::Parameters;

static constexpr int ROW = 0;
static constexpr int CHAR = 1;
static constexpr short MAX_ROWS = 2;
static constexpr short MAX_CHARS = 16;

template<typename A> Device<A>::Device(A& adapter) : _adapter(adapter) {
};

template<typename A> void Device<A>::begin() {
	Parameters p;
	p.functionSet = { FunctionSet::DataLength::EightBits, FunctionSet::Lines::OneLine, FunctionSet::FontSize::EightPixels };

	// initialisation protocol according to the data sheet

	_adapter.sleep(20);
	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	_adapter.sleep(5);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);
	_adapter.sleep(1);
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);

	// set 8 bits, two lines, font size 8 pixels
	p.functionSet = { FunctionSet::DataLength::EightBits, FunctionSet::Lines::TwoLines, FunctionSet::FontSize::EightPixels };
	_adapter.setReadyToExecute(false);
	_adapter.setCommand(Command::FunctionSet, p);
	_adapter.setReadyToExecute(true);

	// set display off, cursor invisible, cursor not blink
	this->setDisplayOn(false);
	this->clear();
	this->setEntryMode(CursorDirection::Increment);
	this->setDisplayOn(true);
}

template<typename A> void Device<A>::write(const char* text) {
	if (_cursor[ROW] >= MAX_ROWS) {
		return;
	}

	char current;
	while ((current = *(text++))) {
		if (current == '\n' || current == '\r') {
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
		this->wait();
	}
}

template<typename A> void Device<A>::breakLine() {
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
	this->wait();
}

template<typename A> void Device<A>::clear() {
	Parameters p;

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::Clear, p);
	_adapter.setReadyToExecute(true);

	_cursor[ROW] = 0;
	_cursor[CHAR] = 0;
	this->wait();
}

template<typename A> void Device<A>::setEntryMode(CursorDirection direction) {
	Parameters p;
	p.entryMode = { direction, false };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::EntryMode, p);
	_adapter.setReadyToExecute(true);

	this->wait();
}

template<typename A> void Device<A>::setDisplayOn(bool isOn) {
	Parameters p;
	p.displayControl = { isOn, _isCursorVisible, _isCursorBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isDisplayOn = isOn;
	this->wait();
}

template<typename A> void Device<A>::setCursorVisible(bool isVisible) {
	Parameters p;
	p.displayControl = { _isDisplayOn, isVisible, _isCursorBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isCursorVisible = isVisible;
	this->wait();
}

template<typename A> void Device<A>::setCursorBlinking(bool isBlinking) {
	Parameters p;
	p.displayControl = { _isDisplayOn, _isCursorVisible, isBlinking };

	_adapter.setReadyToExecute(false);
	_adapter.setRegisterSelect(RegisterSelect::Command);
	_adapter.setReadWrite(ReadWrite::Write);
	_adapter.setCommand(Command::DisplayControl, p);
	_adapter.setReadyToExecute(true);

	_isCursorBlinking = isBlinking;
	this->wait();
}

template<typename A> void Device<A>::wait() {
	bool isBusy;

	do {
		_adapter.setReadyToExecute(false);
		_adapter.setRegisterSelect(RegisterSelect::Command);
		_adapter.setReadWrite(ReadWrite::Read);
		_adapter.setReadyToExecute(true);
		isBusy = _adapter.isBusy();
	} while (isBusy);

	_adapter.setReadyToExecute(false);
}

template class Display::Device<Adapter::Adapter<Adapter::Port::A>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::B>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::C>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::D>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::E>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::F>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::G>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::H>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::J>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::K>>;
template class Display::Device<Adapter::Adapter<Adapter::Port::L>>;

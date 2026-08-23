#ifndef DISPLAY_ADAPTER_MOCK_H
#define DISPLAY_ADAPTER_MOCK_H

#include <queue>
#include <Display/Definitions.h>

namespace Display {
	namespace Adapter {
		template<Port P>
		struct Adapter {
			// do not use pin number higher than 8 in tests, so that it fits inside pinState
			Adapter(const struct Pins&);

			// mock
			void sleep(int milliseconds);
			void setRegisterSelect(RegisterSelect);
			void setReadWrite(ReadWrite);
			void setReadyToExecute(bool);
			void setCommand(Command);
			void setCommand(Command, Parameters);
			void setCharacter(char);
			bool isBusy(void) const;

			// spy
			std::queue<unsigned short> flushLog(void);
			void setBusyCount(int);

		private:
			const struct Pins _pins;
			int _busyCount = 0;
			bool _isEnabled = false;
			unsigned short _pinState = 0; // MSB pins, LSB data bus
			std::queue<unsigned short> _pinLog;
		};
	}
}

#endif


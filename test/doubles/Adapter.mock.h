#ifndef DISPLAY_ADAPTER_MOCK_H
#define DISPLAY_ADAPTER_MOCK_H

#include <queue>
#include <Display/Definitions.h>

namespace Display {
	namespace Adapter {
		struct Adapter {
			Adapter(const Pins&);

			void sleep(int milliseconds);
			void setRegisterSelect(RegisterSelect);
			void setReadWrite(ReadWrite);
			void setReadyToExecute(bool);
			void setCommand(Command);
			void setCommand(Command, Parameters);
			void setCharacter(char);
			bool isBusy(void) const;

			// spy
			std::queue<unsigned long long> flushLog(void);
			int delay(std::queue<unsigned long long>& pinLog);
			void setBusyCount(int);

		private:
			Pins _pins;
			int _busyCount = 0;
			bool _isEnabled = false;
			unsigned long long _pinState = 0;
			std::queue<unsigned long long> _pinLog;
		};
	}
}

#endif


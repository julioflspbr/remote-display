#ifndef DISPLAY_ADAPTER_H
#define DISPLAY_ADAPTER_H

#include "Definitions.h"

namespace Display {
	namespace Adapter {
		template<Port P>
		struct Adapter {
			const Pins pins;

			Adapter(const Pins&);

			void sleep(int milliseconds);
			void setRegisterSelect(RegisterSelect);
			void setReadWrite(ReadWrite);
			void setReadyToExecute(bool);
			void setCommand(Command);
			void setCommand(Command, Parameters);
			void setCharacter(char);
			bool isBusy(void) const;
		};
	}
}

#endif


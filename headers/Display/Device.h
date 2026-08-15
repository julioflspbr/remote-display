#ifndef DISPLAY_DEVICE_H
#define DISPLAY_DEVICE_H

#include "Definitions.h"

namespace Display {
	template<typename Adapter>
	class Device final {
		Adapter& _adapter;

		int _cursor[2] = {};
		bool _isDisplayOn = false;
		bool _isCursorVisible = false;
		bool _isCursorBlinking = false;

		void wait(void);

	public:
		Device(Adapter&);

		void begin(void);
		void write(const char*);
		void breakLine(void);
		void clear(void);

		void setEntryMode(CursorDirection);
		void setDisplayOn(bool);
		void setCursorVisible(bool);
		void setCursorBlinking(bool);
	};
}

#endif


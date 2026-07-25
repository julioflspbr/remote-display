#ifndef DISPLAY_DEVICE_H
#define DISPLAY_DEVICE_H

#include "Definitions.h"

namespace Display {
	namespace Adapter {
		struct Adapter;
	}

	class Device final {
		struct Adapter::Adapter& _adapter;

		int _cursor[2] = {};
		bool _isDisplayOn = false;
		bool _isCursorVisible = false;
		bool _isCursorBlinking = false;

	public:
		Device(struct Adapter::Adapter&);

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


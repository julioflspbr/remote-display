#ifndef DISPLAY_TEST_H
#define DISPLAY_TEST_H

#include <Tests.h>

class DeviceTests final : public Tests {
	void testInit(void);
	void testClear(void);
	void testEntryMode(void);
	void testWrite(void);
	void testBreakLine(void);
	void testDisplayOn(void);
	void testCursorVisible(void);
	void testCursorBlinking(void);

public:
	DeviceTests(void);
	virtual void run(void) final;
};

#endif


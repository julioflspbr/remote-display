#ifndef ADAPTER_TEST_H
#define ADAPTER_TEST_H

#include <Tests.h>

class AdapterTests final : public Tests {
	void testAdapterConstruction(void);
	void testSleep(void);
	void testSetRegisterSelect(void);
	void testSetReadWrite(void);
	void testSetReadyToExecute(void);
	void testClear(void);
	void testSetEntryMode(void);
	void testSetDisplayControl(void);
	void testFunctionSet(void);
	void testSetDDRAMAddress(void);
	void testWriteCharacter(void);
	void testIsBusy(void);

public:

	AdapterTests(void);
	void run(void) override;
};

#endif


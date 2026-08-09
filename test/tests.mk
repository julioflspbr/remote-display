###############################################
#                 Variables                   #
###############################################

test_lib_headers := -Itest/library -Itest/doubles
test_lib_sources := test/library/Arduino.cpp test/library/test.cpp test/library/Tests.cpp

###############################################
#                Definitions                  #
###############################################

TESTING := test_display_adapter test_display_device
TEST_FLAGS := -DTESTING
COMPILE_FOR_TESTS = $(CC) $(CFLAGS) $(TEST_FLAGS) $(test_lib_headers) $(headers) $(test_lib_sources)

###############################################
#                  Recipes                    #
###############################################

test_display_adapter:
	$(COMPILE_FOR_TESTS) test/Display/AdapterTests.cpp src/Display/Adapter.cpp -o test_display_adapter
	./test_display_adapter

test_display_device:
	$(COMPILE_FOR_TESTS) test/Display/DeviceTests.cpp test/doubles/Adapter.mock.cpp src/Display/Device.cpp -o test_display_device
	./test_display_device

test: $(TESTING) clean

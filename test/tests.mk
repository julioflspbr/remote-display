###############################################
#                 Variables                   #
###############################################

test_lib_headers := -Itest/library
test_lib_sources := test/library/Arduino.cpp test/library/test.cpp test/library/Tests.cpp

###############################################
#                Definitions                  #
###############################################

TESTING := test_display_adapter

###############################################
#                  Recipes                    #
###############################################

test_display_adapter:
	$(CC) $(CFLAGS) $(test_lib_headers) $(headers) $(test_lib_sources) test/Display/AdapterTests.cpp source/Display/Adapter.cpp -o test_display_adapter
	./test_display_adapter

test: $(TESTING) clean

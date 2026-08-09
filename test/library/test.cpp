#include <iostream>

#include "test.h"
#include "Arduino.h"

using namespace std;

bool test_results = true;

void expect(bool condition, string&& message) {
	if (!condition) {
		cerr << message << endl;
		test_results = false;
	}
}

void fail(string&& message) {
	cerr << message << endl;
	test_results = false;
}


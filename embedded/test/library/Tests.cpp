#include <iostream>
#include "test.h"
#include "Tests.h"

using namespace std;

//
// Tests implementation
//
Tests::Tests(const string& testName): testName(testName) {
	cout << "----------------------------------------------------------------------------------------------" << endl;
	cout << "Starting " << testName << " tests" << endl;
}

Tests::~Tests() {
	cout << "Ending " << this->testName <<  " tests" << endl;
	cout << "----------------------------------------------------------------------------------------------" << endl;
}

int main() {
	if (Tests::sut) {
		Tests::sut->run();
		delete Tests::sut;
	} else {
		cerr << "The global 'sut' variable (System Under Test) was not defined" << endl;
		return SIGTERM;
	}

	if (test_results) {
		return 0;
	} else {
		return SIGTERM;
	}
}

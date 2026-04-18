#ifndef TEST_H
#define TEST_H

#include <string>

extern bool test_results;

void expect(bool condition, std::string&& message);

#endif


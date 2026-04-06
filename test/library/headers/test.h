#ifndef TEST_H
#define TEST_H

#include <array>
#include <string>

bool compare(unsigned short int value, std::array<int, 8> pins);
void assert(bool condition, std::string message);

#endif


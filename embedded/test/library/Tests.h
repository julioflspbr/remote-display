#ifndef TESTS_H
#define TESTS_H

#include <string>

class Tests {
	std::string testName;

protected:

	Tests(const std::string& testName);

public:

	static class Tests* sut;
	virtual void run(void) = 0;
	virtual ~Tests();

};

#endif


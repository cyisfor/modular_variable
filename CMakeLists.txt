cmake_minimum_required(VERSION 3.13)

include(modular_variable.cmake)

# test

modular_variable(testvar
	TYPE bool
	INIT false
	MODULES foo bar)


add_executable(test test.c modvar/testvar.c)

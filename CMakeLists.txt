cmake_minimum_required(VERSION 3.13)

message(STATUS "This is only an example of how to use this! Just include(modular_variable/modular_variable.cmake)!")

include(modular_variable.cmake)

# test

modular_variable(TESTDERP
  FILE testfile
  VAR testvar
	TYPE int
	INIT 23
	MODULES foo bar)

modvar_source_includes(test.c HEADERS "${TESTDERP_MODVAR_HEADERS}")

add_executable(test test.c ${TESTDERP_MODVAR_SOURCES})

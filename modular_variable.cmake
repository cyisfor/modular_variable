# modular_variable(name stuff) creates ${name}_MODVAR_SOURCES which need to
# be added as sources to use that variable, if they aren't an empty list.

set(MODVARDIR ${CMAKE_CURRENT_BINARY_DIR}/modvar)
include_directories(${MODVARDIR})
# for clarity in including the headers:
set(MODVARDIR ${MODVARDIR}/modvar)
# i.e. #include "modvar/something.h"
file(MAKE_DIRECTORY ${MODVARDIR})

function(modular_variable)
	cmake_parse_arguments(PARSE_ARGV 1 V
		"" "TYPE;INIT;VAR;FILE" "MODULES")
	set(cmakename "${ARGV0}")
	if(${V_VAR})
		set(name "${V_VAR}")
	else()
		set(name "${cmakename}")
	endif()
	if(${V_FILE})
		set(filename "${V_FILE}")
	else()
		set(filename "${cmakename}")
	endif()
	set(type "${V_TYPE}")
	set(init "${V_INIT}")

	set(sources "")
	foreach(suffix IN ITEMS h internal.h c)
		set(output "${MODVARDIR}/${filename}.${suffix}")
#		debugvars()
		file(LOCK "${output}.temp")
		file(WRITE "${output}.temp")
		foreach(module IN LISTS V_MODULES)
			set(input "${CMAKE_CURRENT_SOURCE_DIR}/modvar/${module}.${suffix}.in")
			if(EXISTS "${input}")
				configure_file("${input}" "${input}.temp")
				file(READ "${input}.temp" contents)
				file(APPEND "${output}.temp" "${contents}")
			endif()
		endforeach(module)
		if(EXISTS "${output}.temp")
#			file(REMOVE ${output}.temp1)
			file(RENAME "${output}.temp" "${output}")
			if("${suffix}" STREQUAL "c")
				list(APPEND sources "${output}")
				# propagate to parent scope
				# so we can actually use the generated sources in our projects :p
				set(${cmakename}_MODVAR_SOURCES "${sources}" PARENT_SCOPE)
			endif()
		endif()
		file(LOCK "${output}.temp" RELEASE)
	endforeach(suffix)
endfunction(modular_variable)

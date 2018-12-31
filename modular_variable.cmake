# modular_variable(name stuff) creates ${name}_MODVAR_SOURCES which need to
# be added as sources to use that variable, if they aren't an empty list.

# specify VAR name for the C variable to be a different name than the cmake
# ${name}_MODVAR_SOURCES
# specify FILE name for the generated file to be a different name than the
# cmake name or the C variable name.
# if FILE is unspecified, it defaults to the C variable name.
# if the C variable name is unspecified, it defaults to the cmake name

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
	if(DEFINED V_VAR)
		set(name "${V_VAR}")
	else()
		set(name "${cmakename}")
	endif()
	if(DEFINED V_FILE)
		set(filename "${V_FILE}")
	else()
		set(filename "${name}")
	endif()
	set(type "${V_TYPE}")
	set(init "${V_INIT}")

	set(sources "")
	foreach(suffix IN ITEMS h internal.h c)
		set(output "${MODVARDIR}/${filename}.${suffix}")
		file(LOCK "${output}.lock")
		set(dirty false)
#		debugvars()
		foreach(module IN LISTS V_MODULES)
			set(input "${CMAKE_CURRENT_SOURCE_DIR}/modvar/${module}.${suffix}.in")
			if(EXISTS "${input}")
				configure_file("${input}" "${input}.temp")
				file(READ "${input}.temp" contents)
				if(NOT ${dirty})
					set(dirty true)
					file(WRITE "${output}.temp" "${contents}")
				else()
					file(APPEND "${output}.temp" "${contents}")
				endif()
			endif()
		endforeach(module)
		if(${dirty})
			file(RENAME "${output}.temp" "${output}")
			file(REMOVE "${output}.temp")
			if("${suffix}" STREQUAL "c")
				list(APPEND sources "${output}")
				# propagate to parent scope
				# so we can actually use the generated sources in our projects :p
				set(${cmakename}_MODVAR_SOURCES "${sources}" PARENT_SCOPE)
			endif()
		endif()
		file(LOCK "${output}.lock" RELEASE)
		file(REMOVE "${output}.lock")
	endforeach(suffix)
endfunction(modular_variable)

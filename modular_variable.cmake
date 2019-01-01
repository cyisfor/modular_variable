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

set(modvarlistdir ${CMAKE_CURRENT_LIST_DIR})

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

	if(DEFINED V_DEPENDERS)
		set(DEP)
	endif()

	foreach(suffix IN ITEMS h internal.h c)
		set(output "${MODVARDIR}/${filename}.${suffix}")
		set(inputs)
		foreach(module IN LISTS V_MODULES)
			set(input "${CMAKE_CURRENT_SOURCE_DIR}/modvar/${module}.${suffix}.in")
			if(EXISTS "${input}")
				list(APPEND inputs "${input}")
			endif()
		endforeach(module)
		add_custom_command(
			OUTPUT "${output}"
			COMMAND "${CMAKE_COMMAND}"
			  "-Dmodules='${V_MODULES}'"
				"-Dname=${name}"
				"-Dfilename=${filename}"
				"-Dcmakename=${cmakename}"
				"-Dtype=${type}"
				"-Dinit=${init}"
				"-Dsuffix=${suffix}"
				"-Doutput=${output}"
				"-Dmodvar=${CMAKE_CURRENT_SOURCE_DIR}/modvar"
				-P ${modvarlistdir}/build_modular_variable.cmake
				DEPENDS "${inputs}")
		# then... depend on ${output}?
		if("${suffix}" STREQUAL "c")				
			list(APPEND sources "${output}")
			# propagate to parent scope
			# so we can actually use the generated sources in our projects :p
		else()
			list(APPEND headers "${output}")
		endif()
	endforeach(suffix)
	if(DEFINED sources)
		set(${cmakename}_MODVAR_SOURCES "${sources}" PARENT_SCOPE)
	endif()
	if(DEFINED headers)
		set(${cmakename}_MODVAR_HEADERS "${headers}" PARENT_SCOPE)
	endif()
endfunction(modular_variable)

function(modvar_source_includes target)
	cmake_parse_arguments(PARSE_ARGV 1 V "" "" "HEADERS")
	get_source_file_property(OLD "${target}" OBJECT_DEPENDS)
	if("${OLD}" STREQUAL "NOTFOUND")
		set(OLD)
	endif()
	set(NEW ${OLD} ${V_HEADERS})
	set_source_files_properties("${target}" OBJECT_DEPENDS "${NEW}")
endfunction(modvar_source_includes)

set(MODVARDIR ${CMAKE_BUILD_DIR}/modvar)
file(MAKE_DIRECTORY ${MODVARDIR})
include_directories(${MODVARDIR})
function(modular_variable)
	cmake_parse_arguments(PARSE_ARGV 1 V
		[] [TYPE;INIT] [MODULES])
	set(name ${ARG1})
	set(type ${V_TYPE})
	set(init ${V_INIT})
	set(output ${modvardir}/${V_NAME}.h)
	file(LOCK ${output}.temp)
	foreach(module IN LISTS V_MODULES)
		set(input ${CMAKE_SOURCE_DIR}/modvar/${module}.h.in)
		if(EXISTS ${input})
			configure_file(${input} ${output}.temp1)
			file(APPEND ${output}.temp file(READ ${OUTPUT}.temp1))
		endif()
	endforeach(module)
	file(RENAME ${output}.temp ${output})
	file(UNLOCK ${output}.temp)
endfunction(modular_variable)

# test

modular_variable(test
	TYPE bool
	INIT false
	MODULES foo bar)

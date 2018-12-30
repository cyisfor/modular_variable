set(MODVARDIR ${CMAKE_CURRENT_BINARY_DIR}/modvar)
file(MAKE_DIRECTORY ${MODVARDIR})
include_directories(${MODVARDIR})
function(modular_variable)
	cmake_parse_arguments(PARSE_ARGV 1 V
		[] [TYPE;INIT] [MODULES])
	set(name ${ARGV0})
	set(type ${V_TYPE})
	set(init ${V_INIT})
	foreach(suffix IN ITEMS h internal.h c)
		set(output ${MODVARDIR}/${name}.${suffix})
		file(LOCK ${output}.temp)
		set(targets)
		foreach(module IN LISTS "${V_MODULES}")
			set(input ${CMAKE_CURRENT_SOURCE_DIR}/modvar/${module}.${suffix}.in)
			if(EXISTS ${input})
				configure_file(${input} ${output}.temp1)
				file(APPEND ${output}.temp file(READ ${OUTPUT}.temp1))
				list(APPEND targets ${input})
			endif()
		endforeach(module)
		
		file(RENAME ${output}.temp ${output})
		file(LOCK ${output}.temp RELEASE)
	endforeach(suffix)
endfunction(modular_variable)

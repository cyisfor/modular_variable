# must define output, modules, modvar, module, suffix
# as well as name, cmakename, filename, type, init, for configure_file()

file(LOCK "${output}.lock")
foreach(module IN LISTS modules)
	set(input "${modvar}/${module}.${suffix}.in")
	if(EXISTS "${input}")
		configure_file("${input}" "${input}.temp")
		file(READ "${input}.temp" contents)
		if(DEFINED dirty)
			file(APPEND "${output}.temp" "${contents}")
		else()
			set(dirty true)
			file(WRITE "${output}.temp" "${contents}")
		endif()
	endif()
endforeach(module)
if(DEFINED dirty)
	file(RENAME "${output}.temp" "${output}")
	file(REMOVE "${output}.temp")
	file(LOCK "${output}.lock" RELEASE)
	file(REMOVE "${output}.lock")
else()
	message(WARNING "Not dirty?")
endif()

#include "modvar/testfile.h"
#include "modvar/testfile.internal.h"
#include <stdio.h>

int testvar = 3;

int main(int argc, char *argv[])
{
	printf("Some stuff from the variables %d %d\n", foo, bar);
	puts(foobar);
	return 0;
}

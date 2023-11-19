#pragma DISABLE_COVERAGE
#include <stdio.h>
#pragma ENABLE_COVERAGE
void if_statement(int a, int b, int c)
{   
    if(a && (b || c))
    {
        printf("hello\n");
    }
}

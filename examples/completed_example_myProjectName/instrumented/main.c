#include <tc_inst_decl.h>
#pragma DISABLE_COVERAGE
#include <stdio.h>
#include <string.h>
void if_statement(int a, int b, int c);

void dump_coverage(char *data_file_name)
{
    unsigned int i;

    /*NOTE: IF YOU TRY TO DO (FILE *)fopen(data_file_name,"w"), there will be a parser
      error.  This is because the parser doesn't know what FILE is, because it doesn't do
      preprocessing.  So you have be careful if you instrument without preprocessing.*/
    FILE *out_file = fopen(data_file_name,"w");

    for(i = 0; i < TC_COVERAGE_ARRAY_LENGTH; i++)
    {
        fprintf(out_file,"%d\n",tc_coverage[i]);
    }

    fclose(out_file);
}

void clear_coverage()
{
    memset(tc_coverage,0,TC_COVERAGE_ARRAY_LENGTH);
}

int main(int argc, char **argv)
{
    /*This should achieve coverage of condition 2, but not conditions
      1 or 3*/
    if_statement(1,0,0);
    if_statement(1,1,0);

    dump_coverage("../data/example_one.dat");
 
    return 0;
}
#pragma ENABLE_COVERAGE

/*See copyright in tinycover.c.*/

#include <stdio.h>

int main(int argc, char **argv) 
{
    unsigned int array_size = 0;
    char c;
    char *array_name;
    unsigned int column_count = 0;
    FILE *input_file;
    FILE *output_file;

    if(argc != 4) {
        printf("Usage: hexify <file> <output_file> <array_name>\n");
        return -1;
    }

    input_file = (FILE *)fopen(argv[1],"r");
    output_file = (FILE *)fopen(argv[2],"w");
    array_name = argv[3];

    fprintf(output_file,"char %s[] = {\n",array_name);
    while(1) {
        c = fgetc(input_file);

        if(EOF == c) {
            break;
        } else {
            array_size = array_size + 1;
            fprintf(output_file,"0x%.2X,",c);            
        }
        column_count++;
        if(16 == column_count) {
            fprintf(output_file,"\n");
            column_count = 0;
        }
        
    }
    fclose(input_file);
    fprintf(output_file,"0x00");
    fprintf(output_file,"\n};\n");
    
    return 0;
}

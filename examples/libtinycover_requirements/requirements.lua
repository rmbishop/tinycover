dofile("../../libtinycover.lua")

local c_text = [[int f1(int a, int b, int c, int d)
{
    int r = 0;
    int c[50];

    /*req.1*/
    if(a);

    /*req.2*/
    if(a)
        r = 1;

    /*req.3*/
    if(a)
    {
        r = 1;
    }

    /*req.4*/
    if(a && b){};

    /*req.4.1*/
    if(a && b && c){};

    /*req.4.2*/
    if((a && b)){};

    /*req.4.3*/
    if(a && b || c){};

    /*req.4.4*/ 
    if(a || b && c){};

    /*req.4.5*/
    if(c[0] && c[1] && c[2] && c[3] && c[4] && c[5] && c[6] && c[7] && c[8] && c[9] &&
       c[10] && c[11] && c[12] && c[13] && c[14] && c[15] && c[16] && c[17] && c[18] && c[19] &&
       c[20] && c[21] && c[22] && c[23] && c[24] && c[25] && c[26] && c[27] && c[28] && c[29] &&
       c[30] && c[31] && c[32] && c[33] && c[34] && c[35] && c[36] && c[37] && c[38] && c[39] &&
       c[40] && c[41] && c[42] && c[43] && c[44] && c[45] && c[46] && c[47] && c[48] && c[49]);

    /*req.4.6*/
    if(c[0] || c[1] || c[2] || c[3] || c[4] || c[5] || c[6] || c[7] || c[8] || c[9] ||
        c[10] || c[11] || c[12] || c[13] || c[14] || c[15] || c[16] || c[17] || c[18] || c[19] ||
        c[20] || c[21] || c[22] || c[23] || c[24] || c[25] || c[26] || c[27] || c[28] || c[29] ||
        c[30] || c[31] || c[32] || c[33] || c[34] || c[35] || c[36] || c[37] || c[38] || c[39] ||
        c[40] || c[41] || c[42] || c[43] || c[44] || c[45] || c[46] || c[47] || c[48] || c[49]);

    /*req.5*/
    if(a == b){};

    /*req.5.1*/
    if(a == b && c){};

    /*req.5.2*/
    if(a == b || c){};

    /*req.6*/
    if(a | b){};

    /*req.6.1*/
    if(a | b && c){};

    /*req.7*/
    if(!a && b){};

    /*req.7.1*/
    if(!(a && b)){};

    /*req.7.2*/
    if(!(!a && b)){};

    /*req.7.3*/
    if(!(a == b)){};

    /*req.8*/
    if(a || b, c && d){};

    /*req.8.1*/
    if(((a && b),(c || d))){};

    /*req.8.2*/
    if(!((a && b),(c || d))){};

    /*req.9*/
    if(a ? b : c){};

    /*req.9.1*/
    if((a && b) ? c : d){};

    /*req.9.2*/
    if((a,b) && c){};

    /*req.9.3*/
    if((!a,b) && c){};

    /*req.9.4*/
    if((a,!b) && c){};    

    /*req.10*/
    while(a){};

    /*req.10.1*/
    while(a && b){};

    /*req.11*/
    do
    {
        
    }
    while(a);
    
    /*req.11.1*/
    do
    {
        
    }
    while(a && b);  

    /*req.12*/
    for(r = 0; r < 10; r++)
    {
        
    }

    /*req.12.1*/
    for(r = 0; (r < 10) && (r > 2); r++)
    {
        
    }    
    
    /*req.13*/
    r = (a && b);

    /*req.13.1*/
    r = ((a && b));

    /*req.13.2*/
    r = !(a && b);

    /*req.13.3*/
    r = !!(a && b);    

    /*req.13.4*/
    r = !((a && b));

    /*req.13.5*/
    r = !(!(a && b));    

    /*req.13.6*/
    r = (!(a && b));

    /*req.13.7*/
    r = (!a && b);

    /*req.13.8*/
    r = !a && b;

    /*req.13.9*/
    r = !!a && b;    

    /*req.13.10*/
    r = (!((a && b),(c || d)));

    /*req.14*/
    (a && b) ? c : d;

    /*req.14.1*/
    (a == b) ? c : d;    
}
]]
local output = io.open("arbitrary_name_for_c_file.c","w")
local inst_table,message = instrument_c_source("arbitrary_name_for_c_file.c",c_text,"MCDC+Statement") 

if(inst_table == null) then
    print(message)
    os.exit()
end
output:write(inst_table.instrumented_source)
output:close()

local header_file = io.open("tc_inst_decl.h","w")
header_file:write(inst_table.header)
header_file:close()

local declarations_file = io.open("tc_inst_decl.c","w")
declarations_file:write(inst_table.declarations)
declarations_file:close()

local initial_report = io.open("arbitrary_name_for_c_file.report","w")
initial_report:write(inst_table.results_template)
initial_report:close()


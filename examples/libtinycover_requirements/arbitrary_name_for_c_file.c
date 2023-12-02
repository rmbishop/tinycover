#include <tc_inst_decl.h>
int f1(int a, int b, int c, int d)
{
    unsigned int tc_cov_offset_0, tc_temp_cond_0, tc_temp_dec_0;
    unsigned int tc_cov_offset_1, tc_temp_cond_1, tc_temp_dec_1;
    int r = 0;
    int c[50];

    /*req.1*/
    COV_STATEMENT(0);
    if(INST_SINGLE(0,1,(a))){;

    /*req.2*/}
    COV_STATEMENT(2);
    if(INST_SINGLE(0,3,(a)))
        {COV_STATEMENT(4);
        r = 1;

    /*req.3*/}
    COV_STATEMENT(5);
    if(INST_SINGLE(0,6,(a)))
    {
        COV_STATEMENT(7);
        r = 1;
    }

    /*req.4*/
    COV_STATEMENT(8);
    if(INST_MCDC(0,9,(INST_COND(0,1,a) && INST_COND(0,1,b)))){};

    /*req.4.1*/
    COV_STATEMENT(12);
    if(INST_MCDC(0,13,(INST_COND(0,1,a) && INST_COND(0,1,b) && INST_COND(0,1,c)))){};

    /*req.4.2*/
    COV_STATEMENT(17);
    if(INST_MCDC(0,18,((INST_COND(0,1,a) && INST_COND(0,1,b))))){};

    /*req.4.3*/
    COV_STATEMENT(21);
    if(INST_MCDC(0,22,(INST_COND(0,2,a) && INST_COND(0,2,b) || INST_COND(0,1,c)))){};

    /*req.4.4*/ 
    COV_STATEMENT(27);
    if(INST_MCDC(0,28,(INST_COND(0,3,a) || INST_COND(0,1,b) && INST_COND(0,1,c)))){};

    /*req.4.5*/
    COV_STATEMENT(32);
    if(INST_MCDC(0,33,(INST_COND(0,1,c[0]) && INST_COND(0,1,c[1]) && INST_COND(0,1,c[2]) && INST_COND(0,1,c[3]) && INST_COND(0,1,c[4]) && INST_COND(0,1,c[5]) && INST_COND(0,1,c[6]) && INST_COND(0,1,c[7]) && INST_COND(0,1,c[8]) && INST_COND(0,1,c[9]) &&
       INST_COND(0,1,c[10]) && INST_COND(0,1,c[11]) && INST_COND(0,1,c[12]) && INST_COND(0,1,c[13]) && INST_COND(0,1,c[14]) && INST_COND(0,1,c[15]) && INST_COND(0,1,c[16]) && INST_COND(0,1,c[17]) && INST_COND(0,1,c[18]) && INST_COND(0,1,c[19]) &&
       INST_COND(0,1,c[20]) && INST_COND(0,1,c[21]) && INST_COND(0,1,c[22]) && INST_COND(0,1,c[23]) && INST_COND(0,1,c[24]) && INST_COND(0,1,c[25]) && INST_COND(0,1,c[26]) && INST_COND(0,1,c[27]) && INST_COND(0,1,c[28]) && INST_COND(0,1,c[29]) &&
       INST_COND(0,1,c[30]) && INST_COND(0,1,c[31]) && INST_COND(0,1,c[32]) && INST_COND(0,1,c[33]) && INST_COND(0,1,c[34]) && INST_COND(0,1,c[35]) && INST_COND(0,1,c[36]) && INST_COND(0,1,c[37]) && INST_COND(0,1,c[38]) && INST_COND(0,1,c[39]) &&
       INST_COND(0,1,c[40]) && INST_COND(0,1,c[41]) && INST_COND(0,1,c[42]) && INST_COND(0,1,c[43]) && INST_COND(0,1,c[44]) && INST_COND(0,1,c[45]) && INST_COND(0,1,c[46]) && INST_COND(0,1,c[47]) && INST_COND(0,1,c[48]) && INST_COND(0,1,c[49])))){;

    /*req.4.6*/}
    COV_STATEMENT(84);
    if(INST_MCDC(0,85,(INST_COND(0,50,c[0]) || INST_COND(0,49,c[1]) || INST_COND(0,48,c[2]) || INST_COND(0,47,c[3]) || INST_COND(0,46,c[4]) || INST_COND(0,45,c[5]) || INST_COND(0,44,c[6]) || INST_COND(0,43,c[7]) || INST_COND(0,42,c[8]) || INST_COND(0,41,c[9]) ||
        INST_COND(0,40,c[10]) || INST_COND(0,39,c[11]) || INST_COND(0,38,c[12]) || INST_COND(0,37,c[13]) || INST_COND(0,36,c[14]) || INST_COND(0,35,c[15]) || INST_COND(0,34,c[16]) || INST_COND(0,33,c[17]) || INST_COND(0,32,c[18]) || INST_COND(0,31,c[19]) ||
        INST_COND(0,30,c[20]) || INST_COND(0,29,c[21]) || INST_COND(0,28,c[22]) || INST_COND(0,27,c[23]) || INST_COND(0,26,c[24]) || INST_COND(0,25,c[25]) || INST_COND(0,24,c[26]) || INST_COND(0,23,c[27]) || INST_COND(0,22,c[28]) || INST_COND(0,21,c[29]) ||
        INST_COND(0,20,c[30]) || INST_COND(0,19,c[31]) || INST_COND(0,18,c[32]) || INST_COND(0,17,c[33]) || INST_COND(0,16,c[34]) || INST_COND(0,15,c[35]) || INST_COND(0,14,c[36]) || INST_COND(0,13,c[37]) || INST_COND(0,12,c[38]) || INST_COND(0,11,c[39]) ||
        INST_COND(0,10,c[40]) || INST_COND(0,9,c[41]) || INST_COND(0,8,c[42]) || INST_COND(0,7,c[43]) || INST_COND(0,6,c[44]) || INST_COND(0,5,c[45]) || INST_COND(0,4,c[46]) || INST_COND(0,3,c[47]) || INST_COND(0,2,c[48]) || INST_COND(0,1,c[49])))){;

    /*req.5*/}
    COV_STATEMENT(136);
    if(INST_SINGLE(0,137,(a == b))){};

    /*req.5.1*/
    COV_STATEMENT(138);
    if(INST_MCDC(0,139,(INST_COND(0,1,a == b) && INST_COND(0,1,c)))){};

    /*req.5.2*/
    COV_STATEMENT(142);
    if(INST_MCDC(0,143,(INST_COND(0,2,a == b) || INST_COND(0,1,c)))){};

    /*req.6*/
    COV_STATEMENT(146);
    if(INST_SINGLE(0,147,(a | b))){};

    /*req.6.1*/
    COV_STATEMENT(148);
    if(INST_MCDC(0,149,(INST_COND(0,1,a | b) && INST_COND(0,1,c)))){};

    /*req.7*/
    COV_STATEMENT(152);
    if(INST_MCDC(0,153,(INST_COND(0,1,!a) && INST_COND(0,1,b)))){};

    /*req.7.1*/
    COV_STATEMENT(156);
    if(INST_MCDC(0,157,(!(INST_COND(0,1,a) && INST_COND(0,1,b))))){};

    /*req.7.2*/
    COV_STATEMENT(160);
    if(INST_MCDC(0,161,(!(INST_COND(0,1,!a) && INST_COND(0,1,b))))){};

    /*req.7.3*/
    COV_STATEMENT(164);
    if(INST_SINGLE(0,165,(!(a == b)))){};

    /*req.8*/
    COV_STATEMENT(166);
    if(INST_MCDC(0,167,(INST_COND(0,2,a) || INST_COND(0,1,b))), INST_MCDC(0,170,(INST_COND(0,1,c) && INST_COND(0,1,d)))){};

    /*req.8.1*/
    COV_STATEMENT(173);
    if(INST_MCDC(0,174,((INST_MCDC(1,177,((INST_COND(1,1,a) && INST_COND(1,1,b)))),(INST_COND(0,2,c) || INST_COND(0,1,d)))))){};

    /*req.8.2*/
    COV_STATEMENT(180);
    if(INST_MCDC(0,181,(!(INST_MCDC(1,184,((INST_COND(1,1,a) && INST_COND(1,1,b)))),(INST_COND(0,2,c) || INST_COND(0,1,d)))))){};

    /*req.9*/
    COV_STATEMENT(187);
    if(INST_SINGLE(0,188,(INST_SINGLE(1,189,(a ))? b : c))){};

    /*req.9.1*/
    COV_STATEMENT(190);
    if(INST_SINGLE(0,191,(INST_MCDC(1,192,((INST_COND(1,1,a) && INST_COND(1,1,b)) ))? c : d))){};

    /*req.9.2*/
    COV_STATEMENT(195);
    if(INST_MCDC(0,196,(INST_COND(0,1,(a,b)) && INST_COND(0,1,c)))){};

    /*req.9.3*/
    COV_STATEMENT(199);
    if(INST_MCDC(0,200,(INST_COND(0,1,(!a,b)) && INST_COND(0,1,c)))){};

    /*req.9.4*/
    COV_STATEMENT(203);
    if(INST_MCDC(0,204,(INST_COND(0,1,(a,!b)) && INST_COND(0,1,c)))){};    

    /*req.10*/
    COV_STATEMENT(207);
    while(INST_SINGLE(0,208,(a))){};

    /*req.10.1*/
    COV_STATEMENT(209);
    while(INST_MCDC(0,210,(INST_COND(0,1,a) && INST_COND(0,1,b)))){};

    /*req.11*/
    COV_STATEMENT(213);
    do
    {
        
    }
    while(INST_SINGLE(0,214,(a)));
    
    /*req.11.1*/
    COV_STATEMENT(215);
    do
    {
        
    }
    while(INST_MCDC(0,216,(INST_COND(0,1,a) && INST_COND(0,1,b))));  

    /*req.12*/
    COV_STATEMENT(219);
    for(r = 0; INST_SINGLE(0,220,(r < 10)); r++)
    {
        
    }

    /*req.12.1*/
    COV_STATEMENT(221);
    for(r = 0; INST_MCDC(0,222,(INST_COND(0,1,(r < 10)) && INST_COND(0,1,(r > 2)))); r++)
    {
        
    }    
    
    /*req.13*/
    COV_STATEMENT(225);
    r = INST_MCDC(0,226,((INST_COND(0,1,a) && INST_COND(0,1,b))));

    /*req.13.1*/
    COV_STATEMENT(229);
    r = INST_MCDC(0,230,(((INST_COND(0,1,a) && INST_COND(0,1,b)))));

    /*req.13.2*/
    COV_STATEMENT(233);
    r = INST_MCDC(0,234,(!(INST_COND(0,1,a) && INST_COND(0,1,b))));

    /*req.13.3*/
    COV_STATEMENT(237);
    r = INST_MCDC(0,238,(!!(INST_COND(0,1,a) && INST_COND(0,1,b))));    

    /*req.13.4*/
    COV_STATEMENT(241);
    r = INST_MCDC(0,242,(!((INST_COND(0,1,a) && INST_COND(0,1,b)))));

    /*req.13.5*/
    COV_STATEMENT(245);
    r = INST_MCDC(0,246,(!(!(INST_COND(0,1,a) && INST_COND(0,1,b)))));    

    /*req.13.6*/
    COV_STATEMENT(249);
    r = INST_MCDC(0,250,((!(INST_COND(0,1,a) && INST_COND(0,1,b)))));

    /*req.13.7*/
    COV_STATEMENT(253);
    r = INST_MCDC(0,254,((INST_COND(0,1,!a) && INST_COND(0,1,b))));

    /*req.13.8*/
    COV_STATEMENT(257);
    r = INST_MCDC(0,258,(INST_COND(0,1,!a) && INST_COND(0,1,b)));

    /*req.13.9*/
    COV_STATEMENT(261);
    r = INST_MCDC(0,262,(INST_COND(0,1,!!a) && INST_COND(0,1,b)));    

    /*req.13.10*/
    COV_STATEMENT(265);
    r = INST_MCDC(0,266,((!(INST_MCDC(1,269,((INST_COND(1,1,a) && INST_COND(1,1,b)))),(INST_COND(0,2,c) || INST_COND(0,1,d))))));

    /*req.14*/
    COV_STATEMENT(272);
    INST_MCDC(0,273,((INST_COND(0,1,a) && INST_COND(0,1,b)) ))? c : d;

    /*req.14.1*/
    COV_STATEMENT(276);
    INST_SINGLE(0,277,((a == b) ))? c : d;    
}

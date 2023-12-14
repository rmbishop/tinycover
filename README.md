# Overview:  
tinycover can be used to instrument c source code for statement, decision, and mcdc coverage.

It works by taking C code like this:

    if(a && (b || c))
    {
        printf("hello\n");
    }

  And 'instrumenting' it to create code like this:

    COV_STATEMENT(0);
    if(INST_MCDC(0,1,(INST_COND(0,1,a) && (INST_COND(0,2,b) || INST_COND(0,1,c)))))
    {
        COV_STATEMENT(5);
        printf("hello\n");
    }

The intent behind this is that when you build this code and run it on your target, it produces data that you can use
to generate a coverage report, which looks like this (depending on the values of a, b, and c during run-time)

    MCDC {
      Source_File_Name = "test_preprocessed.c",
      Function_Name = "if_statement",
      Simplified_Expression = "c1 && (c2 || c3)",
      Actual_Expression = [=[a && (b || c)]=],
      Array_Index = 1,
      Number_Of_Conditions = 3,
      Conditions_Covered = 1,
      Full_Coverage_Achieved = "No",
      Line_Number = 961,
      Covered_Conditions = {"c2"},
      Deficient_Conditions = {"c1","c3"},
      Rows = {
          {Row_ID = 1, Values = "F X X", Logic = false, Found = "No"},
          {Row_ID = 2, Values = "T F F", Logic = false, Found = "Yes"},
          {Row_ID = 3, Values = "T F T", Logic = true,  Found = "No"},
          {Row_ID = 4, Values = "T T X", Logic = true,  Found = "Yes"},
      },
      Pairs = {
          {Condition = "c1", True_Row = 3, False_Row = 1, Found = "No"},
          {Condition = "c1", True_Row = 4, False_Row = 1, Found = "No"},
          {Condition = "c2", True_Row = 4, False_Row = 2, Found = "Yes"},
          {Condition = "c3", True_Row = 3, False_Row = 2, Found = "No"},
        },
    }


# Instrumenting example_one:  

  These steps work as-is in Powershell on Windows.  Ensure tinycover.exe is in the same diretory in which you type the tinycover.exe commands.

  1) Create a new project:  
   
    ./tinycover.exe new myProjectName  

  2) Add source files to the myProjectName/src folder/.  
      
    copy examples/example_one/*.* myProjectName/src  

  3) Preprocess the source code.  Tinycover does not pre-process, but it can handle #include directives.  

    In myProjectName/src:

    gcc -E test.c -o test_preprocessed.c
    rm test.c
    
  4) Instrument the source code:  

    ./tinycover.exe inst myProjectName

  5) Build the instrumented code.  In myProjectName/instrumented:

    gcc main.c -o main.exe tc_inst_decl.c test_preprocessed.c -I.

  6) Run the instrumented code:
   
    main.exe  

  7) Generate a coverage report:  

    ./tinycover.exe report myProjectName  

  8)  See completed_example_myProjectName for the expected results  

# Command line parameters

## tinycover new \<folder path\>

  The 'new' command will create a folder at \<folder path\>,
  and will create the following folders and files within:

     /data             Place all .dat files here
     /src              Place all .c files for instrumentation here
     /instrumented     Instrumented .c files are automatically placed here
     /reports          Coverage reports are automatically placed here
     /info             Coverage 'info' files are automatically placed here

## tinycover inst \<folder path\>

  The 'inst' command will take code like this:

    if(a && (b || c))
    {
        printf("hello\n");
    }

  And create code like this:

    COV_STATEMENT(0);
    if(INST_MCDC(0,1,(INST_COND(0,1,a) && (INST_COND(0,2,b) || INST_COND(0,1,c)))))
    {
        COV_STATEMENT(5);
        printf("hello\n");
    }

## tinycover report \<folder path\>    

  The 'report' command will read the .inst.info files in the /info folder and the .dat files
  in the /data folder.  Each line in a .dat file is associated with an Array_Index entry in the
  .inst.info files, where the first line of a .dat file is array index 0.  For example_one, the resulting data file will look like this:

    1
    0
    1
    0
    1
    1
    
   Because array index 0 above has a 1 in it, then the following report data would be seen in the coverage report:

    Statement {
      Source_File_Name = "test_preprocessed.c",
      Function_Name = "if_statement",
      Line_Number = 961,
      Array_Index = 0,
      Full_Coverage_Achieved = "Yes",
    }

  MCDC coverage is satisfied for a condition when both rows of a pair for that condition
  are found.  A condition can have multiple pairs, such as c1 below.  If any of those
  pairs are satisified, the condition is satisfied.  

  In the following report data coverage for c2 was satisfied because rows 2 and 4 were found.
  These rows are associated with rows in the .dat file starting from the Array_Index specified in
  the report data.  

    MCDC {
      Source_File_Name = "test_preprocessed.c",
      Function_Name = "if_statement",
      Simplified_Expression = "c1 && (c2 || c3)",
      Actual_Expression = [=[a && (b || c)]=],
      Array_Index = 1,
      Number_Of_Conditions = 3,
      Conditions_Covered = 1,
      Full_Coverage_Achieved = "No",
      Line_Number = 961,
      Covered_Conditions = {"c2"},
      Deficient_Conditions = {"c1","c3"},
      Rows = {
          {Row_ID = 1, Values = "F X X", Logic = false, Found = "No"},
          {Row_ID = 2, Values = "T F F", Logic = false, Found = "Yes"},
          {Row_ID = 3, Values = "T F T", Logic = true,  Found = "No"},
          {Row_ID = 4, Values = "T T X", Logic = true,  Found = "Yes"},
      },
      Pairs = {
          {Condition = "c1", True_Row = 3, False_Row = 1, Found = "No"},
          {Condition = "c1", True_Row = 4, False_Row = 1, Found = "No"},
          {Condition = "c2", True_Row = 4, False_Row = 2, Found = "Yes"},
          {Condition = "c3", True_Row = 3, False_Row = 2, Found = "No"},
        },
    }


# Building on Windows

  1) Open build.bat and set the compiler  

    set COMPILER=gcc.exe
    rem set COMPILER=cl.exe

  2) Run build.bat

# Building on Linux  

  1) Run build.sh


Open Source code that this project uses:  
lua 5.4.6

# Todo
1. Lots of testing and associated feedback desired, on both Windows and Linux.


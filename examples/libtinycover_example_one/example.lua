dofile("../../libtinycover.lua")

local c_text = [[

int f1()
{
  int x = 0;
  if(1)
    a = "hello"\
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

--Add some result data to satisy condition c1
add_results({0,1,0,1})

--Regenerate the results
local updated_report_text = generate_results(inst_table.results_template)
local updated_report = io.open("arbitrary_name_for_c_file.updated_report","w")
updated_report:write(updated_report_text)
updated_report:close()

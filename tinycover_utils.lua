--See copyright in tinycover.c 
local dummy = 0

function tc_read_data_file(project_folder, data_file_name)
   tab = {}
   print ("Reading data file: " .. project_folder .. "/data/" .. data_file_name)
   for line in io.lines(project_folder .. "/data/" .. data_file_name) do
       table.insert(tab,line)
   end
   add_results(tab)
end

local combined_csv_report

function custom_mcdc_results_handler(cov_info_table)

   local covered_conditions_string = cov_info_table.Covered_Conditions:gsub("[{}\"]","")
   covered_conditions_string = covered_conditions_string:gsub(","," ")
   
   local deficient_conditions_string = cov_info_table.Deficient_Conditions:gsub("[{}\"]","")
   deficient_conditions_string = deficient_conditions_string:gsub(","," ")    
      
   combined_csv_report:write(
      cov_info_table.Source_File_Name .. "," ..
      cov_info_table.Function_Name .. "," ..
      cov_info_table.Line_Number .. "," ..      
      "MCDC," ..          
      cov_info_table.Array_Index .. "," ..   
      cov_info_table.Full_Coverage_Achieved .. "," ..    
      cov_info_table.Simplified_Expression .. "," ..            
      cov_info_table.Number_Of_Conditions .. "," ..
      cov_info_table.Conditions_Covered .. "," ..
      covered_conditions_string .. "," ..
      deficient_conditions_string .. "\n"                
   )
   
end 

function custom_decision_results_handler(cov_info_table)
   combined_csv_report:write(
      cov_info_table.Source_File_Name .. "," ..
      cov_info_table.Function_Name .. "," ..
      cov_info_table.Line_Number .. "," ..      
      "Decision," ..          
      cov_info_table.Array_Index .. "," ..   
      cov_info_table.Full_Coverage_Achieved .. "," ..  
      cov_info_table.Simplified_Expression .. "," ..
      "," ..
      "," ..
      "," ..                
      ",\n"
   )
end 

function custom_statement_results_handler(cov_info_table)
   combined_csv_report:write(
      cov_info_table.Source_File_Name .. "," ..
      cov_info_table.Function_Name .. "," ..
      cov_info_table.Line_Number .. "," ..     
      "Statement," ..         
      cov_info_table.Array_Index .. "," ..               
      cov_info_table.Full_Coverage_Achieved .. "," .. 
      "," ..
      "," ..
      "," ..
      "," ..        
      ",\n"        
   )
end 

local combined_report_initialized = false

function tc_generate_results(project_folder, inst_info_file)
   local info_file = io.open(project_folder .. "/info/" .. inst_info_file)
   local info_file_text = info_file:read("*all")
   info_file:close()
   if(false == combined_report_initialized) then 
       combined_report_initialized = true
       print("Generating combined report: combined_report.csv")
       combined_csv_report = io.open(project_folder .. "/reports/combined_report.csv","w")
       combined_csv_report:write("Source_File_Name," .. 
                                  "Function_Name," .. 
                                  "Line_Number," .. 
                                  "Coverage_Type," .. 
                                  "Array_Index," .. 
                                  "Full_Coverage_Achieved," ..                                   
                                  "Simplified_Expression," .. 
                                  "Number_Of_Conditions," ..                                        
                                  "Conditions_Covered," ..
                                  "Covered_Conditions," ..     
                                  "Deficient_Conditions\n"                                  
   )                                                                

   else
       combined_csv_report = io.open(project_folder .. "/reports/combined_report.csv","a")
   end
   local base_name = inst_info_file:gsub(".inst.info","")
   local new_results = generate_results(info_file_text)

   local outfile = io.open(project_folder .. "/reports/" .. base_name .. ".report","w")
   if(nil ~= outfile) then
      print("Generating report: " .. base_name .. ".report")
      outfile:write(new_results)
      outfile:close()
   end

   if(nil ~= combined_csv_report) then
      combined_csv_report:close()
   end
end


used_starting_index = false
function tc_instrument(project_folder,source_file_name)
  
   --Run config.lua
   local result, msg = pcall(dofile,project_folder .. "/config.lua")
   if(false == result) then
       print(msg)
       return 1
   end   
   local f = io.open(project_folder .. "/src/" .. source_file_name)

   if(nil == f) then
      print("Error opening source file: " .. source_file_name)
      return 1
   end

   local c_text = f:read("*all")    

   if(nil == Coverage) then 
      Coverage = "MCDC+Statement" 
   end

   if(nil == ArrayName) then 
       ArrayName = "tc_coverage" 
   end    

   if(nil == StartingArrayIndex) then 
       StartingArrayIndex = 0
   end     

   local list_to_map = {}
   --Look at the DisableCoverage list from config.lua
   --and convert it to a map
   if(DisableCoverage ~= nil) then
      for _,file_name in pairs(DisableCoverage) do
         list_to_map[file_name] = true
      end
   end

   if((nil == source_file_name:find("%.[cC]$")) or (true == list_to_map[source_file_name]))then
      if(nil == source_file_name:find("%.[cC]$")) then
         print("Skipping " .. source_file_name .. ". File does not have .c extension")
      elseif(true == list_to_map[source_file_name]) then
         print("Skipping " .. source_file_name .. ". File is in the DisableCoverage list in config.lua")
      end
      
      --copy the file but do not instrument it
      local orig_file = io.open(project_folder .. "/src/" .. source_file_name, "rb")
      local copy_file = io.open(project_folder .. "/instrumented/" .. source_file_name, "wb")
      if(orig_file and copy_file) then 
         local orig_text = orig_file:read("*all")
         copy_file:write(orig_text)
         copy_file:close()
         orig_file:close()
      end
      return 0
   end

   local inst_table,error_message
   print("Instrumenting " .. source_file_name)
   if(false == used_starting_index) then
      inst_table,error_message = instrument_c_source(source_file_name,c_text, Coverage, ArrayName,StartingArrayIndex) 
      used_starting_index = true
   else
      inst_table,error_message = instrument_c_source(source_file_name,c_text, Coverage, ArrayName) 
   end
   if(nil ~= error_message) then
      print(error_message)
      return 1
   end
 
   local instrumented_file = io.open(project_folder .. "/instrumented/" .. source_file_name,"w")
   if(nil == instrumented_file) then
      print("Error writing instrumented file:" .. project_folder .. "/instrumented/" .. source_file_name)
      return 1
   else
      instrumented_file:write(inst_table.instrumented_source)
      instrumented_file:close()
   end
   if(inst_table.file_array_size > 0) then
      local inst_info_file = io.open(project_folder .. "/info/" .. source_file_name .. ".inst.info","w")
      if(nil == inst_info_file) then
         print("Error writing inst.info file:" ..project_folder .. "/info/" .. source_file_name .. ".inst.info")
         return 1
      else    
         inst_info_file:write(inst_table.results_template) 
      end
      inst_info_file:close()   
   end

   local header_file = io.open(project_folder .. "/instrumented/tc_inst_decl.h","w")
   if(nil == header_file) then
      print("Error writing header file: " .. project_folder .. "/instrumented/tc_inst_decl.h")
      header_file:close()
      return 1
   else    
      header_file:write(inst_table.header)
      header_file:close()
   end
    
   local declarations_file = io.open(project_folder .. "/instrumented/tc_inst_decl.c","w")
   if(nil == declarations_file) then
      print("Error writing declarations file: " .. project_folder .. "/instrumented/tc_inst_decl.c")
      declarations_file:close()    
      return 1
   else       
      declarations_file:write(inst_table.declarations)
      declarations_file:close()    
   end

    return 0
end

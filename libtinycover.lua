--libtinycover.lua
--Copyright notice is at bottom of file.

--Globals are in CamelCase
local InstrumentedText = {}
local CoverageArrayIndex = 0
local ExpressionStack = {}
local SrcFileName = ""
local BufferLength = 0
local IdentTable = {}
local IdentStack = {}
local Buffer = nil
local CoverageData = {}
local CoverageResults = {}
local ResultsTemplate = {}
local CoverageEnabled = true
local Indentation = ""
local StatementCoverage = false
local DecisionCoverage = false
local MCDCCoverage = false
local ArrayName = "tc_coverage"
local StartingArrayIndex = 0

local Tokens = {}

--Constants are UPPER_CASE
Tokens.TOK_NUMBER = 1
Tokens.TOK_STRING = 2
Tokens.TOK_CHAR = 3
Tokens.TOK_COMMENT = 4
Tokens.TOK_SPACE = 5
Tokens.TOK_TAB = 6
Tokens.TOK_NEWLINE = 7
Tokens.TOK_FORMFEED = 8
Tokens.TOK_WORD = 9
Tokens.TOK_OPENBRACE = 10
Tokens.TOK_OPENPAREN = 11
Tokens.TOK_CLOSEBRACE = 12
Tokens.TOK_TILDE = 13
Tokens.TOK_CLOSEPAREN = 14
Tokens.TOK_PERIOD = 15
Tokens.TOK_ELLIPSES = 16
Tokens.TOK_COMMA = 17
Tokens.TOK_SEMICOLON = 18
Tokens.TOK_QUESTIONMARK = 19
Tokens.TOK_BACKSLASH = 20
Tokens.TOK_EXCLAMATIONMARK = 21
Tokens.TOK_AMPERSAND = 22
Tokens.TOK_BITWISEOR = 23
Tokens.TOK_AND = 24
Tokens.TOK_BOOLEAN = 25
Tokens.TOK_NONLOGICAL = 26
Tokens.TOK_RELATIONAL = 27
Tokens.TOK_OR = 28
Tokens.TOK_POUND = 29
Tokens.TOK_COLON = 30
Tokens.TOK_STAR = 31
Tokens.TOK_FORWARDSLASH = 32
Tokens.TOK_MOD = 33
Tokens.TOK_SHIFT = 34
Tokens.TOK_AT = 35
Tokens.TOK_OPENBRACKET = 36
Tokens.TOK_CLOSEBRACKET = 37
Tokens.TOK_PLUS = 38
Tokens.TOK_PLUSPLUS = 39
Tokens.TOK_MINUS = 40
Tokens.TOK_INDIRECTION_ARROW = 41
Tokens.TOK_MINUSMINUS = 42
Tokens.TOK_ASSIGNMENT = 43
Tokens.TOK_EXCLUSIVEOR = 44
local NEW_TYPE = 45
local INSERT_OPEN_BRACKET = 46
local INSERT_CLOSE_BRACKET = 47
local FIRST_LINE_OF_FUNCTION = 48
local BOOLEAN_EXPRESSION = 49
local NON_LOGICAL_EXPRESSION = 50
local ARRAY_INDEX = 51
local FUNCTION_PARAMETERS = 52
local OPERAND = 53
local END_OF_FILE = 54
local OR_OPERATOR = 55
local AND_OPERATOR = 56
local START_OF_FILE = 57
local OPEN_EXPRESSION_PARENS = 58
local CLOSE_EXPRESSION_PARENS = 59
local EXCLAMATION_MARK_OPERATOR = 60
local COMMA_EXPRESSION = 61
local CONDITIONAL_EXPRESSION = 62
local INSERT_STATEMENT_COVERAGE = 63
local COMPOUND_STATEMENT_WITHIN_EXPRESSION = 65
local RELATIONAL_EXPRESSION = 65

local TokenTextDebug = {}
TokenTextDebug[Tokens.TOK_NUMBER] = ""
TokenTextDebug[Tokens.TOK_STRING] = ""
TokenTextDebug[Tokens.TOK_CHAR] = ""
TokenTextDebug[Tokens.TOK_COMMENT] = ""
TokenTextDebug[Tokens.TOK_SPACE] = "space"
TokenTextDebug[Tokens.TOK_TAB] = "tab"
TokenTextDebug[Tokens.TOK_NEWLINE] = "newline"
TokenTextDebug[Tokens.TOK_FORMFEED] = "formfeed character"
TokenTextDebug[Tokens.TOK_WORD] = ""
TokenTextDebug[Tokens.TOK_OPENBRACE ] = "{"
TokenTextDebug[Tokens.TOK_OPENPAREN ] = "("
TokenTextDebug[Tokens.TOK_CLOSEBRACE ] = "}"
TokenTextDebug[Tokens.TOK_TILDE ] = "~"
TokenTextDebug[Tokens.TOK_CLOSEPAREN ] = ")"
TokenTextDebug[Tokens.TOK_PERIOD ] = "."
TokenTextDebug[Tokens.TOK_ELLIPSES ] = "..."
TokenTextDebug[Tokens.TOK_COMMA ] = ","
TokenTextDebug[Tokens.TOK_SEMICOLON ] = ";"
TokenTextDebug[Tokens.TOK_QUESTIONMARK ] = ""
TokenTextDebug[Tokens.TOK_BACKSLASH ] = ""
TokenTextDebug[Tokens.TOK_EXCLAMATIONMARK ] = "!"
TokenTextDebug[Tokens.TOK_AMPERSAND ] = "&"
TokenTextDebug[Tokens.TOK_AND ] = "&&"
TokenTextDebug[Tokens.TOK_BOOLEAN ] = ""
TokenTextDebug[Tokens.TOK_NONLOGICAL ] = ""
TokenTextDebug[Tokens.TOK_OR ] = ""
TokenTextDebug[Tokens.TOK_POUND ] = ""
TokenTextDebug[Tokens.TOK_COLON ] = ""
TokenTextDebug[Tokens.TOK_STAR ] = "*"
TokenTextDebug[Tokens.TOK_AT ] = "@"
TokenTextDebug[Tokens.TOK_OPENBRACKET ] = "["
TokenTextDebug[Tokens.TOK_CLOSEBRACKET ] = "]"
TokenTextDebug[Tokens.TOK_PLUS ] = "+"
TokenTextDebug[Tokens.TOK_PLUSPLUS ] = "++"
TokenTextDebug[Tokens.TOK_MINUS ] = "-"
TokenTextDebug[Tokens.TOK_INDIRECTION_ARROW ] = "->"
TokenTextDebug[Tokens.TOK_MINUSMINUS ] = "--"
TokenTextDebug[Tokens.TOK_ASSIGNMENT ] = ""
TokenTextDebug[NEW_TYPE ] = ""
TokenTextDebug[INSERT_OPEN_BRACKET ] = ""
TokenTextDebug[INSERT_CLOSE_BRACKET ] = ""
TokenTextDebug[FIRST_LINE_OF_FUNCTION ] = ""
TokenTextDebug[BOOLEAN_EXPRESSION ] = ""
TokenTextDebug[NON_LOGICAL_EXPRESSION ] = ""
TokenTextDebug[ARRAY_INDEX ] = ""
TokenTextDebug[FUNCTION_PARAMETERS ] = ""
TokenTextDebug[OPERAND ] = ""
TokenTextDebug[END_OF_FILE ] = ""
TokenTextDebug[OR_OPERATOR ] = ""
TokenTextDebug[AND_OPERATOR ] = ""
TokenTextDebug[START_OF_FILE ] = ""
TokenTextDebug[OPEN_EXPRESSION_PARENS ] = ""
TokenTextDebug[CLOSE_EXPRESSION_PARENS ] = ""
TokenTextDebug[EXCLAMATION_MARK_OPERATOR ] = ""
TokenTextDebug[COMMA_EXPRESSION ] = ""
TokenTextDebug[CONDITIONAL_EXPRESSION ] = ""
TokenTextDebug[INSERT_STATEMENT_COVERAGE ] = ""

--Local functions
local add_mcdc_results
local new_expression_info
local copy_truth_table_row
local copy_expression_info
local resolve_truth_table
local exclamation_mark
local expand_and
local expand_or
local eval_expression
local get_tf_pairs
local get_expression_info
local comment
local first_line_of_function
local newline
local formfeed
local space
local tab
local start_boolean_expression
local exclamation_mark_operator
local open_expression_parens
local close_expression_parens
local end_boolean_expression
local or_operator
local and_operator
local add_mcdc_to_results_template
local add_decision_to_results_template
local get_initial_results
local get_declarations_text
local get_header_text
local start_of_file
local start_operand
local end_operand
local end_of_file
local text
local sharptext
local evaluate_instrumentation_commands
local remove_inner_boolean_expressions
local remove_inner_relational_expressions
local find_exclamation_mark_operators
local typeof
local enum
local struct
local attribute
local builtin_va_arg
local builtin_offsetof
local union
local add_ident
local remove_ident
local get_ident
local enumerator_list
local enumerator
local lexer_found_number
local lexer_found_word
local lexer_found_L
local word_matches
local at
local is_new_type
local specifier_qualifier_list
local argument_expression_list
local primary_expression
local postfix_expression
local type_name
local is_specifier_qualifier
local cast_expression
local unary_expression
local shift_expression
local bitwise_expression
local relational_expression
local math_expression
local get_prefix_expression
local and_expression
local or_expression
local conditional_expression
local assignment_expression
local expression
local expression_statement
local if_statement
local else_statement
local for_statement
local while_statement
local do_statement
local switch_statement
local case_statement
local return_statement
local is_label_statement
local label_statement
local goto_statement
local statement
local is_single_token_specifier_qualifier
local local_declaration
local skip_args
local asm
local pragma_operator
local get_expression_nesting_depth
local compound_statement
local is_type_qualifier
local pointer
local initializer_list
local initializer
local parameter_declaration
local parameter_type_list
local direct_declarator
local declarator
local external_declaration
local add_idents
local initialize_globals
local has_child_boolean_expression
local parse_c_text
local insert_statement_coverage
local bor

--Start of Results Generation
add_decision_results = function(cov_info_table)

   table_text = [[
Decision {
   Source_File_Name = "]] .. cov_info_table.Source_File_Name .. [[",
   Function_Name = "]] .. cov_info_table.Function_Name .. [[",
   Simplified_Expression = "]] .. cov_info_table.Simplified_Expression .. [[",
   Actual_Expression = ]] .. [==[[=[]==] ..cov_info_table.Actual_Expression .. [==[]=]]==] .. [[,
   Array_Index = ]] .. cov_info_table.Array_Index .. [[,
   Full_Coverage_Achieved = "]] .. cov_info_table.Full_Coverage_Achieved .. [[",
   Line_Number = ]] .. cov_info_table.Line_Number .. [[,
   Rows = {
         {Row_ID = 1, Values = "F", Logic = false, Found = "]] .. tostring(cov_info_table.Rows[1].Found) .. [["},
         {Row_ID = 2, Values = "T", Logic = true,  Found = "]] .. tostring(cov_info_table.Rows[2].Found) .. [["},
   },]] .. "\n"
   
   table_text = table_text .. "}\n"

   table.insert(CoverageResults,table_text)
end

add_mcdc_results = function(cov_info_table)

   table_text = [[
MCDC {
   Source_File_Name = "]] .. cov_info_table.Source_File_Name .. [[",
   Function_Name = "]] .. cov_info_table.Function_Name .. [[",
   Simplified_Expression = "]] .. cov_info_table.Simplified_Expression .. [[",
   Actual_Expression = ]] .. [==[[=[]==] ..cov_info_table.Actual_Expression .. [==[]=]]==] .. [[,
   Array_Index = ]] .. cov_info_table.Array_Index .. [[,
   Number_Of_Conditions = ]] .. cov_info_table.Number_Of_Conditions .. [[,
   Conditions_Covered = ]] .. cov_info_table.Conditions_Covered .. [[,
   Full_Coverage_Achieved = "]] .. cov_info_table.Full_Coverage_Achieved .. [[",
   Line_Number = ]] .. cov_info_table.Line_Number .. [[,
   Covered_Conditions = ]] .. cov_info_table.Covered_Conditions .. [[,
   Deficient_Conditions = ]] .. cov_info_table.Deficient_Conditions .. [[,
   Rows = {]] .. "\n"

   local rows_text = ""
   for i,row in ipairs(cov_info_table.Rows) do
      local spacing = " "
      if(row.Logic) then
        spacing = "  "
      end
      local formatted_row = string.format("%." .. #tostring(#cov_info_table.Rows) .. "d",i)
      rows_text = rows_text .. [[
      {Row_ID = ]] .. formatted_row  .. [[, Values = "]] ..row.Values .. [[", Logic = ]] .. tostring(row.Logic) .. "," .. spacing .. [[Found = "]] .. tostring(row.Found) .. [["},]] .. "\n" 
   end
   rows_text = rows_text .. [[
   },]] .. "\n"
   
   local pairs_text = [[
   Pairs = {]] .. "\n"
   for i, pair in ipairs(cov_info_table.Pairs) do
      local formatted_condition = pair.Condition
      local formatted_true_row = string.format("%." .. #tostring(#cov_info_table.Rows) .. "d",pair.True_Row) 
      local formatted_false_row = string.format("%." .. #tostring(#cov_info_table.Rows) .. "d",pair.False_Row)          
      pairs_text = pairs_text .. [[
      {Condition = "]] .. formatted_condition .. [[", True_Row = ]] .. formatted_true_row .. [[, False_Row = ]] .. formatted_false_row .. [[, Found = "]] .. tostring(pair.Found) .. [["},]] .. "\n" 
   end
     pairs_text = pairs_text .. [[
    },]] .. "\n"   

   table_text = table_text .. rows_text .. pairs_text .. "}\n"

   table.insert(CoverageResults,table_text)
end

function custom_statement_results_handler(cov_info_table)
   --This can be redefined by users of this library 
end

function Statement(cov_info_table)
   local statement_index = cov_info_table.Array_Index + 1
   local found_statement = "No"

   if(CoverageData[statement_index] == 1) then
      cov_info_table.Full_Coverage_Achieved = "Yes"
      found_statement = "Yes"
   end
   local statement = [[
Statement {
   Source_File_Name = "]] .. cov_info_table.Source_File_Name .. [[",
   Function_Name = "]] .. cov_info_table.Function_Name .. [[",
   Line_Number = ]] .. cov_info_table.Line_Number .. [[,
   Array_Index = ]] .. cov_info_table.Array_Index.. [[,
   Full_Coverage_Achieved = "]] .. cov_info_table.Full_Coverage_Achieved .. [[",
}
]]

   table.insert(CoverageResults,statement)
   custom_statement_results_handler(cov_info_table)
end

function custom_decision_results_handler(cov_info_table)
   --This can be redefined by users of this library 
end

function Decision(cov_info_table)
   local table_index = cov_info_table.Array_Index+1

   if(CoverageData[table_index] == 1) then
      cov_info_table.Rows[1].Found = "Yes"
   elseif(CoverageData[table_index] == 2) then
      cov_info_table.Rows[2].Found = "Yes"
   elseif(CoverageData[table_index] == 3) then
      cov_info_table.Rows[1].Found = "Yes"
      cov_info_table.Rows[2].Found = "Yes"
   end

   if(("Yes" == cov_info_table.Rows[1].Found) and ("Yes" == cov_info_table.Rows[2].Found)) then
      cov_info_table.Full_Coverage_Achieved = "Yes"
   else
      cov_info_table.Full_Coverage_Achieved = "No"
   end

   add_decision_results(cov_info_table)
   custom_decision_results_handler(cov_info_table)
end
  
function custom_mcdc_results_handler(cov_info_table)
   --This can be redefined by users of this library    
end

function MCDC(cov_info_table)
   local conditions_covered_count = 0
   local conditions_covered = {}
   if(cov_info_table.Number_Of_Conditions == 1) then
      local table_index = cov_info_table.Array_Index+1
      if(CoverageData[table_index] == 1) then
         cov_info_table.Rows[1].Found = "Yes"
      elseif(CoverageData[table_index] == 2) then
            cov_info_table.Rows[2].Found = "Yes"
      elseif(CoverageData[table_index] == 3) then
            cov_info_table.Rows[1].Found = "Yes"
            cov_info_table.Rows[2].Found = "Yes"
      end
   else
      local starting_index = cov_info_table.Array_Index
      for _,row in pairs(cov_info_table.Rows) do
         local table_index = starting_index + row.Row_ID 
         if(CoverageData[table_index] == 1) then
            row.Found = "Yes"
         end
      end
   end

   for _, tf_pair in pairs(cov_info_table.Pairs) do
      local t_row = tf_pair.True_Row
      local f_row = tf_pair.False_Row
      local condition = tf_pair.Condition:gsub("c","")
      condition = tonumber(condition)
      tf_pair.Found = "No"

      if(("Yes" == cov_info_table.Rows[t_row].Found) and ("Yes" == cov_info_table.Rows[f_row].Found)) then
         tf_pair.Found = "Yes"
         conditions_covered_count = conditions_covered_count + 1
         conditions_covered[condition] = true
      end
   end

   cov_info_table.Conditions_Covered = conditions_covered_count

   if(conditions_covered_count == cov_info_table.Number_Of_Conditions) then
      cov_info_table.Full_Coverage_Achieved = "Yes"
   else
      cov_info_table.Full_Coverage_Achieved = "No"
   end

   local deficient_conditions = {}
   local covered_conditions = {}
   for condition_index = 1,cov_info_table.Number_Of_Conditions do
      local formatted_condition = "\"c".. tostring(condition_index) ..  "\""
      if(true == conditions_covered[condition_index]) then
         table.insert(covered_conditions,formatted_condition)
      else
         table.insert(deficient_conditions,formatted_condition)
      end
   end

   cov_info_table.Covered_Conditions = "{" ..table.concat(covered_conditions, ",") .. "}"
   cov_info_table.Deficient_Conditions = "{" ..table.concat(deficient_conditions, ",") .. "}"

   add_mcdc_results(cov_info_table)
   custom_mcdc_results_handler(cov_info_table)
end
  
--end of Results generation

--Start of expression evaluator code
--Example: new_expression_info("&|cc|cc")
new_expression_info = function(expr)
   local expression_info = {}
   expression_info.truth_table = {}
   expression_info.condition_offet_table = {}
   expression_info.condition_true_false_pairs = {}
   return expression_info
 end

 copy_truth_table_row = function(row)
   local new_truth_table_row = {}

   new_truth_table_row.true_false_values = {}
   new_truth_table_row.true_false_values_as_decimal = {}

   for i, v in ipairs(row.true_false_values) do
      new_truth_table_row.true_false_values[i] = v
      new_truth_table_row.true_false_values_as_decimal[i] = row.true_false_values_as_decimal[i]
   end
   new_truth_table_row.index = row.index
   new_truth_table_row.result = row.result

   return new_truth_table_row

 end

 copy_expression_info = function(expression_info)
 
   local new_expression_info = new_expression_info()
   for _, row in ipairs(expression_info.truth_table) do
      local new_row = copy_truth_table_row(row)
      table.insert(new_expression_info.truth_table, new_row)
   end

   for condition_number, offset in pairs(expression_info.condition_offet_table) do
      new_expression_info.condition_offet_table[condition_number] = offset
   end

   for condition_number, pair_list in pairs(expression_info.condition_true_false_pairs) do
      new_expression_info.condition_true_false_pairs[condition_number] = {}
      for _, pair in ipairs(pair_list) do
         table.insert(new_expression_info.condition_true_false_pairs[condition_number], pair)
      end
   end

    return new_expression_info
 end

 resolve_truth_table = function(expression_info, condition_index)
   local new_truth_table = copy_expression_info(expression_info)
   for _, row in ipairs(new_truth_table.truth_table) do
      if (row.true_false_values[condition_index] == "f") then
         row.true_false_values[condition_index] = "F"
         row.true_false_values_as_decimal[condition_index] = 0
      elseif (row.true_false_values[condition_index] == "t") then
         row.true_false_values[condition_index] = "T"
         row.true_false_values_as_decimal[condition_index] = 1
      elseif (row.true_false_values[condition_index] == "-") then
         row.true_false_values[condition_index] = "X"
         row.true_false_values_as_decimal[condition_index] = 0
      end
    end
    return new_truth_table
 end

 exclamation_mark = function(expression_info, condition_index)
   local new_expression_info = copy_expression_info(expression_info)
   for _, row in ipairs(new_expression_info.truth_table) do
      if (row.true_false_values[condition_index] == "f") then
         row.true_false_values[condition_index] = "t"
         row.true_false_values_as_decimal[condition_index] = 1
      elseif (row.true_false_values[condition_index] == "t") then
         row.true_false_values[condition_index] = "f"
         row.true_false_values_as_decimal[condition_index] = 0
      end
   end
   return new_expression_info
 end

expand_and = function(expression_info)
   local new_expression_info = copy_expression_info(expression_info)
   local row_count = #new_expression_info.truth_table
   for row_index = 1, row_count do
      local row = new_expression_info.truth_table[row_index]

      for condition_index = 1, #row.true_false_values do
         if (row.true_false_values[condition_index] == "t") then
            table.insert(row.true_false_values, condition_index, "t")
            break
         elseif (row.true_false_values[condition_index] == "-") then
            table.insert(row.true_false_values, condition_index, "-")
            break
         elseif (row.true_false_values[condition_index] == "f") then
            local new_row = copy_truth_table_row(row)
            table.insert(row.true_false_values, condition_index + 1, "-")
            table.insert(new_row.true_false_values, condition_index, "t")
            table.insert(new_expression_info.truth_table, new_row)
            break
         end
      end
   end
   return new_expression_info
 end

expand_or = function(expression_info)
   local new_expression_info = copy_expression_info(expression_info)
   local row_count = #new_expression_info.truth_table
   for row_index = 1, row_count do
      local row = new_expression_info.truth_table[row_index]

      for condition_index = 1, #row.true_false_values do
         if (row.true_false_values[condition_index] == "f") then
            table.insert(row.true_false_values, condition_index, "f")
            break
         elseif (row.true_false_values[condition_index] == "-") then
            table.insert(row.true_false_values, condition_index, "-")
            break
         elseif (row.true_false_values[condition_index] == "t") then
            local new_row = copy_truth_table_row(row)
            table.insert(row.true_false_values, condition_index + 1, "-")
            table.insert(new_row.true_false_values, condition_index, "f")
            table.insert(new_expression_info.truth_table, new_row)
            break
         end
      end
   end

   return new_expression_info
 end


eval_expression = function(expression_to_evaluate, t_f_values)
   local char_index = 1
   local condition_index = 1
   local eval_binary_expression_recursive, eval_unary_expression_recursive
   
   --local function within eval_expression
   eval_binary_expression_recursive = function(boolean_operation, inverse)
      local left_side = false
      local right_side = false
      char_index = char_index + 1
      local char = expression_to_evaluate:sub(char_index, char_index)
      if (char == "c") then
         left_side = eval_unary_expression_recursive(false)     
      elseif (char == "!") then
         left_side = eval_unary_expression_recursive(true)          
      elseif (char == "&") then
         left_side = eval_binary_expression_recursive("&",false)
      elseif (char == "|") then
         left_side = eval_binary_expression_recursive("|",false)
      end    

      if(inverse) then
         left_side = not left_side
      end         
       
      char_index = char_index + 1
      local char = expression_to_evaluate:sub(char_index, char_index)
      if (char == "c") then
         right_side = eval_unary_expression_recursive(false)     
      elseif (char == "!") then
         right_side = eval_unary_expression_recursive(true)        
      elseif (char == "&") then
         right_side = eval_binary_expression_recursive("&",false)
      elseif (char == "|") then
         right_side = eval_binary_expression_recursive("|",false)
      end    
       
      if (boolean_operation == "|") then return left_side or right_side
      elseif (boolean_operation == "&") then return left_side and right_side
      end         
   end

   --local function within eval_expression
   eval_unary_expression_recursive = function(inverse)
      local result = false

      local char = expression_to_evaluate:sub(char_index, char_index)
      if (char == "c") then
         if (t_f_values:sub(condition_index, condition_index) == "F") then
            result =  false
         elseif (t_f_values:sub(condition_index, condition_index) == "T") then
            result = true
         end
         condition_index = condition_index + 1
      elseif (char == "!") then
         char_index = char_index + 1
         result = eval_unary_expression_recursive(true)      
          
         if(inverse) then
            result = not result
         end

      elseif (char == "&") then
         result = eval_binary_expression_recursive("&")

         if(inverse) then
            result = not result
         end
      elseif (char == "|") then
         result = eval_binary_expression_recursive("|")
          
         if(inverse) then
            result = not result
         end            
      end

       return result
    end

   local c = expression_to_evaluate:sub(1, 1)
   return eval_unary_expression_recursive(false)
 end


get_tf_pairs = function(expression_info)
   local new_expression_info = copy_expression_info(expression_info)
   local false_rows = {}
   local true_rows = {}
   for i, row in ipairs(expression_info.truth_table) do
      row.index = i
      if (row.result) then
         table.insert(true_rows, row)
      else
         table.insert(false_rows, row)
      end
   end

    local row_pairs = {}

   for _, false_row in ipairs(false_rows) do
      local modified_condition_index = 0
      for _, true_row in ipairs(true_rows) do
         local diff_count = 0
         for condition_index, _ in ipairs(true_row.true_false_values) do
            if ((true_row.true_false_values[condition_index] ~= "X") and (false_row.true_false_values[condition_index] ~= "X")) then
               if (true_row.true_false_values[condition_index] ~= false_row.true_false_values[condition_index]) then
                  diff_count = diff_count + 1
                  modified_condition_index = condition_index
               end
            end
         end
         if (diff_count == 1) then
            if (row_pairs[modified_condition_index] == nil) then
               row_pairs[modified_condition_index] = {}
            end
            local pair = { true_row = true_row.index, false_row = false_row.index }
            if (nil == new_expression_info.condition_true_false_pairs[modified_condition_index]) then
               new_expression_info.condition_true_false_pairs[modified_condition_index] = {}
            end
            table.insert(new_expression_info.condition_true_false_pairs[modified_condition_index], pair)
         end
      end
   end
   return new_expression_info
end

 --Example:get_expression_info("&|cc|cc")
get_expression_info = function(expr)
   local expression_info = new_expression_info(expr)
   local condition_index = 1
   table.insert(expression_info.truth_table, { true_false_values = { "f" }, true_false_values_as_decimal = { 0 } })
   table.insert(expression_info.truth_table, { true_false_values = { "t",}, true_false_values_as_decimal = { 1} })
   
   for i = 1, #expr do
      local c = expr:sub(i, i)
      local look_ahead_one = expr:sub(i+1,i+1)
 
      if (c == "|") then
         expression_info = expand_or(expression_info)
      elseif ((c == "!") and ((look_ahead_one == "&") or (look_ahead_one == "|") or (look_ahead_one == "!"))) then
         expression_info = exclamation_mark(expression_info,condition_index)      
      elseif (c == "&") then
         expression_info = expand_and(expression_info)
      elseif (c == "c") then
         expression_info = resolve_truth_table(expression_info, condition_index)
         condition_index = condition_index + 1
      end
   end
 
   for _, row in ipairs(expression_info.truth_table) do
      row.result = eval_expression(expr, table.concat(row.true_false_values))
   end
   table.sort(expression_info.truth_table, function(t1, t2) return tonumber(table.concat(t1.true_false_values_as_decimal), 2) < tonumber(table.concat(t2.true_false_values_as_decimal), 2) end)
   for i, row in ipairs(expression_info.truth_table) do
      row.index = i - 1
   end
 
   local condition_count = #expression_info.truth_table[1].true_false_values
   for condition_index = 1, condition_count do
      local offset = 0
      for _, row in ipairs(expression_info.truth_table) do
         if (row.true_false_values[condition_index] == "F") then
            offset = offset + 1
         elseif (row.true_false_values[condition_index] == "T") then
            expression_info.condition_offet_table[condition_index] = offset
            break
         end
      end
   end
    expression_info = get_tf_pairs(expression_info)
 
    return expression_info
 end
--End of expression evaluator code

ExpressionStack.__index = ExpressionStack
 
ExpressionStack.create = function(self) 
   local stack = {}
   setmetatable(stack,ExpressionStack)
   stack.stack_top = 0
   stack.list = {}
   return stack
end
local expression_stack = ExpressionStack:create()
 
ExpressionStack.push = function(self,expression, line_number, file_name, function_name, decision_coverage) 
   self.stack_top = self.stack_top + 1
   local expression_info = get_expression_info(expression)

   self.list[self.stack_top] = {
      expression_info = expression_info,
      offset_index = 1,
      condition_index = 1,
      condition_count = #expression_info.truth_table[1].true_false_values,
      infix_expression = "",
      actual_expression = "",
      line_number = line_number,
      file_name = file_name,
      function_name = function_name,
      coverage_storage_array_index = CoverageArrayIndex
   }

   --Increase the array index by the size of the table for the expression
   if(decision_coverage or #expression_info.truth_table[1].true_false_values <= 1) then
      CoverageArrayIndex = CoverageArrayIndex + 1
   else
      CoverageArrayIndex = CoverageArrayIndex + 
      #self.list[self.stack_top].expression_info.truth_table
   end
end

ExpressionStack.get_stack_size = function(self)
   return self.stack_top
end

ExpressionStack.get_stack_top = function(self)
   return self.list[self.stack_top]
end

ExpressionStack.add_to_infix_expression = function(self,text)
   if(self.stack_top > 0) then
      self.list[self.stack_top].infix_expression = self.list[self.stack_top].infix_expression .. text
   end
end

ExpressionStack.add_condition_to_infix_expression = function(self)
   if(self.stack_top > 0) then
      self.list[self.stack_top].infix_expression = self.list[self.stack_top].infix_expression .. text
   end
end

ExpressionStack.add_to_actual_expression = function(self,text)

   --if we are dealing with an expression that contains a nested expression, such as "a && b[c || d] && e", then 
   --we need to make sure we record the full actual expression for all layers of the stack.
   for i = self.stack_top,1,-1 do
      self.list[i].actual_expression = self.list[i].actual_expression .. text
   end

   
end

ExpressionStack.get_infix_expression = function(self,text)
   return self.list[self.stack_top].infix_expression
end

ExpressionStack.pop = function(self) 
   self.stack_top = self.stack_top - 1
end

ExpressionStack.get_next_offset = function(self) 
   local offset_index = self.list[self.stack_top].offset_index
   local condition_offset_table = self.list[self.stack_top].expression_info.condition_offet_table
   local result =  condition_offset_table[offset_index]
   self.list[self.stack_top].offset_index = offset_index + 1
   return result
end

ExpressionStack.get_condition_index = function(self) 
   local condition_index = self.list[self.stack_top].condition_index
   return condition_index
end

ExpressionStack.get_condition_count = function(self) 
   local condition_index = self.list[self.stack_top].condition_count
   return condition_index
end

ExpressionStack.increment_condition_index = function(self) 
   local condition_index = self.list[self.stack_top].condition_index
   self.list[self.stack_top].condition_index = condition_index + 1
   return result
end



comment = function(text)
   write(text)
end
       
first_line_of_function = function(max_nested_expressions, function_name) 
   function_name = function_name

   for i=0,max_nested_expressions-1 do
      write("unsigned int tc_cov_offset_" .. i .. ", tc_temp_cond_" .. i ..", tc_temp_dec_" .. i .. ";")
      write("\n");
      write(Indentation)
   end
end     

insert_close_bracket = function() 
   --Insert COV_STATEMENT, then insert some whitespace after it so that the 
   --next statement will be where it would have been had we not inserted anything.
   local start_index = #InstrumentedText
   local saved_whitespace = ""

   --Go back until you reach the first thing that isn't whitespace
   while(true) do
      if((nil == (InstrumentedText[start_index]:find("[^%s]"))) or --if text is just whitespace, go back
         (nil ~= InstrumentedText[start_index]:find("^%s-#"))) then --if the text starts with a #
           start_index = start_index - 1     
     else
        break
     end
   end

   table.insert(InstrumentedText,start_index+1,"}")
  
end       

insert_open_bracket = function() 
   table.insert(InstrumentedText,"{")
end                        

newline = function(newlines) 
   Indentation = ""
   write(newlines)
   if(expression_stack:get_stack_size() > 0) then
      expression_stack:add_to_actual_expression(newlines)
   end
end

formfeed = function(formfeeds) 
   write(formfeeds)
end
 
space = function(spaces_string) 
   local start_index = #InstrumentedText
   local add_to_indentation = true

   while(nil == InstrumentedText[start_index]:find("\n")) do
      --Search until the start of the string.  Only add to the indentation if
      --the current space that is being added is at the front of the line.
      if(nil ~= InstrumentedText[start_index]:find("[^\t ]")) then
         add_to_indentation = false
      end   
      start_index = start_index - 1
   end
   if(add_to_indentation) then
      Indentation = Indentation .. spaces_string
   end
   write(spaces_string)
   if(expression_stack:get_stack_size() > 0) then
      expression_stack:add_to_actual_expression(spaces_string)
   end
end

tab = function(tabs_string) 
   local start_index = #InstrumentedText
   local add_to_indentation = true

   while(nil == InstrumentedText[start_index]:find("\n")) do
      --Search until the start of the string.  Only add to the indentation if
      --the current space that is being added is at the front of the line.
      if(nil ~= InstrumentedText[start_index]:find("[^\t ]")) then
         add_to_indentation = false
      end   
      start_index = start_index - 1
   end
   if(add_to_indentation) then
      Indentation = Indentation .. tabs_string
   end
   write(tabs_string)
   if(expression_stack:get_stack_size() > 0) then
      expression_stack:add_to_actual_expression(tabs_string)
   end
end
 
start_boolean_expression = function(prefix_expression, line_number, file_name, function_name, decision_coverage)
   expression_stack:push(prefix_expression, line_number, file_name, function_name, decision_coverage)
   local stack_top = expression_stack:get_stack_top()
   if(#prefix_expression == 1 or decision_coverage) then
      write("INST_SINGLE(" .. expression_stack.stack_top-1 .. "," ..
      stack_top.coverage_storage_array_index .. "," .. "(")      
   else
      write("INST_MCDC(" .. expression_stack.stack_top-1 .. "," .. 
      stack_top.coverage_storage_array_index .. "," .. "(")
   end
end

exclamation_mark_operator = function()
   write("!")
   expression_stack:add_to_infix_expression("!")
   expression_stack:add_to_actual_expression("!")
end   

open_expression_parens = function()
   write("(")
   expression_stack:add_to_infix_expression("(")
   expression_stack:add_to_actual_expression("(")
end

close_expression_parens = function()
   write(")")
   expression_stack:add_to_infix_expression(")")
   expression_stack:add_to_actual_expression(")")
end
 
end_boolean_expression = function(prefix_expression, decision_coverage)
   write("))")
   if(#prefix_expression == 1) then
      expression_stack:add_to_infix_expression("c1")
   end
   if(decision_coverage) then
      add_decision_to_results_template()
   else
      add_mcdc_to_results_template()
   end
   expression_stack:pop()
end
 
or_operator = function(text)
   write("||")
   expression_stack:add_to_infix_expression(" || ")
   expression_stack:add_to_actual_expression("||")
end
 
and_operator = function(text)
   write("&&")
   expression_stack:add_to_infix_expression(" && ")
   expression_stack:add_to_actual_expression("&&")
end

insert_statement_coverage = function(line_number,file_name,function_name)
 
   local start_index = #InstrumentedText
    --If there would be some text just before COV_STATEMENT, then insert a newline first
    --unless the text is "{"
    while(true) do

      --Search until we come to the start of the line.  
      if(nil ~= InstrumentedText[start_index]:find("\n")) then
         break
      end

      --If we find some non-whitespace, then insert a newline and break, unless it is a "{"
      if(nil ~= InstrumentedText[start_index]:find("[^ \t]")) then
         if(InstrumentedText[#InstrumentedText] ~= "{") then
            table.insert(InstrumentedText,"\n")
            table.insert(InstrumentedText,Indentation)     
         end      
         break
      end
      start_index = start_index - 1
    end

    table.insert(InstrumentedText,"COV_STATEMENT(" .. CoverageArrayIndex .. ");")
    table.insert(InstrumentedText,"\n")
    table.insert(InstrumentedText,Indentation)    

   add_statement_to_results_template(line_number,
      file_name,
      function_name,
      CoverageArrayIndex
   )  
   CoverageArrayIndex = CoverageArrayIndex + 1
end

add_statement_to_results_template = function(line_number, file_name, function_name, coverage_storage_array_index)
   local data = {}
    
   table.insert(data,[[
Statement {
   Source_File_Name = "]] .. file_name .. [[",
   Function_Name = "]] .. function_name .. [[",
   Line_Number = ]] .. line_number .. [[,
   Array_Index = ]] .. coverage_storage_array_index.. [[,
   Full_Coverage_Achieved = "No",
]])   
   table.insert(data,"}\n")
   table.insert(ResultsTemplate,table.concat(data))
end

add_decision_to_results_template = function()
   local stack_top = expression_stack:get_stack_top()
   local rows_text = {}
   local data = {}
    
   table.insert(data,[[
Decision {
   Source_File_Name = "]] .. stack_top.file_name .. [[",
   Function_Name = "]] .. stack_top.function_name .. [[",
   Simplified_Expression = "]] .. stack_top.infix_expression .. [[",
   Actual_Expression = ]] .. [==[[=[]==] ..stack_top.actual_expression .. [==[]=]]==] .. [[,
   Array_Index = ]] .. stack_top.coverage_storage_array_index .. [[,
   Full_Coverage_Achieved = "No",
   Line_Number = ]] .. stack_top.line_number .. [[,
]])

table.insert(rows_text,[[
   Rows = {
      {Row_ID = 1, Values = "F", Logic = false, Found = "No"},
      {Row_ID = 2, Values = "T", Logic = true,  Found = "No"},
   },]] .. "\n")

   table.insert(data,table.concat(rows_text))
   table.insert(data,"}\n")
   table.insert(ResultsTemplate,table.concat(data))
 end
 
add_mcdc_to_results_template = function()
   local stack_top = expression_stack:get_stack_top()
   local rows_text = {}
   local data = {}
    
   table.insert(data,[[
MCDC {
   Source_File_Name = "]] .. stack_top.file_name .. [[",
   Function_Name = "]] .. stack_top.function_name .. [[",
   Simplified_Expression = "]] .. stack_top.infix_expression .. [[",
   Actual_Expression = ]] .. [==[[=[]==] ..stack_top.actual_expression .. [==[]=]]==] .. [[,
   Array_Index = ]] .. stack_top.coverage_storage_array_index .. [[,
   Number_Of_Conditions = ]] .. stack_top.condition_count .. [[,
   Conditions_Covered = 0,
   Full_Coverage_Achieved = "No",
   Line_Number = ]] .. stack_top.line_number .. [[,
   Covered_Conditions = {},
   Deficient_Conditions = {},
]])

table.insert(rows_text,[[
   Rows = {
]])
               
   local row_count = #stack_top.expression_info.truth_table
   for i,row in ipairs(stack_top.expression_info.truth_table) do
      local spacing = " "
      if(row.result) then
         spacing = "  "
      end
      local formatted_row_id = string.format("%." .. #tostring(row_count) .. "d",i)
      table.insert(rows_text, 
[[
      {Row_ID = ]] .. formatted_row_id .. [[, Values = "]] .. table.concat(row.true_false_values," ") .. [[", Logic = ]] .. tostring(row.result) .. "," .. spacing .. [[Found = "No"]] ..  [[},]] .. "\n")
    end
    table.insert(rows_text,[[
   },]] .. "\n")

   table.insert(data,table.concat(rows_text))
   local pairs_text = {}
   table.insert(pairs_text,[[
   Pairs = {
]])
               
   for condition_number, pair_list in ipairs(stack_top.expression_info.condition_true_false_pairs) do
      for _, pair in ipairs(pair_list) do
         local condition_current_string = "\"c" ..tostring(condition_number) .. "\"," 
         local condition_max_string = "\"c" ..tostring(stack_top.condition_count) .. "\"," 
         local formatted_condition = string.format("%-"  .. tostring(#condition_max_string) .. "s", condition_current_string) 
         local max_row_string = tostring(#tostring(row_count .. ","))
         local formatted_true_row_string = string.format("%-"  .. max_row_string .. "s", pair.true_row .. ",") 
         local formatted_false_row_string = string.format("%-"  .. max_row_string .. "s", pair.false_row .. ",") 

         table.insert(pairs_text,[[
      {Condition = ]] .. formatted_condition .. [[ True_Row = ]] .. formatted_true_row_string .. [[ False_Row = ]] .. formatted_false_row_string .. [[ Found = "No"},]] .. "\n") 
      end
    end
    table.insert(pairs_text,[[
   },]] .. "\n")

   table.insert(data,table.concat(pairs_text))
   table.insert(data,"}\n")
   table.insert(ResultsTemplate,table.concat(data))
 end

get_initial_results = function()
   return table.concat(ResultsTemplate)
end

                           
start_of_file = function()
   write("#include <tc_inst_decl.h>\n")
end
 
start_operand = function(decision_coverage) 
   local offset = expression_stack:get_next_offset()
   local top = expression_stack:get_stack_top()
   local t = top.expression_info.condition_offet_table
   if(decision_coverage == false) then
      write("INST_COND(" .. expression_stack.stack_top-1 .. "," .. offset .. ",")
   end
end

end_operand = function(decision_coverage) 
   local condition_index = expression_stack:get_condition_index()
   local condition_count = expression_stack:get_condition_count()
   local simplified_condition_name = "c" .. condition_index
   expression_stack:add_to_infix_expression(simplified_condition_name)
   expression_stack:increment_condition_index()

   --We want to insert the end ")" right after the condition
   local start_index = #InstrumentedText
   while(true) do
      if((nil == (InstrumentedText[start_index]:find("[^%s]"))) or --if text is just whitespace, go back
         (nil ~= InstrumentedText[start_index]:find("^%s-#"))) --if the text starts with a #
      then
         start_index = start_index - 1
      else
        break
      end
   end
   if(decision_coverage == false) then
      table.insert(InstrumentedText,start_index+1,")")
   end
end
 
end_of_file = function() 
end
 
text = function(str) 
   write(str)
   if(expression_stack:get_stack_size() > 0) then
      expression_stack:add_to_actual_expression(str)
   end
end

sharptext = function(str) 
   write(str)
end

evaluate_instrumentation_commands = function(token_list)
   local list = token_list
   if(nil == list) then
      return nil
   end
   for i=1,#list do
      --if the current list entry is itself a list, then handle that list ala recursion.
      if((BOOLEAN_EXPRESSION == list[i].expression_type) or
         (RELATIONAL_EXPRESSION == list[i].expression_type)) then
         --We must be inside of a function
         if(list[i].function_name ~= nil) then
            if(list[i].coverage_enabled and (list[i].mcdc_coverage or list[i].decision_coverage)) then
               start_boolean_expression(list[i].prefix_expression, 
                  list[i].line_number,
                  SrcFileName,
                  list[i].function_name,
                  list[i].decision_coverage)
            end
         end
         evaluate_instrumentation_commands(list[i])

         --We must be inside of a function
         if(list[i].function_name ~= nil) then         
            if(list[i].coverage_enabled and (list[i].mcdc_coverage or list[i].decision_coverage)) then
               end_boolean_expression(list[i].prefix_expression, list[i].decision_coverage)  
            end        
         end    
      elseif(COMMA_EXPRESSION == list[i].expression_type) then
         evaluate_instrumentation_commands(list[i])      
      elseif(CONDITIONAL_EXPRESSION == list[i].expression_type) then
         evaluate_instrumentation_commands(list[i])                
      elseif(NON_LOGICAL_EXPRESSION == list[i].expression_type) then
         evaluate_instrumentation_commands(list[i])                     
      elseif(EXCLAMATION_MARK_OPERATOR == list[i].t) then
          exclamation_mark_operator()                       
      elseif(OPERAND == list[i].expression_type) then
         if(list[i].function_name ~= nil) then            
            if(list[i].coverage_enabled and (list[i].mcdc_coverage or list[i].decision_coverage)) then
               start_operand(list[i].decision_coverage)  
            end
         end
         evaluate_instrumentation_commands(list[i])

         if(list[i].function_name ~= nil) then   
            if(list[i].coverage_enabled and (list[i].mcdc_coverage or list[i].decision_coverage)) then
               end_operand(list[i].decision_coverage)  
            end      
         end 
      elseif(nil == list[i].t) then
         evaluate_instrumentation_commands(list[i])
      else 
         if(list[i].t == Tokens.TOK_NUMBER) then
            text(list[i].v)
         elseif(list[i].t == Tokens.TOK_CHAR) then
            text(list[i].v)             
         elseif(list[i].t == Tokens.TOK_STRING) then
           text(list[i].v)   
         elseif(list[i].t == Tokens.TOK_COMMENT) then  --Tokens.TOK_COMMENT
           comment(list[i].comment)                                                                                                                             
         elseif(list[i].t == FIRST_LINE_OF_FUNCTION) then
            first_line_of_function(list[i].max_nested_expressions, list[i].function_name)           
         elseif(list[i].t == INSERT_OPEN_BRACKET) then
           insert_open_bracket()                           
         elseif(list[i].t == INSERT_CLOSE_BRACKET) then
           insert_close_bracket()                                                  
         elseif(list[i].t == Tokens.TOK_NEWLINE) then
            newline(list[i].v)
         elseif(list[i].t == Tokens.TOK_FORMFEED) then
            formfeed(list[i].v)            
         elseif(list[i].t == Tokens.TOK_POUND) then
            sharptext(list[i].sharptext)           
         elseif(list[i].t == Tokens.TOK_SPACE) then
            space(list[i].v)   
         elseif(list[i].t == Tokens.TOK_TAB) then
            tab(list[i].v)              
         elseif(list[i].t == OPEN_EXPRESSION_PARENS) then
            open_expression_parens()           
         elseif(list[i].t == CLOSE_EXPRESSION_PARENS) then
            close_expression_parens()                        
         elseif(list[i].t == START_OF_FILE) then
             start_of_file()           
         elseif(list[i].t == END_OF_FILE) then
            end_of_file()                   
         elseif(list[i].t == OR_OPERATOR) then
            or_operator()                  
         elseif(list[i].t == AND_OPERATOR) then
            and_operator()           
         elseif(list[i].t == INSERT_STATEMENT_COVERAGE) then
            if(list[i].function_name ~= nil) then               
               if(list[i].coverage_enabled and list[i].statement_coverage) then
                  insert_statement_coverage(list[i].line_number,
                     SrcFileName,
                     list[i].function_name
                  )  
               end    
            end                                                
         else
             text(list[i].v)
         end
      end
   end
end

--End of code used for instrumenting


--Start of code used for parsing
local coverage_control_commands = {}
coverage_control_commands["ENABLE_COVERAGE"] = function() 
   CoverageEnabled = true
end
coverage_control_commands["DISABLE_COVERAGE"] = function() 
   CoverageEnabled = false
end

insert_statement_coverage_command = function(token_list,line_number,function_name)
   table.insert(token_list, {t = INSERT_STATEMENT_COVERAGE, 
      line_number = line_number,
      function_name = function_name,
      coverage_enabled = CoverageEnabled,
      statement_coverage = StatementCoverage
   })   
end

remove_inner_boolean_expressions = function(token_list)
   local list = token_list   
 
   for i=1,#list do
      local inner_expression_info = nil 
      if(list[i].expression_type == BOOLEAN_EXPRESSION) then
         list[i].expression_type = nil
      elseif((list[i].expression_type == NON_LOGICAL_EXPRESSION) or 
             (list[i].expression_type == COMMA_EXPRESSION) or      
             (list[i].expression_type == RELATIONAL_EXPRESSION) or               
             (list[i].expression_type == CONDITIONAL_EXPRESSION) or  
             (list[i].expression_type == ARRAY_INDEX) or
             (list[i].expression_type == COMPOUND_STATEMENT_WITHIN_EXPRESSION) or 
             (list[i].expression_type == FUNCTION_PARAMETERS)) then
         --do nothing
      elseif(nil == list[i].t) then
         remove_inner_boolean_expressions(list[i])
      end
   end
 end

 find_exclamation_mark_operators = function(token_list)
   local list = token_list   

   for i=1,#list do
      if((list[i].expression_type == NON_LOGICAL_EXPRESSION) or 
         (list[i].expression_type == COMMA_EXPRESSION) or      
         (list[i].expression_type == RELATIONAL_EXPRESSION) or               
         (list[i].expression_type == CONDITIONAL_EXPRESSION) or  
         (list[i].expression_type == ARRAY_INDEX) or
         (list[i].expression_type == COMPOUND_STATEMENT_WITHIN_EXPRESSION) or 
         (list[i].expression_type == FUNCTION_PARAMETERS)) then
         --do nothing
      elseif(list[i].t == Tokens.TOK_EXCLAMATIONMARK) then
         list[i].t = EXCLAMATION_MARK_OPERATOR         
      elseif(nil == list[i].t) then
         find_exclamation_mark_operators(list[i])
      end
   end
end

remove_inner_relational_expressions = function(token_list)
   local list = token_list   

   for i=1,#list do
      if(list[i].expression_type == RELATIONAL_EXPRESSION) then
         list[i].expression_type = BOOLEAN_EXPRESSION
      elseif((list[i].expression_type == NON_LOGICAL_EXPRESSION) or 
         (list[i].expression_type == COMMA_EXPRESSION) or                
         (list[i].expression_type == CONDITIONAL_EXPRESSION) or  
         (list[i].expression_type == ARRAY_INDEX) or
         (list[i].expression_type == COMPOUND_STATEMENT_WITHIN_EXPRESSION) or 
         (list[i].expression_type == FUNCTION_PARAMETERS)) then
         --do nothing      
      elseif(nil == list[i].t) then
         remove_inner_relational_expressions(list[i])
      end
   end
end

typeof = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
 
   --consume the 'typeof'
   token = at(token_list,token)
 
   --consume the (
   token = at(token_list,token,Tokens.TOK_OPENPAREN)
 
   token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
 
   --consume the first )
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
 
   return token, token_list
 end
 
enum = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = at(token_list,tok)
   if(token.t == Tokens.TOK_OPENBRACE) then
      --consume the "{"
      token = at(token_list,token,Tokens.TOK_OPENBRACE)
 
      token, inner_token_list = enumerator_list(token); table.insert(token_list,inner_token_list)
 
      --consume the "}"
      token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
 
    else
      --consume the identifier
      token = at(token_list,token)
      if(token.t == Tokens.TOK_OPENBRACE) then
         --consume the "{"
         token = at(token_list,token,Tokens.TOK_OPENBRACE)
     
         token, inner_token_list = enumerator_list(token); table.insert(token_list,inner_token_list)
 
         --consume the "}"
         token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
      end
   end
 
   return token, token_list
 end
 
 
 --Struct definitions are superfluous for our needs, so let's just consume all tokens until the
 --last matching pair of {} is found.
struct = function(tok)
   local token_list = {}
   local token = at(token_list,tok)
   local open_count = 0

   while(true) do
      if((token.v == "__attribute__") or (token.v == "__attribute")) then 
         token, inner_token_list = attribute(token); table.insert(token_list, inner_token_list)  
      elseif(token.v == "__declspec") then 
         token, inner_token_list = declspec(token); table.insert(token_list, inner_token_list)  
      elseif(token.v == "_Pragma") or word_matches(token,"__pragma") then     
         token, inner_token_list = pragma_operator(token);table.insert(token_list, inner_token_list)        
      else
         break
      end
   end

   if(token.t ~= Tokens.TOK_OPENBRACE) then
      --consume the tag
      token = at(token_list,token)
   end
 
   if(token.t == Tokens.TOK_OPENBRACE) then
      open_count = open_count + 1
       
      while(0 < open_count) do
         token = at(token_list,token)
         if(token.t == Tokens.TOK_OPENBRACE) then
           open_count = open_count + 1
         elseif(token.t == Tokens.TOK_CLOSEBRACE) then
           open_count = open_count - 1
         end
      end      
   
      --consume the "}"
      token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
   end
 
   return token, token_list
end
 
declspec = function(tok)
   local token = tok
   local token_list = {}
   local inner_token_list = {}   

   --consume declspec
   token = at(token_list,token)

   --assume an expression
   token, inner_token_list = skip_args(token); table.insert(token_list,inner_token_list)

   return token, token_list
end

attribute = function(tok)
   local token_list = {}
   local token = tok
   local open_p_count = 2

   token = at(token_list,token)
   --consume the first (
   token = at(token_list,token)

   --consume the second (
   token = at(token_list,token)
   while(0 < open_p_count) do
      if(token.t == Tokens.TOK_OPENPAREN) then
         open_p_count = open_p_count + 1
      elseif(token.t == Tokens.TOK_CLOSEPAREN) then
         open_p_count = open_p_count - 1
      end
      token = at(token_list,token)
   end

   return token, token_list
end
 
builtin_va_arg = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   --consume __builtin_va_arg name
   token = at(token_list,token)
   --consume open parens
   token = at(token_list,token,Tokens.TOK_OPENPAREN) 

   --consume expression
   token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list)

   --consume comma
   token = at(token_list,token,Tokens.TOK_COMMA)

   --consume type name
   token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)

   --consume close parens
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)   

   return token, token_list 
end
 
builtin_offsetof = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   --consume builtin_offsetof name
   token = at(token_list,token)
   --consume open parens
   token = at(token_list,token,Tokens.TOK_OPENPAREN) 

   --consume type name
   token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)

   --consume comma
   token = at(token_list,token,Tokens.TOK_COMMA)

   --consume expression
   token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list)

   --consume close parens
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)    

   return token, token_list
end
 
union = function(tok)
   local token_list = {}
   local token = at(token_list,tok)
   local open_count = 0

   while(true) do
      if((token.v == "__attribute__") or (token.v == "__attribute")) then 
         token, inner_token_list = attribute(token); table.insert(token_list, inner_token_list)  
      elseif(token.v == "__declspec") then 
         token, inner_token_list = declspec(token); table.insert(token_list, inner_token_list)  
      elseif(token.v == "_Pragma") or word_matches(token,"__pragma") then     
         token, inner_token_list = pragma_operator(token);table.insert(token_list, inner_token_list)        
      else
         break
      end
   end

   if(token.t ~= Tokens.TOK_OPENBRACE) then
      --consume the tag
      token = at(token_list,token)
   end

   if(token.t == Tokens.TOK_OPENBRACE) then
      --consume the "{"
      open_count = open_count + 1
     

      while(0 < open_count) do
         token = at(token_list,token)
         if(token.t == Tokens.TOK_OPENBRACE) then
            open_count = open_count + 1
         elseif(token.t == Tokens.TOK_CLOSEBRACE) then
            open_count = open_count - 1
         end
      end      

      --consume the "}"
      token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
   end

   return token, token_list
end
 
add_ident = function(ident_name,ident_type)
   if(ident_name == nil) then
      error("File: " .. SrcFileName .. " Error adding identifier")
   end

   if(nil == IdentTable[ident_name]) then
      IdentTable[ident_name] = {}
      IdentTable[ident_name].top = 0
      IdentTable[ident_name].stack = {}
      IdentTable[ident_name].stack[IdentTable[ident_name].top] = ident_type
      IdentTable[ident_name].top = IdentTable[ident_name].top + 1
      table.insert(IdentStack,ident_name)
   else
      IdentTable[ident_name].stack[IdentTable[ident_name].top] = ident_type
      IdentTable[ident_name].top = IdentTable[ident_name].top + 1
      table.insert(IdentStack,ident_name)
   end
end
 
function remove_ident(ident_name)
   if(nil ~= IdentTable[ident_name]) then
      IdentTable[ident_name].top = IdentTable[ident_name].top - 1
   end
end


get_ident = function(tok)
   
   local name = tok.v
   if(nil == IdentTable[name]) then
      return nil
   else
      local top = IdentTable[name].top - 1
      return IdentTable[name].stack[top]
   end
end
  
enumerator_list = function(tok)
   local token_list = {}

   local token, inner_token_list = enumerator(tok); table.insert(token_list,inner_token_list)

   while(token.t == Tokens.TOK_COMMA) do
      token = at(token_list,token)

      if(token.t == Tokens.TOK_CLOSEBRACE) then
        break
      end

      token, inner_token_list = enumerator(token); table.insert(token_list,inner_token_list)
   end
   return token, token_list

end
 
enumerator = function(tok)
   local token_list = {}

   --consume the identifier
   local token = at(token_list,tok)

  --skip everything until the next comma or the }.
   while(1) do
      if(token.t == Tokens.TOK_COMMA) then
         break
      elseif(token.t == Tokens.TOK_CLOSEBRACE) then
         break
      end
      token = at(token_list,token)
   end

   return token, token_list

end
 
 LexerLookup = {}
 
lexer_found_number = function(index) 
   local token = {}
   token.t = Tokens.TOK_NUMBER
   token.v = Buffer:match("%d+[_a-zA-Z%.%d]*",index)
   token.buffer_loc = index + token.v:len()
   return token
end
 
lexer_found_word = function(index) 
   local token = {}
   local word = Buffer:match("[_%a]+[%d_%a]*",index)
   token.t = Tokens.TOK_WORD
   token.v = word
   
   token.buffer_loc = index + #word
   return token
end
 

lexer_found_L = function(index) 
   local token = {}
   if("\"" == Buffer:sub(index+1,index+1)) then
      token = LexerLookup[34](index+1) 
      token.v = "L" .. token.v
   elseif("\'" == Buffer:sub(index+1,index+1)) then
      token = LexerLookup[39](index+1)
      token.v = "L" .. token.v
   else
      token.t = Tokens.TOK_WORD
      token.v = Buffer:match("[_%a]+[0-9_%a]*",index)
      token.buffer_loc = index + token.v:len()
   end

   return token
end
 
LexerLookup[32] = function(index)
   local token = {}
   local current_index = index

   local spaces = Buffer:match(" +",current_index)

   token.t = Tokens.TOK_SPACE
   token.buffer_loc = current_index + #spaces
   token.v = spaces
   token.ws_count = #spaces

   return token

end
 
LexerLookup[9] = function(index)
   local token = {}
   local current_index = index
   local ws = {}
 
   while(9 == Buffer:byte(current_index)) do
     current_index = current_index + 1  
     table.insert(ws,"\t")
   end
   
   token.t = Tokens.TOK_TAB
   token.buffer_loc = current_index
   token.v = table.concat(ws)
   token.ws_count = #ws

   return token

end

LexerLookup[13] = function(index)
   local token = {}
   local current_index = index
   local ws = {}
   local increment_line_number_count = 0

   while(13 == Buffer:byte(current_index)) do
      if(10 == Buffer:byte(index+1)) then
         current_index = current_index + 2  
         increment_line_number_count = increment_line_number_count + 1
         table.insert(ws,"\r\n")
      else
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Carriage return without newline.")
      end 
   end
   
   token.t = Tokens.TOK_NEWLINE
   token.buffer_loc = current_index
   token.v = table.concat(ws)
   token.ws_count = #ws
   token.increment_line_number_count = increment_line_number_count

   return token
end

--handle form form-feed character
LexerLookup[12] = function(index)
   local token = {}
   local current_index = index
   local ws = {}
 
   while(12 == Buffer:byte(current_index)) do
      current_index = current_index + 1  
      table.insert(ws,"\f")
   end
   
   token.t = Tokens.TOK_FORMFEED
   token.buffer_loc = current_index
   token.v = table.concat(ws)
   token.ws_count = #ws

   return token
end

LexerLookup[10] = function(index)
   local token = {}
   local current_index = index

   local newlines = Buffer:match("\n+",current_index)
   token.t = Tokens.TOK_NEWLINE
   token.buffer_loc = current_index + #newlines
   token.v = newlines
   token.ws_count = #newlines
   token.increment_line_number_count = #newlines

   return token
end

LexerLookup[123] = function(index)
   local token = {}
   token.t = Tokens.TOK_OPENBRACE
   token.v = "{"
   token.buffer_loc = index + 1
   return token
end 

LexerLookup[40] = function(index)
   local token = {}
   token.t = Tokens.TOK_OPENPAREN
   token.v = "("
   token.buffer_loc = index + 1
   return token
end 

LexerLookup[125] = function(index)
   local token = {}
   token.t = Tokens.TOK_CLOSEBRACE
   token.v = "}"
   token.buffer_loc = index + 1
   return token
end 

LexerLookup[126] = function(index)
   local token = {}
   token.t = Tokens.TOK_TILDE
   token.v = "~"
   token.buffer_loc = index + 1
 
   return token
end 

LexerLookup[41] = function(index)
   local token = {}
   token.t = Tokens.TOK_CLOSEPAREN
   token.v = ")"
   token.buffer_loc = index + 1
 
   return token
end 

local digits = {}
digits[48] = true
digits[49] = true
digits[50] = true
digits[51] = true
digits[52] = true
digits[53] = true
digits[54] = true
digits[55] = true
digits[56] = true
digits[57] = true
digits[58] = true

LexerLookup[46] = function(index)
   local token = {}
   token.t = Tokens.TOK_PERIOD
   token.v = "."
   token.buffer_loc = index + 1

   if(".." == Buffer:sub(index+1,index+2)) then
      token.t = Tokens.TOK_ELLIPSES
      token.v = "..."
      token.buffer_loc = token.buffer_loc + 2
   else
      test_byte = Buffer:byte(index+1)
      if(nil ~= digits[test_byte]) then
         token.t = Tokens.TOK_NUMBER
         token.v = Buffer:match("%.+[_a-zA-Z%.%d]*",index)
         token.buffer_loc = index + token.v:len()
      end
   end

   return token
end
 
LexerLookup[44] = function(index)
   local token = {}
   token.t = Tokens.TOK_COMMA
   token.v = ","
   token.buffer_loc = index + 1

   return token
end
 

LexerLookup[59] = function(index)
   local token = {}
   token.t = Tokens.TOK_SEMICOLON
   token.v = ";"
   token.buffer_loc = index + 1

   return token
end

LexerLookup[63] = function(index)
   local token = {}
   token.t = Tokens.TOK_QUESTIONMARK
   token.v = "?"
   token.buffer_loc = index + 1

   return token
end
 

LexerLookup[92] = function(index)
   local token = {}
   token.t = Tokens.TOK_BACKSLASH
   token.v = "\\"
   token.buffer_loc = index + 1
   return token
end

LexerLookup[33] = function(index)
   local token = {}
   token.t = Tokens.TOK_EXCLAMATIONMARK
   token.v = "!"
   local current_index = index+1
   if(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_RELATIONAL
      token.v = "!="
      current_index = current_index+1 
   end
   token.buffer_loc = current_index
   return token
end

LexerLookup[38] = function(index)
   local token = {}
   token.t = Tokens.TOK_AMPERSAND
   token.v = "&"
   local current_index = index+1
   if(38 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_AND
      token.v = "&&"
      current_index = current_index+1 
   elseif(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "&="
      current_index = current_index+1 
   end
   token.buffer_loc = current_index
   return token
end
 
LexerLookup[94] = function(index)
   local token = {}
   --^
   token.t = Tokens.TOK_EXCLUSIVEOR
   token.v = "^"
   local current_index = index+1
   if(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "^="
      current_index = current_index+1 
   end

   token.buffer_loc = current_index
   return token
end


LexerLookup[124] = function(index)
   local token = {}
   token.t = Tokens.TOK_BITWISEOR
   token.v = "|"
   local current_index = index+1
   if(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "|="
      current_index = current_index+1 
   elseif(124 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_OR
      token.v = "||"
      current_index = current_index+1 
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[39] = function(index) 
   local token = {}
   token.t = Tokens.TOK_CHAR
   local current_index = index + 1

   while(1) do
      if(39 == Buffer:byte(current_index)) then
         current_index = current_index + 1
         break
      elseif(92 == Buffer:byte(current_index)) then
         current_index = current_index + 1  
      elseif(nil == Buffer:find("\'",current_index)) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
      end
      current_index = current_index + 1
   end

   token.v = Buffer:sub(index,current_index-1)
   token.buffer_loc = current_index
   return token
end
 
LexerLookup[34] = function(index) 
   local token = {t = Tokens.TOK_STRING}
   local current_index = index + 1

   ::top::
   while(true) do
      r = Buffer:sub(current_index,current_index)
      if(r == nil) then
         break
      elseif(r == "\\") then
         current_index = current_index + 2
      elseif(r == "\"") then
         current_index = current_index + 1
         break
      elseif(r == "\r") then
          break
      elseif(r == "\n") then 
         break
      else
         current_index = current_index + 1
          if(current_index > #Buffer) then
              break
          end
      end
    end

   token.buffer_loc = current_index
   token.v = Buffer:sub(index,current_index-1)
   return token
end
 
LexerLookup[95] = lexer_found_word
LexerLookup[97] = lexer_found_word
LexerLookup[98] = lexer_found_word
LexerLookup[99] = lexer_found_word
LexerLookup[100] = lexer_found_word
LexerLookup[101] = lexer_found_word
LexerLookup[102] = lexer_found_word
LexerLookup[103] = lexer_found_word
LexerLookup[104] = lexer_found_word
LexerLookup[105] = lexer_found_word
LexerLookup[106] = lexer_found_word
LexerLookup[107] = lexer_found_word
LexerLookup[108] = lexer_found_word
LexerLookup[109] = lexer_found_word
LexerLookup[110] = lexer_found_word
LexerLookup[111] = lexer_found_word
LexerLookup[112] = lexer_found_word
LexerLookup[113] = lexer_found_word
LexerLookup[114] = lexer_found_word
LexerLookup[115] = lexer_found_word
LexerLookup[116] = lexer_found_word
LexerLookup[117] = lexer_found_word
LexerLookup[118] = lexer_found_word
LexerLookup[119] = lexer_found_word
LexerLookup[120] = lexer_found_word
LexerLookup[121] = lexer_found_word
LexerLookup[122] = lexer_found_word
LexerLookup[65] = lexer_found_word
LexerLookup[66] = lexer_found_word
LexerLookup[67] = lexer_found_word
LexerLookup[68] = lexer_found_word
LexerLookup[69] = lexer_found_word
LexerLookup[70] = lexer_found_word
LexerLookup[71] = lexer_found_word
LexerLookup[72] = lexer_found_word
LexerLookup[73] = lexer_found_word
LexerLookup[74] = lexer_found_word
LexerLookup[75] = lexer_found_word
LexerLookup[76] = lexer_found_L
LexerLookup[77] = lexer_found_word
LexerLookup[78] = lexer_found_word
LexerLookup[79] = lexer_found_word
LexerLookup[80] = lexer_found_word
LexerLookup[81] = lexer_found_word
LexerLookup[82] = lexer_found_word
LexerLookup[83] = lexer_found_word
LexerLookup[84] = lexer_found_word
LexerLookup[85] = lexer_found_word
LexerLookup[86] = lexer_found_word
LexerLookup[87] = lexer_found_word
LexerLookup[88] = lexer_found_word
LexerLookup[89] = lexer_found_word
LexerLookup[90] = lexer_found_word
LexerLookup[48] = lexer_found_number
LexerLookup[49] = lexer_found_number
LexerLookup[50] = lexer_found_number
LexerLookup[51] = lexer_found_number
LexerLookup[52] = lexer_found_number
LexerLookup[53] = lexer_found_number
LexerLookup[54] = lexer_found_number
LexerLookup[55] = lexer_found_number
LexerLookup[56] = lexer_found_number
LexerLookup[57] = lexer_found_number
 
LexerLookup[35] = function(index)
   local token = {}
   local current_index

   token.t = Tokens.TOK_POUND
   local end_index  = Buffer:find("\n",index) 
   if(nil == end_index) then
      current_index = #Buffer
   else
      current_index = end_index - 1
   end

   token.sharptext = Buffer:sub(index,current_index)
   token.buffer_loc = current_index + 1

   if(token.sharptext:find("#include")) then 
      msg = "Warning:  File should be preprocessed before instrumenting. Syntax errors may occur.  #include statement found in " .. SrcFileName
      --print(msg)
   elseif(token.sharptext:find("#define")) then 
      msg = "Warning:  File should be preprocessed before instrumenting.  Syntax errors may occur. #define statement found in " .. SrcFileName
      --print(msg)
   elseif(token.sharptext:find("#undef")) then 
      msg = "Warning:  File should be preprocessed before instrumenting.  Syntax errors may occur. #undef statement found in " .. SrcFileName
      --print(msg)
   elseif(token.sharptext:find("#pragma")) then 
      white_space = token
      pragma_string = token.sharptext:sub(8,#token.sharptext)
      pragma_string = string.gsub(pragma_string,"%s","")
    
      if(nil ~= coverage_control_commands[pragma_string]) then
         coverage_control_commands[pragma_string]()
      end

   elseif("#line" == token.sharptext:sub(1,5)) then
      pragma_string = token.sharptext:sub(6,#token.sharptext)
      first_space = pragma_string:find(" ")
 
      if(nil == first_space) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
      end

      second_space = pragma_string:find("%s",first_space+1)

      if(nil ~= second_space) then
         line_directive_line_number = pragma_string:sub(first_space+1,second_space)
  
         if(nil ~= pragma_string:find(".",second_space+1)) then
            pragma_string = pragma_string:gsub("\n","")
            --put [[ ]] quotes around the file name
            line_directive_file_name =  "[[" .. pragma_string:sub(second_space+1,#pragma_string) .. "]]"
         end
      end
   end  
   return token
end

LexerLookup[58] = function(index)
   local token = {}
   token.t = Tokens.TOK_COLON
   token.v = ":"
   token.buffer_loc = index + 1
   return token
end
 
LexerLookup[42] = function(index)
   local token = {}
   token.t = Tokens.TOK_STAR
   token.v = "*"
   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "*="
      current_index = current_index+1 
   end
   token.buffer_loc = current_index
   return token
end
 
LexerLookup[64] = function(index)
   local token = {}
   token.t = Tokens.TOK_AT
   token.v = "@"
   token.buffer_loc = index + 1
   return token
end

LexerLookup[61] = function(index)
   local token = {}
   token.t = Tokens.TOK_ASSIGNMENT
   token.v = "="
   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_RELATIONAL
      token.v = "=="
      current_index = current_index+1 
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[91] = function(index)
   local token = {}
   token.t = Tokens.TOK_OPENBRACKET
   token.v = "["
   local current_index = index + 1
   token.buffer_loc = current_index
   return token
end
 
LexerLookup[93] = function(index)
   local token = {}
   token.t = Tokens.TOK_CLOSEBRACKET
   token.v = "]"
   local current_index = index + 1
   token.buffer_loc = current_index
   return token
end
 
LexerLookup[47] = function(index)
   local token = {}
   local start_lua_code = nil
   local end_lua_code = nil
   local start_of_slashes = nil
   local increment_line_number_count = 0
   token.t = Tokens.TOK_FORWARDSLASH
   token.v = "/"

   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      current_index = current_index+1 
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "/="
   elseif(47 == Buffer:byte(current_index)) then
      start_of_slashes = current_index
      token.t = Tokens.TOK_COMMENT
      current_index = Buffer:find("\n",current_index)
     if(nil == current_index) then
       current_index = start_of_slashes + 1
       token.t = Tokens.TOK_COMMENT
     end
     
   elseif(42 == Buffer:byte(current_index)) then
     local end_index = Buffer:find("*/",current_index) 
     local temp_index = current_index
     
     temp_index = Buffer:find("\n",temp_index)
     while((nil ~= temp_index) and
           (end_index > temp_index)) do
        temp_index = temp_index + 1
        increment_line_number_count = increment_line_number_count + 1
        temp_index = Buffer:find("\n",temp_index)
     end

     current_index = end_index + 2
     token.t = Tokens.TOK_COMMENT
   end
   token.buffer_loc = current_index
   
   start_lua_code = Buffer:find("<<<",index)
   if(nil ~= start_lua_code) then
      end_lua_code = Buffer:find(">>>",start_lua_code)
      if(nil == end_lua_code) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
      else
         lua_code = Buffer:sub(start_lua_code+3,end_lua_code-1)
         load(lua_code)()
      end
   end
   token.increment_line_number_count = increment_line_number_count
   token.comment = Buffer:sub(index,current_index-1) 
   return token
end
 
LexerLookup[37] = function(index)
   local token = {}
   token.t = Tokens.TOK_MOD
   token.v = "%"
   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      current_index = current_index+1 
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "%="
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[43] = function(index)
   local token = {}
   token.t = Tokens.TOK_PLUS
   token.v = "+"
   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      current_index = current_index + 1
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "+="
   elseif(43 == Buffer:byte(current_index)) then
      current_index = current_index + 1
      token.t = Tokens.TOK_PLUSPLUS
      token.v = "++"
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[45] = function(index)
   local token = {}
   token.t = Tokens.TOK_MINUS
   token.v = "-"
   local current_index = index + 1
   if(61 == Buffer:byte(current_index)) then
      current_index = current_index + 1
      token.t = Tokens.TOK_ASSIGNMENT
      token.v = "-="
   elseif(62 == Buffer:byte(current_index)) then
      current_index = current_index + 1
      token.t = Tokens.TOK_INDIRECTION_ARROW
      token.v = "->"
   elseif(45 == Buffer:byte(current_index)) then
      current_index = current_index + 1
      token.t = Tokens.TOK_MINUSMINUS
      token.v = "--"
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[60] = function(index)
   local token = {}
   token.t = Tokens.TOK_RELATIONAL
   token.v = "<"
   local current_index = index + 1
   if(60 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_SHIFT
      token.v = "<<"
      current_index = current_index + 1
      if(61 == Buffer:byte(current_index)) then
         current_index = current_index + 1
         token.t = Tokens.TOK_ASSIGNMENT
         token.v = "<<="     
      end
   elseif(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_RELATIONAL
      token.v = "<="
      current_index = current_index + 1
   end

   token.buffer_loc = current_index
   return token
end
 
LexerLookup[62] = function(index)
   local token = {}
   token.t = Tokens.TOK_RELATIONAL
   token.v = ">"
   local current_index = index + 1
   if(62 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_SHIFT
      token.v = ">>"
      current_index = current_index + 1
      if("=" == Buffer:byte(current_index)) then
         current_index = current_index + 1
         token.t = Tokens.TOK_ASSIGNMENT
         token.v = ">>="      
      end
   elseif(61 == Buffer:byte(current_index)) then
      token.t = Tokens.TOK_RELATIONAL
      token.v = ">="
      current_index = current_index + 1
   end
   token.buffer_loc = current_index
   return token
end
 
word_matches = function(token,str)
   if(token.v == str) then
      return true 
   end 
   return false
 end
 
local ws_toks = {
  [Tokens.TOK_SPACE] = 1,
  [Tokens.TOK_TAB] = 1,
  [Tokens.TOK_NEWLINE] = 1,
  [Tokens.TOK_FORMFEED] = 1,    
  [Tokens.TOK_COMMENT] = 1,
  [Tokens.TOK_POUND] = 1,
  [Tokens.TOK_BACKSLASH] = 1
}

local last_buffer_loc = -1
local last_buffer_loc_loop_detection_count = 0

 at = function(token_list,tok,expected_token)
   local result = false
   local token = tok

   if(END_OF_FILE == token.t) then
      error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Unexpected end of file. ")
   elseif(nil == token) then
      error("File: " .. SrcFileName .. " nil token")
   else
      if(expected_token ~= nil) then
         if(token.t ~= expected_token) then
            error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.  Expected: " .. TokenTextDebug[expected_token] .. " Actual: " .. token.v)
         end
      end
   end

   while(true) do
      local first = Buffer:byte(token.buffer_loc)
      if((nil ~= LexerLookup[first]) and (token.buffer_loc <= BufferLength)) then
         table.insert(token_list,token)
         local previous_line_number = token.line_number
         local previous_function_name = token.function_name
         result,token = pcall(LexerLookup[first],token.buffer_loc)

         if(result == false) then
            error("File: " .. SrcFileName .. " Line: " .. previous_line_number .. " Syntax Error")
         end
         token.function_name = previous_function_name         
         token.line_number = previous_line_number     
         if(token.increment_line_number_count ~= nil) then
            token.line_number = token.line_number + token.increment_line_number_count
         end
         if(END_OF_FILE == token.t) then
            error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Unexpected end of file. ")
         elseif(nil == token) then
            error("File: " .. SrcFileName .. " nil token")   
         elseif(nil == ws_toks[token.t]) then
             break
         end   
      else    
         --If we aren't at the end of the file, the error must be because we found a bad character
         if(token.buffer_loc <= BufferLength) then 
            error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Found unknown character: " .. tostring(first) .. " Ensure file encoding is UTF-8.")
         end
         --Insert the very last token into the token list
         table.insert(token_list,token)
         local eof_token = {t=END_OF_FILE, line_number = token.line_number}
         return eof_token,index
      end
   end  
   local temp_token_list = {}
   --

   ----Concatenate strings
   if(token.t == Tokens.TOK_STRING) then
      local lookahead = at(temp_token_list,token)
      if(lookahead.t == Tokens.TOK_STRING) then
         table.insert(token_list,temp_token_list)
         token = lookahead
      end
   end

   if(token.v == "__extension__") then token = at(token_list,token)
   end

   return token
end

is_new_type = function(tok)
   local test_ident = get_ident(tok)
   if(nil ~= test_ident) then
      return test_ident == NEW_TYPE
   end
   return false
end
 
specifier_qualifier_list = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local type_found = false

   while(true) do
      if(is_basic_type(token)) then     
         type_found = true
         token = at(token_list,token);  
         while(is_basic_type(token)) do
            token = at(token_list,token);  
         end         
      elseif(is_single_token_specifier_qualifier(token)) then
         token = at(token_list,token);
      elseif(nil ~= multiple_token_extension_keywords[token.v]) then
         token, inner_token_list = multiple_token_extension_keywords[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(nil ~= multiple_token_specifier_qualifiers[token.v]) then
         type_found = true
         token, inner_token_list = multiple_token_specifier_qualifiers[token.v](token); table.insert(token_list, inner_token_list)           
      elseif(token.t == Tokens.TOK_WORD) then
         if(type_found) then
            break
         elseif(is_new_type(token)) then
            type_found = true
            token = at(token_list,token);
         else
            break
         end
      else
         break
      end
   end
   return token, token_list
end
 
argument_expression_list = function(tok)
   local token_list = {}

   local token, inner_token_list = assignment_expression(tok); table.insert(token_list,inner_token_list)
   while(token.t == Tokens.TOK_COMMA) do
      token = at(token_list,token)
      token, inner_token_list = assignment_expression(token); table.insert(token_list,inner_token_list)
   end

   return token, token_list
end
 
primary_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local identifier = nil

   if(token.t == Tokens.TOK_NUMBER) then
      token = at(token_list,token)   
   elseif(token.t == Tokens.TOK_STRING)  then
      token = at(token_list,token) 
   elseif(token.t == Tokens.TOK_CHAR) then
      token = at(token_list,token)          
   elseif(token.t == Tokens.TOK_OPENPAREN) then
      local open_parens_token = token
      token = at(token_list,token)   
      if(token.t == Tokens.TOK_OPENBRACE) then
         token, inner_token_list = compound_statement(token,nil,nil,false); table.insert(token_list,inner_token_list)
         token = at(token_list,token)       
         inner_token_list.expression_type = COMPOUND_STATEMENT_WITHIN_EXPRESSION
      else
         token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
         local close_parens_token = token
         --If an expression has multiple parenthesis surrounding it, be sure to instrument those
         --parenthesis.
         --e.g, ((a && b)) should be instrumented as 
         --if((INST_MCDC(0,1,(INST_COND(0,1,a) && INST_COND(0,1,b)))))
         --instead of
         --if(INST_MCDC(0,1,((INST_COND(0,1,a) && INST_COND(0,1,b)))))
         if(has_child_boolean_expression(inner_token_list)) then
            open_parens_token.t = OPEN_EXPRESSION_PARENS
            token_list.line_number = token.line_number
            token_list.function_name = token.function_name
            token_list.expression_type = BOOLEAN_EXPRESSION
            token_list.coverage_enabled = CoverageEnabled
            token_list.decision_coverage = DecisionCoverage
            token_list.mcdc_coverage = MCDCCoverage
            local prefix_expression = get_prefix_expression({inner_token_list})
            token_list.prefix_expression = prefix_expression
            remove_inner_boolean_expressions(token_list)  
            find_exclamation_mark_operators(token_list)
            token = at(token_list,token,Tokens.TOK_CLOSEPAREN) 
            close_parens_token.t = CLOSE_EXPRESSION_PARENS
         else
            token = at(token_list,token,Tokens.TOK_CLOSEPAREN) 
         end 
      end
   elseif(token.v == "__pragma") then     
      token, inner_token_list = pragma_operator(token,nil); table.insert(token_list,inner_token_list) 
   elseif(token.v == "__builtin_va_arg") then
      token, inner_token_list = builtin_va_arg(token,nil); table.insert(token_list,inner_token_list) 
   elseif(token.v == "__builtin_convertvector") then
      --use builtin_va_arg too, just to consume the function call
      token, inner_token_list = builtin_va_arg(token,nil); table.insert(token_list,inner_token_list)       
   elseif(token.v == "__builtin_offsetof") then
      token, inner_token_list = builtin_offsetof(token,nil); table.insert(token_list,inner_token_list)       
   elseif( (false == is_specifier_qualifier(token)) and (token.t == Tokens.TOK_WORD)) then
      identifier = token
      token = at(token_list,token)   
   end
   return token, token_list, identifier
end
 
postfix_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}  
   local token = tok

   if(token.t == Tokens.TOK_OPENPAREN) then
      local temp_token_list = {}
      local temp_token = at(temp_token_list,token)

      if(is_specifier_qualifier(temp_token)) then   
         --consume the "("
         token = at(token_list,token,Tokens.TOK_OPENPAREN)
         token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)
         token = at(token_list,token)
         if(token.t == Tokens.TOK_OPENBRACE) then
            token = at(token_list,token)
            token, inner_token_list = initializer_list(token); table.insert(token_list,inner_token_list)
            
            while(token.t == Tokens.TOK_COMMA) do
               token = at(token_list,token)
               token, inner_token_list = initializer_list(token); table.insert(token_list,inner_token_list)
            end
            token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
         end
      else
         token, inner_token_list = primary_expression(token); table.insert(token_list,inner_token_list)
      end
   else
      token, inner_token_list = primary_expression(token); table.insert(token_list,inner_token_list)    
   end

   while(true) do
      if(token.t == Tokens.TOK_OPENBRACKET) then 
         token = at(token_list,token)   
         token, inner_token_list = expression(token); 
         local array_index_wrapper = {}
         table.insert(array_index_wrapper,inner_token_list)
         array_index_wrapper.expression_type = ARRAY_INDEX
         table.insert(token_list,array_index_wrapper)
         token = at(token_list,token)   
      elseif(token.t == Tokens.TOK_OPENPAREN) then  
         token = at(token_list,token)  
         if(token.t ~= Tokens.TOK_CLOSEPAREN) then
             token, inner_token_list = argument_expression_list(token); 
             local function_parameters_wrapper = {}
             table.insert(function_parameters_wrapper,inner_token_list)
             function_parameters_wrapper.expression_type = FUNCTION_PARAMETERS
             table.insert(token_list,function_parameters_wrapper)       
         end

         token = at(token_list,token)      
      elseif(token.t == Tokens.TOK_PERIOD) then  
         token = at(token_list,token)    
         --consume identifier 
         token = at(token_list,token)    
      elseif(token.t == Tokens.TOK_INDIRECTION_ARROW) then  
         token = at(token_list,token)    
         --consume identifier 
         token = at(token_list,token)          
      elseif(token.t == Tokens.TOK_PLUSPLUS) then  
         token = at(token_list,token)     
      elseif(token.t == Tokens.TOK_MINUSMINUS) then 
         token = at(token_list,token)   
      elseif(token.t == Tokens.TOK_OPENBRACE) then 
         token = at(token_list,token)
         token, inner_token_list = initializer_list(token); table.insert(token_list,inner_token_list)         
         token = at(token_list,token,Tokens.TOK_CLOSEBRACE)
      else
         break
      end 
   end

  return token, token_list
end
 
type_name = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   token, inner_token_list = specifier_qualifier_list(token); table.insert(token_list,inner_token_list)
   if(token.t ~= Tokens.TOK_CLOSEPAREN) then
      token, inner_token_list = declarator(token, true,false); table.insert(token_list,inner_token_list)   
   end
   return token, token_list
end
 
is_specifier_qualifier = function(tok)
   local token = tok
   if(is_single_token_specifier_qualifier(token) or
     (is_basic_type(token)) or
     (nil ~= multiple_token_extension_keywords[token.v]) or 
     (nil ~= multiple_token_specifier_qualifiers[token.v]) or
     (is_new_type(token))) then
      return true
   end
   return false
end
 
cast_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local temp_token_list = {}
   local token = tok

   if(token.t == Tokens.TOK_OPENPAREN) then 
       --consume the (
      local temp_token = at(temp_token_list,token)
      if(is_specifier_qualifier(temp_token)) then

         token = at(token_list,token)
         token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)        
         --consume the )

         token = at(token_list,token,Tokens.TOK_CLOSEPAREN)

         token, inner_token_list = cast_expression(token); table.insert(token_list,inner_token_list) 
      else        
          token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list) 
      end
   else
      token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list) 
   end

   return token, token_list
end

local unary_operators = {}
unary_operators[Tokens.TOK_AMPERSAND] = true
unary_operators[Tokens.TOK_AND] = true
unary_operators[Tokens.TOK_STAR] = true
unary_operators[Tokens.TOK_PLUS] = true
unary_operators[Tokens.TOK_MINUS] = true
unary_operators[Tokens.TOK_TILDE] = true
unary_operators[Tokens.TOK_EXCLAMATIONMARK] = true

unary_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   if(token.t == Tokens.TOK_EXCLAMATIONMARK) then
      token = at(token_list,token)  
      token, inner_token_list = cast_expression(token); 
      --This works like this:  If we see a "!", and it is at the start of !(a && b), then we need
      --to call the whole thing a boolean expression.  So !(boolean expression) becomes (!boolean expression).
      --and !!(boolean expression) !(!boolean expression) which becomes (!!boolean expression).
      if(has_child_boolean_expression(inner_token_list)) then    
         token_list.line_number = token.line_number
         token_list.function_name = token.function_name         
         --2",token_list.expression_type)
         token_list.expression_type = BOOLEAN_EXPRESSION
         token_list.coverage_enabled = CoverageEnabled
         token_list.decision_coverage = DecisionCoverage
         token_list.mcdc_coverage = MCDCCoverage         
         local prefix_expression = get_prefix_expression({inner_token_list})
         token_list.prefix_expression = "!" .. prefix_expression
         remove_inner_boolean_expressions(inner_token_list)
         find_exclamation_mark_operators(token_list)
      end
      
      table.insert(token_list,inner_token_list)
   elseif(nil ~= unary_operators[token.t]) then
      token = at(token_list,token)  
      token, inner_token_list = cast_expression(token); table.insert(token_list,inner_token_list)
   elseif(token.v == "sizeof") then 
      token = at(token_list,token)
      if(token.t ~= Tokens.TOK_OPENPAREN) then
         token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
      else
         token = at(token_list,token,Tokens.TOK_OPENPAREN)

         --It can be sizeof(T) or sizeof(expression)
         if(is_specifier_qualifier(token)) then
            token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)
         else
            token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
         end            
         token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
         --Special handling for 
         if(token.t == Tokens.TOK_OPENBRACE) then
            token, inner_token_list = initializer(token); table.insert(token_list,inner_token_list)
         end             
      end
   elseif((token.v == "__alignof__") or (token.v == "__alignof")) then 
      token = at(token_list,token)
      if(token.t ~= Tokens.TOK_OPENPAREN) then
         token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
      else
         token = at(token_list,token,Tokens.TOK_OPENPAREN)

         --It can be __alignof__(T) or __alignof__(expression)
         if(is_specifier_qualifier(token)) then
            token, inner_token_list = type_name(token); table.insert(token_list,inner_token_list)
         else
            token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
         end            
         token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
      end      
   elseif(token.v == "__imag__" or 
          token.v == "__imag" or         
          token.v == "__real__" or       
          token.v == "__real") then
      token = at(token_list,token)        
      token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list)                 
   elseif((token.t == Tokens.TOK_PLUSPLUS) or (token.t == Tokens.TOK_MINUSMINUS)) then
      token = at(token_list,token)  
      token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list)
   else
      token, inner_token_list = postfix_expression(token); table.insert(token_list,inner_token_list) 
   end

   return token, token_list
end
 
relational_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local found = false
   local starting_line_number = token.line_number

   token, inner_token_list = shift_expression(token);table.insert(token_list,inner_token_list)
   if(token.t == Tokens.TOK_RELATIONAL) then
      found = true
      token = at(token_list,token)
      token, inner_token_list = relational_expression(token);table.insert(token_list,inner_token_list)
   end

   if(found) then
      token_list.line_number = starting_line_number
      token_list.function_name = token.function_name      
      token_list.prefix_expression = "c"      
      token_list.expression_type = RELATIONAL_EXPRESSION
      token_list.coverage_enabled = CoverageEnabled
      token_list.decision_coverage = DecisionCoverage
      token_list.mcdc_coverage = MCDCCoverage     
      find_exclamation_mark_operators(token_list)   
   end
    
   return token, token_list
end
     
local math_operator_list = {}
math_operator_list[Tokens.TOK_STAR] = 1
math_operator_list[Tokens.TOK_PLUS] = 1
math_operator_list[Tokens.TOK_MINUS] = 1
math_operator_list[Tokens.TOK_FORWARDSLASH] = 1
math_operator_list[Tokens.TOK_MOD] = 1

math_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local found = false

   token, inner_token_list = cast_expression(token);table.insert(token_list,inner_token_list)
   if(nil ~= math_operator_list[token.t]) then
      token = at(token_list,token)
      token, inner_token_list = math_expression(token);table.insert(token_list,inner_token_list)
   end

   if(found) then
      token_list.expression_type = NON_LOGICAL_EXPRESSION      
   end
    
   return token, token_list
end
    
local bitwise_operator_list = {}
math_operator_list[Tokens.TOK_BITWISEOR] = 1
math_operator_list[Tokens.TOK_AMPERSAND] = 1
math_operator_list[Tokens.TOK_EXCLUSIVEOR] = 1

bitwise_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local found = false

   token, inner_token_list = relational_expression(token);table.insert(token_list,inner_token_list)
   if(nil ~= bitwise_operator_list[token.t]) then
      token = at(token_list,token)
      token, inner_token_list = bitwise_expression(token);table.insert(token_list,inner_token_list)
   end

   if(found) then
      token_list.expression_type = NON_LOGICAL_EXPRESSION      
   end
    
   return token, token_list
end

shift_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local found = false

   token, inner_token_list = math_expression(token);table.insert(token_list,inner_token_list)
   if(Tokens.TOK_SHIFT == token.t) then
      token = at(token_list,token)
      token, inner_token_list = shift_expression(token);table.insert(token_list,inner_token_list)
   end

   if(found) then
      token_list.expression_type = NON_LOGICAL_EXPRESSION      
   end
    
   return token, token_list
end
    

get_prefix_expression = function(expression)
   local list = expression   
   local prefix_expression = ""

   for i=1,#list do
      if(list[i].expression_type == OPERAND) then
         return  "c"      
      elseif(list[i].expression_type == BOOLEAN_EXPRESSION) then 
         return list[i].prefix_expression        
      elseif((list[i].expression_type == NON_LOGICAL_EXPRESSION) or 
            (list[i].expression_type == RELATIONAL_EXPRESSION) or                  
            (list[i].expression_type == CONDITIONAL_EXPRESSION) or                
            (list[i].expression_type == ARRAY_INDEX) or
            (list[i].expression_type == COMPOUND_STATEMENT_WITHIN_EXPRESSION) or             
            (list[i].expression_type == FUNCTION_PARAMETERS)) then  
         return "c"
      elseif(list[i].expression_type == COMMA_EXPRESSION) then 
        --skip comma expressions           
      elseif(nil == list[i].t) then
         return get_prefix_expression(list[i])
      end
   end
end
 
and_expression = function(tok)
   local token_list = {}
   local found = false
   local token = tok
   local inner_token_list1 = nil
   local inner_token_list2 = nil
   local line_number
   local function_name
   local left_side, right_side
   token, inner_token_list1 = bitwise_expression(tok)
 
   if(token.t == Tokens.TOK_AND) then
      line_number = token.line_number
      function_name = token.function_name      
      found = true
      token.t = AND_OPERATOR

      if(has_child_boolean_expression(inner_token_list1) == false) then    
         left_side = {
            expression_type = OPERAND,
            function_name = token.function_name,
            coverage_enabled = CoverageEnabled,
            mcdc_coverage = MCDCCoverage,
            decision_coverage = DecisionCoverage
         }
         table.insert(left_side,inner_token_list1)
      else
         left_side = inner_token_list1
      end
      table.insert(token_list,left_side)
      
      token = at(token_list,token)
      token, inner_token_list2 = and_expression(token)

      if(has_child_boolean_expression(inner_token_list2) == false) then   
         right_side = {
            expression_type = OPERAND,
            function_name = token.function_name,
            coverage_enabled = CoverageEnabled,
            mcdc_coverage = MCDCCoverage,
            decision_coverage = DecisionCoverage
         }
         table.insert(right_side,inner_token_list2)
      else
         right_side = inner_token_list2
      end
      table.insert(token_list,right_side)
   end
 
   if(found) then
     token_list.line_number = line_number
     token_list.function_name = function_name      
     token_list.expression_type = BOOLEAN_EXPRESSION
     token_list.coverage_enabled = CoverageEnabled
     token_list.decision_coverage = DecisionCoverage
     token_list.mcdc_coverage = MCDCCoverage     
     local prefix_expression_1 = get_prefix_expression({left_side})
     local prefix_expression_2 = get_prefix_expression({right_side})
 
     if((prefix_expression_1 == nil) or (prefix_expression_2 == nil)) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
     end
     
     token_list.prefix_expression = "&" .. prefix_expression_1 .. prefix_expression_2
     remove_inner_relational_expressions(token_list)     
     remove_inner_boolean_expressions(token_list)
     find_exclamation_mark_operators(token_list)
   else
      table.insert(token_list,inner_token_list1)
   end   
   
   return token, token_list  
end
  
 
 
or_expression = function(tok)
   local token_list = {}
   local found = false
   local token = tok
   local inner_token_list1 = nil
   local inner_token_list2 = nil
   local line_number
   local function_name
   local left_side, right_side

   token, inner_token_list1 = and_expression(tok)

   if(token.t == Tokens.TOK_OR) then
      line_number = token.line_number
      function_name = token.function_name   
      found = true
      token.t = OR_OPERATOR
      if(has_child_boolean_expression(inner_token_list1) == false) then    
         left_side = {
            expression_type = OPERAND,
            function_name = token.function_name,
            coverage_enabled = CoverageEnabled,
            mcdc_coverage = MCDCCoverage,
            decision_coverage = DecisionCoverage
         }
         table.insert(left_side,inner_token_list1)
      else
         left_side = inner_token_list1
      end
      table.insert(token_list,left_side)

      token = at(token_list,token)
      token, inner_token_list2 = or_expression(token);
     
      if(has_child_boolean_expression(inner_token_list2) == false) then     
         right_side = {
            expression_type = OPERAND,
            function_name = token.function_name,
            coverage_enabled = CoverageEnabled,
            mcdc_coverage = MCDCCoverage,
            decision_coverage = DecisionCoverage
         }
         table.insert(right_side,inner_token_list2)
      else
         right_side = inner_token_list2
      end
      table.insert(token_list,right_side)
   end

   if(found) then
      token_list.line_number = line_number
      token_list.function_name = function_name 
      token_list.expression_type = BOOLEAN_EXPRESSION
      token_list.coverage_enabled = CoverageEnabled
      token_list.decision_coverage = DecisionCoverage
      token_list.mcdc_coverage = MCDCCoverage      
      local prefix_expression_1 = get_prefix_expression({left_side})
      local prefix_expression_2 = get_prefix_expression({right_side})

      if((prefix_expression_1 == nil) or (prefix_expression_2 == nil)) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
      end

      token_list.prefix_expression = "|" .. prefix_expression_1 .. prefix_expression_2
      remove_inner_relational_expressions(token_list)      
      remove_inner_boolean_expressions(token_list)
      find_exclamation_mark_operators(token_list)
   else
      table.insert(token_list,inner_token_list1)
   end   

   return token, token_list  
end
   
conditional_expression = function(tok)
   local token_list = {}
   local token = tok
   local found = false
   local token, inner_token_list = or_expression(token)

   if(token.t == Tokens.TOK_QUESTIONMARK) then
      found = true
      remove_inner_relational_expressions(inner_token_list)
      if(has_child_boolean_expression(inner_token_list) == false) then
         inner_token_list.line_number = token.line_number
         inner_token_list.function_name = token.function_name         
         inner_token_list.prefix_expression = "c"
         inner_token_list.expression_type = BOOLEAN_EXPRESSION
         inner_token_list.coverage_enabled = CoverageEnabled
         inner_token_list.decision_coverage = DecisionCoverage
         inner_token_list.mcdc_coverage = MCDCCoverage         
      end
      table.insert(token_list,inner_token_list)   

      --consume the '?'
      token = at(token_list,token,Tokens.TOK_QUESTIONMARK)

      --handle gnu extension (a ?: b)
      if(token.t == Tokens.TOK_COLON) then
         --consume the ":"
         token = at(token_list,token)
         token, inner_token_list = conditional_expression(token); table.insert(token_list,inner_token_list)
      else
         token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)

         --consume the ":"
         token = at(token_list,token,Tokens.TOK_COLON)
         token, inner_token_list = conditional_expression(token); table.insert(token_list,inner_token_list)
      end
   else
      table.insert(token_list,inner_token_list)
   end    

   if(found) then
      token_list.expression_type = CONDITIONAL_EXPRESSION
      find_exclamation_mark_operators(token_list)
   end
   return token, token_list
end

assignment_expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local found = false

   token, inner_token_list = conditional_expression(token); table.insert(token_list,inner_token_list) 

   while(token.t == Tokens.TOK_ASSIGNMENT) do
      found = true
      token = at(token_list,token)
      token, inner_token_list = assignment_expression(token); table.insert(token_list,inner_token_list)
   end

   if(found) then
      token_list.expression_type = NON_LOGICAL_EXPRESSION
   end   

   return token, token_list
end
 
 --called from a bunch of things
expression = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   token, inner_token_list = assignment_expression(token)

   if(token.t == Tokens.TOK_COMMA) then
      while(token.t == Tokens.TOK_COMMA) do
         local comma_expression = {expression_type = COMMA_EXPRESSION}
         table.insert(comma_expression,inner_token_list)
         table.insert(token_list,comma_expression)

         token = at(token_list,token)       
         token, inner_token_list = assignment_expression(token)        
      end
      table.insert(token_list,inner_token_list) 
   else
      table.insert(token_list,inner_token_list)  
   end

   return token, token_list
end
 
expression_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   if(token.t == Tokens.TOK_SEMICOLON) then
      token = at(token_list,token)
   else   
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)
   end
   return token, token_list
end
 
if_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local insert_brackets = false
   local starting_line_number = 0

   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   
   --consume the "if" 
   token = at(token_list,token)
   starting_line_number = token.line_number

   --consume the "("
   token = at(token_list,token,Tokens.TOK_OPENPAREN)

   token, inner_token_list = expression(token);
   remove_inner_relational_expressions(inner_token_list)
   if(has_child_boolean_expression(inner_token_list) == false) then
      inner_token_list.line_number = starting_line_number
      inner_token_list.function_name = token.function_name        
      inner_token_list.prefix_expression = "c"
      inner_token_list.expression_type = BOOLEAN_EXPRESSION
      inner_token_list.coverage_enabled = CoverageEnabled
      inner_token_list.decision_coverage = DecisionCoverage
      inner_token_list.mcdc_coverage = MCDCCoverage      
      find_exclamation_mark_operators(inner_token_list)
   end
   table.insert(token_list,inner_token_list)   
   
   --consume the ")"      

   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
   
   if((token.t ~= Tokens.TOK_OPENBRACE) and CoverageEnabled) then
      insert_brackets = true
      table.insert(token_list,{t = INSERT_OPEN_BRACKET})
   end
   
   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)
   
   if(true == insert_brackets) then
      table.insert(token_list,{t = INSERT_CLOSE_BRACKET})
   end    
    
   if(token.v == "else") then
      token, inner_token_list = else_statement(token); table.insert(token_list,inner_token_list)
   end
   
   return token, token_list   
end
 
else_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok 
   local insert_brackets = false

   --consume the else
   token = at(token_list,token)
     
      if((token.t ~= Tokens.TOK_OPENBRACE) and CoverageEnabled) then
         insert_brackets = true
         table.insert(token_list,{t = INSERT_OPEN_BRACKET})
      end
   
   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)

   if(true == insert_brackets) then
      table.insert(token_list,{t = INSERT_CLOSE_BRACKET})
   end  

   return token, token_list
end
 
for_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local insert_brackets = false
   local ident_stack_top = #IdentStack
   local starting_line_number = 0

   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   
   --consume the "for"
   token = at(token_list,token)
   starting_line_number = token.line_number
   
   --consume the "("
    token = at(token_list,token,Tokens.TOK_OPENPAREN)
   if(is_specifier_qualifier(token)) then
      token, inner_token_list = local_declaration(token); table.insert(token_list,inner_token_list)
   else   
      token, inner_token_list = expression_statement(token); table.insert(token_list,inner_token_list)
   end
   
   --token = expression_statement(token)
   if(token.t == Tokens.TOK_SEMICOLON) then
      token = at(token_list,token)
   else
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)

      remove_inner_relational_expressions(inner_token_list)
      if(has_child_boolean_expression(inner_token_list) == false) then
         inner_token_list.line_number = starting_line_number
         inner_token_list.function_name = token.function_name        
         inner_token_list.prefix_expression = "c"
         inner_token_list.expression_type = BOOLEAN_EXPRESSION
         inner_token_list.coverage_enabled = CoverageEnabled
         inner_token_list.decision_coverage = DecisionCoverage
         inner_token_list.mcdc_coverage = MCDCCoverage      
         find_exclamation_mark_operators(inner_token_list)
      end

      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)
   end
   --if the next token isn't a ), then it must be the optional expression
   if(token.t ~= Tokens.TOK_CLOSEPAREN) then
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)     
   end    

   --consume the ")"
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)

   if((token.t ~= Tokens.TOK_OPENBRACE) and CoverageEnabled) then
      insert_brackets = true
      table.insert(token_list,{t = INSERT_OPEN_BRACKET})
      --insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   end

   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list) 

   --cleanup the identifier stack
   while(#IdentStack > ident_stack_top) do
      removed_name = table.remove(IdentStack)
      remove_ident(removed_name)
   end

   if(true == insert_brackets) then
      table.insert(token_list,{t = INSERT_CLOSE_BRACKET})
   end   

   return token, token_list
end
 
while_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok    
   local insert_brackets = false
   local starting_line_number = 0
   
   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   
   --consume the "while" 
   token = at(token_list,token)
   starting_line_number = token.line_number
   
   --consume the "("
   token = at(token_list,token,Tokens.TOK_OPENPAREN)
     
   token, inner_token_list = expression(token);
   remove_inner_relational_expressions(inner_token_list)
   if(has_child_boolean_expression(inner_token_list) == false) then
      inner_token_list.line_number = starting_line_number
      inner_token_list.function_name = token.function_name        
      inner_token_list.prefix_expression = "c"
      inner_token_list.expression_type = BOOLEAN_EXPRESSION
      inner_token_list.coverage_enabled = CoverageEnabled
      inner_token_list.decision_coverage = DecisionCoverage
      inner_token_list.mcdc_coverage = MCDCCoverage      
      find_exclamation_mark_operators(inner_token_list)
   end
   table.insert(token_list,inner_token_list)   
   
   --consume the ")"      
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
    
   if((token.t ~= Tokens.TOK_OPENBRACE) and CoverageEnabled) then
      insert_brackets = true
      table.insert(token_list,{t = INSERT_OPEN_BRACKET})
   end

   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)
  
   if(true == insert_brackets) then
      table.insert(token_list,{t = INSERT_CLOSE_BRACKET})
   end   

   if(true == inserting_open_bracket) then
      inserting_open_bracket = false
   end   

   return token, token_list
end
 
do_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok 
   local insert_brackets = false
   local starting_line_number = 0

   --consume the "do"
   
   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   token = at(token_list,token)

   if((token.t ~= Tokens.TOK_OPENBRACE) and CoverageEnabled) then
      insert_brackets = true
      table.insert(token_list,{t = INSERT_OPEN_BRACKET})
   end      
   
   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)

   if(true == insert_brackets) then
      table.insert(token_list,{t = INSERT_CLOSE_BRACKET})
   end    

   --consume the "while" 
   token = at(token_list,token)
   starting_line_number = token.line_number
   
   --consume the "("
   token = at(token_list,token,Tokens.TOK_OPENPAREN)
     
   token, inner_token_list = expression(token);
   
   remove_inner_relational_expressions(inner_token_list)
   if(has_child_boolean_expression(inner_token_list) == false) then
      inner_token_list.line_number = starting_line_number
      inner_token_list.function_name = token.function_name        
      inner_token_list.prefix_expression = "c"
      inner_token_list.expression_type = BOOLEAN_EXPRESSION
      inner_token_list.coverage_enabled = CoverageEnabled
      inner_token_list.decision_coverage = DecisionCoverage
      inner_token_list.mcdc_coverage = MCDCCoverage      
      find_exclamation_mark_operators(inner_token_list)
   end
   table.insert(token_list,inner_token_list)   
   
   --consume the ")"      
   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)
 
   --consume the ";"
    token = at(token_list,token,Tokens.TOK_SEMICOLON)
   return token, token_list
end
 
switch_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   insert_statement_coverage_command(token_list, token.line_number, token.function_name)

   --consume the "switch"
   token = at(token_list,token)

   --consume the "("
   token = at(token_list,token,Tokens.TOK_OPENPAREN)

   token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)

   --consume the ")"

   token = at(token_list,token,Tokens.TOK_CLOSEPAREN)

   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)

   return token, token_list
end
 
case_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   --consume the "case"
   token = at(token_list,token)

   token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
       
   if(token.t == Tokens.TOK_ELLIPSES) then
      token = at(token_list,token)
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
   end

   --consume the ":"
   token = at(token_list,token,Tokens.TOK_COLON)

   token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)
   return token, token_list
end
 
return_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   --consume the "return"
   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   token = at(token_list,token)

   if(token.t ~= Tokens.TOK_SEMICOLON) then
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)
   end

   --consume the ";"
   token = at(token_list,token,Tokens.TOK_SEMICOLON)  

   return token, token_list
end
 
is_label_statement = function(tok)
   local token = tok
   local temp_token_list = {}
   local look_ahead = at(temp_token_list,token)

   if(token.v == "__label__") then return true
   elseif((token.t == Tokens.TOK_WORD) and (look_ahead.t == Tokens.TOK_COLON)) then return true
   else return false
   end
end
 
label_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   if(token.v == "__label__") then 
      token = at(token_list,token)
    
      --consume the label name
      token = at(token_list,token)
       
      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)
   else
      --it's a MYLABEL: type label
      --consume the label name
      token = at(token_list,token)
      --consume the ":"
      token = at(token_list,token,Tokens.TOK_COLON)
      --consume the statement.  Also, allow for a label at the end of a compound without any statement, such as
         --L1:}
      if(token.t ~= Tokens.TOK_CLOSEBRACE) then
         token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)             
      end
   end

   return token, token_list
end
 
goto_statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   --consume the "goto"
   insert_statement_coverage_command(token_list, token.line_number, token.function_name)
   token = at(token_list,token)

   --consume the identifier
   token, inner_token_list = unary_expression(token); table.insert(token_list,inner_token_list)

   --consume the ";"
   token = at(token_list,token,Tokens.TOK_SEMICOLON)

   return token, token_list
end
 
statement = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   if(last_buffer_loc >= tok.buffer_loc) then
      last_buffer_loc_loop_detection_count = last_buffer_loc_loop_detection_count + 1
      if(last_buffer_loc_loop_detection_count > 10) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Error during parsing.")
      end
   else
      last_buffer_loc = tok.buffer_loc
      last_buffer_loc_loop_detection_count = 0
   end

   if(token.v == "for") then 
      token, inner_token_list = for_statement(token); table.insert(token_list,inner_token_list)
   elseif(token.v == "goto") then 
      token, inner_token_list = goto_statement(token); table.insert(token_list,inner_token_list)   
   elseif(token.v == "continue") then 
      --consume the "continue"
      insert_statement_coverage_command(token_list, token.line_number, token.function_name)
      token = at(token_list,token)
      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)
   elseif(token.v == "break") then 
      --consume the "break"
      insert_statement_coverage_command(token_list, token.line_number, token.function_name)
      token = at(token_list,token)
      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)  
   elseif(token.v == "return") then 
      token, inner_token_list = return_statement(token); table.insert(token_list,inner_token_list)    
   elseif(token.v == "asm") or word_matches(token,"__asm") or word_matches(token,"__asm__") then

       token, inner_token_list = asm(token); table.insert(token_list,inner_token_list)   
      --consume the ";"
      token = at(token_list,token,Tokens.TOK_SEMICOLON)  

   --A statement that uses __attribute__
   elseif((token.v == "__attribute__") or (token.v == "__attribute")) then 
      token, inner_token_list = attribute(token); table.insert(token_list, inner_token_list)    
   elseif(token.v == "case") then 
      token, inner_token_list = case_statement(token); table.insert(token_list,inner_token_list)
   elseif(token.v == "default") then 
      --consume the "default"
      token = at(token_list,token)
      --consume the ":"
      token = at(token_list,token,Tokens.TOK_COLON)
      token, inner_token_list = statement(token); table.insert(token_list,inner_token_list)   
   elseif(token.t == Tokens.TOK_OPENBRACE) then
      token, inner_token_list = compound_statement(token,nil,nil,false); table.insert(token_list,inner_token_list)
   elseif(token.t == Tokens.TOK_SEMICOLON) then
      token = at(token_list,token)  
   elseif(token.v == "if") then 
      token, inner_token_list = if_statement(token); table.insert(token_list,inner_token_list)   
   elseif(token.v == "switch") then 
      token, inner_token_list = switch_statement(token); table.insert(token_list,inner_token_list)
   elseif(token.v == "while") then 
      token, inner_token_list = while_statement(token); table.insert(token_list,inner_token_list)
   elseif(token.v == "do") then 
      token, inner_token_list = do_statement(token); table.insert(token_list,inner_token_list)
   elseif(is_label_statement(token)) then
      token, inner_token_list = label_statement(token); table.insert(token_list,inner_token_list)  
   elseif(token.v == "_Pragma") or word_matches(token,"__pragma") then     
      token, inner_token_list = pragma_operator(token);table.insert(token_list, inner_token_list)        
   elseif(token.v == "__try") then    
      token = at(token_list,token)      
   elseif(token.v == "__finally") then    
      token = at(token_list,token)        
   elseif(token.v == "__except") then    
      token = at(token_list,token)      
      token = at(token_list,token, Tokens.TOK_OPENPAREN)   
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)          
      token = at(token_list,token, Tokens.TOK_CLOSEPAREN)   
   else 
      insert_statement_coverage_command(token_list, token.line_number, token.function_name)
      token, inner_token_list = expression(token); table.insert(token_list,inner_token_list)   
      --consume the ;
      token = at(token_list,token,Tokens.TOK_SEMICOLON)
   end
   return token, token_list
end

local basic_types = {}
basic_types["__complex__"] = true
basic_types["__complex"] = true  
basic_types["_Complex"] = true
basic_types["complex"] = true    
basic_types["__int16"] = true    
basic_types["__int32"] = true    
basic_types["__int64"] = true 
basic_types["__int128"] = true 
basic_types["__int8"] = true 
basic_types["__signed__"] = true     
basic_types["__signed"] = true     
basic_types["signed"] = true  
basic_types["unsigned"] = true    
basic_types["_atomic"] = true
basic_types["_Atomic"] = true
basic_types["_Bool"] = true
basic_types["bool"] = true   
basic_types["_Float16"] = true
basic_types["_Float32"] = true
basic_types["_Float32x"] = true
basic_types["_Float64"] = true
basic_types["_Float64x"] = true
basic_types["_Float128"] = true
basic_types["auto"] = true
basic_types["char"] = true
basic_types["double"] = true
basic_types["float" ] = true
basic_types["int"] = true
basic_types["long"] = true
basic_types["short" ] = true  
basic_types["void"] = true

is_basic_type = function(token)
   if((token ~= nil) and (basic_types[token.v] ~= nil)) then
      return true
   end
   return false

end
 
local single_token_specifier_qualifiers = {}
single_token_specifier_qualifiers["__complex__"] = true
single_token_specifier_qualifiers["__complex"] = true
single_token_specifier_qualifiers["_Complex"] = true
single_token_specifier_qualifiers["complex"] = true    
single_token_specifier_qualifiers["__int16"] = true    
single_token_specifier_qualifiers["__int32"] = true    
single_token_specifier_qualifiers["__int64"] = true 
single_token_specifier_qualifiers["__int128"] = true 
single_token_specifier_qualifiers["__int8"] = true 
single_token_specifier_qualifiers["__signed__"] = true
single_token_specifier_qualifiers["__signed"] = true   
single_token_specifier_qualifiers["signed"] = true   
single_token_specifier_qualifiers["unsigned"] = true
single_token_specifier_qualifiers["_atomic"] = true
single_token_specifier_qualifiers["_Atomic"] = true   
single_token_specifier_qualifiers["_Bool" ] = true
single_token_specifier_qualifiers["bool"] = true   
single_token_specifier_qualifiers["_Float16" ] = true
single_token_specifier_qualifiers["_Float32" ] = true
single_token_specifier_qualifiers["_Float32x" ] = true
single_token_specifier_qualifiers["_Float64" ] = true
single_token_specifier_qualifiers["_Float64x" ] = true
single_token_specifier_qualifiers["_Float128" ] = true
single_token_specifier_qualifiers["auto"] = true
single_token_specifier_qualifiers["char"] = true
single_token_specifier_qualifiers["double"] = true
single_token_specifier_qualifiers["float" ] = true
single_token_specifier_qualifiers["int"] = true
single_token_specifier_qualifiers["long"] = true
single_token_specifier_qualifiers["short" ] = true
single_token_specifier_qualifiers["void"] = true
single_token_specifier_qualifiers["static"] = true
single_token_specifier_qualifiers["volatile"] = true
single_token_specifier_qualifiers["__builtin_va_list"] = true   
single_token_specifier_qualifiers["__unaligned"] = true
single_token_specifier_qualifiers["__const"] = true
single_token_specifier_qualifiers["__inline__"] = true   
single_token_specifier_qualifiers["__inline"] = true
single_token_specifier_qualifiers["__inline"] = true
single_token_specifier_qualifiers["__instrinsic"] = true
single_token_specifier_qualifiers["__restrict__"] = true
single_token_specifier_qualifiers["__restrict"] = true
single_token_specifier_qualifiers["__restrict"] = true
single_token_specifier_qualifiers["const" ] = true
single_token_specifier_qualifiers["extern"] = true
single_token_specifier_qualifiers["inline"] = true   
single_token_specifier_qualifiers["register"] = true
single_token_specifier_qualifiers["restrict"] = true   

is_single_token_specifier_qualifier = function(token)
   if((token ~= nil) and (single_token_specifier_qualifiers[token.v] ~= nil)) then
      return true
   end
   return false
end
 
 multiple_token_specifier_qualifiers = {}
 multiple_token_specifier_qualifiers["struct"] = struct
 multiple_token_specifier_qualifiers["union"] = union
 multiple_token_specifier_qualifiers["enum"] = enum
 multiple_token_specifier_qualifiers["typeof"] = typeof
 multiple_token_specifier_qualifiers["__typeof__"] = typeof
 multiple_token_specifier_qualifiers["asm"] = asm
 multiple_token_specifier_qualifiers["__asm"] = asm
 multiple_token_specifier_qualifiers["__asm__"] = asm
 
 multiple_token_extension_keywords = {}
 multiple_token_extension_keywords["__attribute__"] = attribute
 multiple_token_extension_keywords["__attribute"] = attribute
 multiple_token_extension_keywords["__declspec"] = declspec

local_declaration = function(tok)
   local token_list = {}
   local inner_token_list = {}  
   local token = tok
   local ident_name
   local typedef_found = false
   local type_found = false
   
   while(true) do
      if(token.v == "typedef") then 
         typedef_found = true
         token = at(token_list,token)
      elseif(is_basic_type(token)) then     
         type_found = true
         token = at(token_list,token);  
         while(is_basic_type(token)) do
            token = at(token_list,token);  
         end
      elseif(is_single_token_specifier_qualifier(token)) then
         token = at(token_list,token);
      elseif(nil ~= multiple_token_extension_keywords[token.v]) then
         token, inner_token_list = multiple_token_extension_keywords[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(nil ~= multiple_token_specifier_qualifiers[token.v]) then
         type_found = true
         token, inner_token_list = multiple_token_specifier_qualifiers[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(token.t == Tokens.TOK_WORD) then
         if(type_found) then
            break
         elseif(is_new_type(token)) then
            type_found = true
            token = at(token_list,token);
         else
            break
         end
      else
         break
      end
   end
   
   local found_ident = false;
   
   while(true) do
      if(token.t == Tokens.TOK_COMMA) then 
         token = at(token_list,token)
      elseif(token.t == Tokens.TOK_ASSIGNMENT) then
         token = at(token_list,token)
         token, inner_token_list = initializer(token); table.insert(token_list, inner_token_list)
      elseif(token.t == Tokens.TOK_SEMICOLON) then 
         token = at(token_list,token)
         break
      elseif((token.t == Tokens.TOK_OPENBRACE) and (found_ident)) then  
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.  Local functions are not allowed")
      else
         token, inner_token_list, ident_name = declarator(token,false,false); table.insert(token_list, inner_token_list) 
         if(typedef_found) then
            add_ident(ident_name,NEW_TYPE)
         else
            add_ident(ident_name,nil)
         end
         found_ident = true
     end
   end
   return token, token_list
 end
 
skip_args = function(tok)
   local token_list = {}
   local token = tok
   local open_p_count = 1
   token = at(token_list,token)
   
   while(0 < open_p_count) do
      if(token.t == Tokens.TOK_OPENPAREN) then
         open_p_count = open_p_count + 1
      elseif(token.t == Tokens.TOK_CLOSEPAREN) then
         open_p_count = open_p_count - 1
      end
      token = at(token_list,token)
   end
   
   return token, token_list
 end

pragma_operator = function(tok)
   local token_list = {}
   local token = tok
   local inner_token_list

   --consume the pragma
   token = at(token_list,token)

   --assume a string or an expression
   token, inner_token_list = skip_args(token); table.insert(token_list,inner_token_list)
   
   return token, token_list
end
 
asm = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok

   token = at(token_list,token)
   
   --skip everything up until the (
   
   while(token.t ~= Tokens.TOK_OPENPAREN) do
     token = at(token_list,token)
   end
   token, inner_token_list = skip_args(token); table.insert(token_list,inner_token_list)
   return token, token_list
 end

get_expression_nesting_depth = function(token_list, current_depth, result)
   local list = token_list   
   
   for i=1,#list do
      if((list[i].expression_type == BOOLEAN_EXPRESSION) or
        (list[i].expression_type == RELATIONAL_EXPRESSION)) then  
         if(current_depth+1 > result.depth) then
            result.depth = current_depth + 1
         end  
         get_expression_nesting_depth(list[i], current_depth+1, result)     
      elseif(list[i].t == nil) then
         get_expression_nesting_depth(list[i], current_depth, result)  
      end
   end
   
   return false
 end
 
compound_statement = function(tok, parameter_list, is_function, function_name)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local token_list_location_of_declarations = 0
   local ident_stack_top = #IdentStack

  --consume the "{"
   token,index = at(token_list,tok,Tokens.TOK_OPENBRACE)
   if(is_function and CoverageEnabled and MCDCCoverage) then
      table.insert(token_list, {t = FIRST_LINE_OF_FUNCTION})
      token_list_location_of_declarations = #token_list
   end
   add_idents(parameter_list,false) 
   while(token.t ~= Tokens.TOK_CLOSEBRACE) do
      if(is_specifier_qualifier(token) or token.v == "typedef") then
         token, inner_token_list = local_declaration(token,false)
      else
         if(token.t ~= Tokens.TOK_CLOSEBRACE) then
            token,inner_token_list = statement(token)
         end
      end
      if(#inner_token_list > 0) then
         table.insert(token_list,inner_token_list)
      end
   end
 
   --cleanup the identifier stack
   while(#IdentStack > ident_stack_top) do
      removed_name = table.remove(IdentStack)
      remove_ident(removed_name)
   end

   --consume the "}"
   token = at(token_list,token,Tokens.TOK_CLOSEBRACE)

   if(is_function) then
      local result = {depth=0}
      get_expression_nesting_depth(token_list,0,result)
      token_list[token_list_location_of_declarations] = {t = FIRST_LINE_OF_FUNCTION, max_nested_expressions = result.depth, function_name = function_name}

      --Since we are done with the function, set the token name to nil
      token.function_name = nil
   end
   
   return token, token_list
end
 
local type_qualifiers = {}
type_qualifiers["const"] = true
type_qualifiers["__const"] = true
type_qualifiers["restrict"] = true
type_qualifiers["volatile"] = true
type_qualifiers["_atomic"] = true
type_qualifiers["_Atomic"] = true

is_type_qualifier = function(token)

   if((token ~= nil) and (nil ~= type_qualifiers[token.v])) then
      return true
   else 
      return false
   end
end
 
pointer = function(tok)
   local token_list = {}
   local inner_token_list = {}   
   
   --Consume the "*"
   local token = at(token_list,tok,Tokens.TOK_STAR)
   
   if(token.v == "__restrict") or word_matches(token,"__restrict__") then
      token = at(token_list,token)
   
   elseif(token.v == "__ptr32") or word_matches(token,"__ptr64") then
      token = at(token_list,token)
   end
   
   --type-qualifer-list
   while(true) do
      if(is_type_qualifier(token)) then
         token = at(token_list,token)
      else
         break
      end
   end
   
   if(token.t == Tokens.TOK_STAR) then
      token, inner_token_list = pointer(token); table.insert(token_list, inner_token_list)
   end
   
   return token, token_list
 end
 
initializer_list = function(tok)
   local token_list = {}
   local inner_token_list = {}  
   local token = tok
   local temp_token_list = {}
   local temp_token = at(temp_token_list,token)
   
   if(token.t == Tokens.TOK_OPENBRACKET) then
      token = at(token_list,token)  
      --consume the constant expression
      token, inner_token_list = expression(token); table.insert(token_list, inner_token_list)
      token = at(token_list,token)
   
   --the is a union or struct name using format .myFieldName
   elseif(token.t == Tokens.TOK_PERIOD) then
      token = at(token_list,token)    
   
      --consume the identifier
      token = at(token_list,token)    
   
   --the is a union or struct name using format myFieldName:
   elseif((token.t == Tokens.TOK_WORD) and (temp_token.t == Tokens.TOK_COLON)) then
      if(temp_token.t == Tokens.TOK_COLON) then
         --this is a struct or union field
   
         --consume the field name 
         token = at(token_list,token)    
   
         --consume the ":"
         token = at(token_list,token,Tokens.TOK_COLON)    
      end
   end
   
   token,inner_token_list = initializer(token); table.insert(token_list, inner_token_list)
   
   while(token.t == Tokens.TOK_COMMA) do
      token = at(token_list,token)
      token,inner_token_list = initializer_list(token); table.insert(token_list, inner_token_list)
   end
   
   return token, token_list
 end
 
initializer = function(tok)
   local token_list = {}
   local inner_token_list = {} 
   local token = tok
   
   if(token.t == Tokens.TOK_OPENBRACE) then
      token = at(token_list,token);
      token, inner_token_list = initializer_list(token); table.insert(token_list, inner_token_list)
      
      if(token.t == Tokens.TOK_COMMA) then
         token = at(token_list,token)
      end
      
      token = at(token_list,token);
   else
      token, inner_token_list = assignment_expression(token); table.insert(token_list, inner_token_list)    
   end
   
   return token, token_list
 end

parameter_declaration = function(tok)
   local token_list = {}
   local inner_token_list = {}    
   local token = tok
   local declarator_name = nil
   local type_found = false

   while(true) do
      if(is_basic_type(token)) then     
         type_found = true
         token = at(token_list,token);  
         while(is_basic_type(token)) do
            token = at(token_list,token);  
         end         
      elseif(is_single_token_specifier_qualifier(token)) then
         token = at(token_list,token);
      elseif(nil ~= multiple_token_extension_keywords[token.v]) then
         token, inner_token_list = multiple_token_extension_keywords[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(nil ~= multiple_token_specifier_qualifiers[token.v]) then
         type_found = true
         token, inner_token_list = multiple_token_specifier_qualifiers[token.v](token); table.insert(token_list, inner_token_list)           
      elseif(token.t == Tokens.TOK_WORD) then
         if(type_found) then
            break
         elseif(is_new_type(token)) then
            type_found = true
            token = at(token_list,token);
         else
            break
         end
      else
         break
      end
   end

   --This declarator could actually be a abstract-declarator.  We can call direct-declarator though
   --because in a direct-declarator, then identifier is optional.
   token, inner_token_list,declarator_name, _ = declarator(token,false,true); table.insert(token_list, inner_token_list)      
   return token,token_list, declarator_name
 
 end
 
parameter_type_list = function(tok)
   local token_list = {}
   local inner_token_list = {}  
   local token = tok
   local declarator
   local ident_list = {}
   local ident_count = 0

   --parameter_type_list",token.v)

   token, inner_token_list, declarator = parameter_declaration(token); table.insert(token_list, inner_token_list)
   --If we are here, that means that an unknown type name was found
   if(token.t == Tokens.TOK_WORD) then
      error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Syntax Error.")
   end

   if(nil ~= declarator) then
      ident_count = ident_count + 1
      ident_list[ident_count] = declarator
   end
   
   while(token.t == Tokens.TOK_COMMA) do
      token = at(token_list,token)
   
      if(token.t == Tokens.TOK_ELLIPSES) then
         token = at(token_list,token)
         break
      else
         token, inner_token_list, declarator = parameter_declaration(token); table.insert(token_list, inner_token_list)
      end
   
      if(nil ~= declarator) then
         ident_count = ident_count + 1
         ident_list[ident_count] = declarator
      end
   end
   
   return token, token_list, ident_list
 end

consume_all_types = function(tok)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local ident_name
   local parameter_list = nil   

   while(true) do
      if(token.v == "_Pragma") or word_matches(token,"__pragma") then      
         token, inner_token_list = pragma_operator(token);table.insert(token_list, inner_token_list)            
      elseif(token.v == "typedef") then 
         typedef_found = true
         token = at(token_list,token)
      elseif(is_basic_type(token)) then     
         type_found = true
         token = at(token_list,token);  
         while(is_basic_type(token)) do
            token = at(token_list,token);  
         end         
      elseif(is_single_token_specifier_qualifier(token)) then
         token = at(token_list,token);
      elseif(nil ~= multiple_token_extension_keywords[token.v]) then
         token, inner_token_list = multiple_token_extension_keywords[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(nil ~= multiple_token_specifier_qualifiers[token.v]) then
         type_found = true
         token, inner_token_list = multiple_token_specifier_qualifiers[token.v](token); table.insert(token_list, inner_token_list)           
      elseif(token.t == Tokens.TOK_WORD) then
         if(type_found) then
            break
         elseif(is_new_type(token)) then
            type_found = true
            token = at(token_list,token);
         else
            break
         end
      else
         break
      end
   end

   return token, token_list  
end
 
direct_declarator = function(tok, is_abstract, in_parameter_declaration)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local ident_name
   local parameter_list = nil

   --if we see a type when here, then this is a parameter list within a parameter declaration
   --e.g "(int x)"" within int myFunc(int myFunc2(int x));
   if(in_parameter_declaration) then
      token, inner_token_list = consume_all_types(token); table.insert(token_list, inner_token_list)
   end

   if(token.t == Tokens.TOK_OPENPAREN) then
      token = at(token_list,token)
      token, inner_token_list, ident_name,parameter_list = declarator(token, is_abstract, in_parameter_declaration); table.insert(token_list, inner_token_list)
      token = at(token_list,token)
   elseif((true ~= is_abstract) and (token.t == Tokens.TOK_WORD)) then
      --get the IDENTIFIER
      if(nil ~= token) then
         ident_name = token.v
      end
      token = at(token_list,token)
   end

   while(true) do
      if(token.t == Tokens.TOK_AT) then
         token = at(token_list,token)
         token = at(token_list,token)      
      elseif(token.t == Tokens.TOK_OPENBRACKET) then
         --consume "["
         token = at(token_list,token)
 
         if(token.t == Tokens.TOK_CLOSEBRACKET) then
            token = at(token_list,token)
         else
            while(true) do
               if(is_type_qualifier(token)) then
                  token = at(token_list,token)
               elseif(token.v == "static") then
                  token = at(token_list,token)
               elseif(token.t ~= Tokens.TOK_CLOSEBRACKET) then
                  token, inner_token_list = assignment_expression(token); table.insert(token_list, inner_token_list)
               elseif(token.t == Tokens.TOK_CLOSEBRACKET) then
                  token = at(token_list,token)
                  break
               else
                  break
               end
            end
         end
      elseif(token.t == Tokens.TOK_OPENPAREN) then

         --consume the "("
         token = at(token_list,token)
 
         if(token.t == Tokens.TOK_CLOSEPAREN) then
            --consume the ")"
            token = at(token_list,token)            
         else
            token,inner_token_list,parameter_list = parameter_type_list(token); table.insert(token_list, inner_token_list)
            token = at(token_list,token)
         end
      --declaratorname  __attribute__((attributetext))  
      elseif((token.v == "__attribute__") or (token.v == "__attribute")) then 
         token, inner_token_list = attribute(token); table.insert(token_list, inner_token_list)
      --declaratorname  __asm__(asmtext) __attribute__((attributetext))  
      elseif(token.v == "__asm__") or word_matches(token,"asm") or word_matches(token,"__asm") then 
         token, inner_token_list = asm(token); table.insert(token_list, inner_token_list) 
      else
         break
      end
   end

   return token, token_list, ident_name, parameter_list
 end
 
declarator = function(tok, is_abstract, in_parameter_declaration)
   local token_list = {}
   local inner_token_list = {}
   local token = tok
   local ident_name
   local parameter_list = nil

   if(last_buffer_loc >= tok.buffer_loc) then
      last_buffer_loc_loop_detection_count = last_buffer_loc_loop_detection_count + 1
      if(last_buffer_loc_loop_detection_count > 10) then
         error("File: " .. SrcFileName .. " Line: " .. token.line_number .. " Error during parsing.")
      end
   else
      last_buffer_loc = tok.buffer_loc
      last_buffer_loc_loop_detection_count = 0
   end

   while(true) do

      --If the token is __cdecl, consume that first before getting the parameter
      --name.  This handles the __cdecl extension.
      if(token.v == "__cdecl") then
         token = at(token_list,token)
      elseif(token.v == "__stdcall") then
         token = at(token_list,token)
      end

      if(token.t == Tokens.TOK_STAR) then
         token, inner_token_list = pointer(token);table.insert(token_list, inner_token_list)
      --We need this here to handle cases where we see a "(" followed by __attribute__, such
      --as typedef void (__attribute__((__cdecl__)).  In such cases, the __attribute__ will not be
      --read via multiple_token_specifier_qualifiers, because once the "(" is seen, the parser
      --will stop reading type definitions and assume the next token is a declarator name.   
      elseif((token.v == "__attribute__") or (token.v == "__attribute")) then 
         token, inner_token_list = attribute(token); table.insert(token_list, inner_token_list)
      else
         break
      end
   end
   token,inner_token_list, ident_name,parameter_list = direct_declarator(token, is_abstract,in_parameter_declaration); table.insert(token_list, inner_token_list)
   return token,token_list, ident_name,parameter_list
 end

external_declaration = function(tok)
   local token_list = {}
   local inner_token_list = {}
 
   local token = tok
   ::top::
   local typedef_found = false
   local parameter_list = {}
   local declarator_names = {}
   local declarator_name
   local type_found = false
 
   while(true) do
      if(token.v == "_Pragma") or word_matches(token,"__pragma") then      
         token, inner_token_list = pragma_operator(token);table.insert(token_list, inner_token_list)            
      elseif(token.v == "typedef") then 
         typedef_found = true
         token = at(token_list,token)
      elseif(is_basic_type(token)) then     
         type_found = true
         token = at(token_list,token);  
         while(is_basic_type(token)) do
            token = at(token_list,token);  
         end         
      elseif(is_single_token_specifier_qualifier(token)) then
         token = at(token_list,token);
      elseif(nil ~= multiple_token_extension_keywords[token.v]) then
         token, inner_token_list = multiple_token_extension_keywords[token.v](token); table.insert(token_list, inner_token_list)      
      elseif(nil ~= multiple_token_specifier_qualifiers[token.v]) then
         type_found = true
         token, inner_token_list = multiple_token_specifier_qualifiers[token.v](token); table.insert(token_list, inner_token_list)           
      elseif(token.t == Tokens.TOK_WORD) then
         if(type_found) then
            break
         elseif(is_new_type(token)) then
            type_found = true
            token = at(token_list,token);
         else
            break
         end
      else
         break
      end
   end

   if(token.t == Tokens.TOK_SEMICOLON) then
      token = at(token_list,token)
 
      if((nil ~= token) and (END_OF_FILE ~= token.t)) then
         goto top
      end
   else
   local get_all_declarators = true
      while(true == get_all_declarators) do
         if(token.v == "__asm__") or word_matches(token,"asm") or word_matches(token,"__asm") then 
            token, inner_token_list = statement(token);table.insert(token_list, inner_token_list)
         elseif(token.t == Tokens.TOK_COMMA) then
            token = at(token_list,token)
            table.insert(declarator_names,declarator_name) 
         elseif(token.t == Tokens.TOK_ASSIGNMENT) then
            token = at(token_list,token)
            token, inner_token_list = initializer(token);table.insert(token_list, inner_token_list)
      
            --handles syntax like {1,2,3}[1]
            token, inner_token_list = postfix_expression(token);table.insert(token_list, inner_token_list)
         elseif(token.t == Tokens.TOK_SEMICOLON) then    
            token = at(token_list,token)    
            --add the last ident found to the list
            table.insert(declarator_names,declarator_name)
            --and then add the list of all idents
            --found to the actual identifier list
            add_idents(declarator_names,typedef_found)
            get_all_declarators = false
            declarator_names = {}
         elseif(token.t == Tokens.TOK_OPENBRACE) then    
            --It is a function, so the last declarator_name
            --found is the function name
    
            --send idents to compound
            token.function_name = declarator_name
            token, inner_token_list = compound_statement(token, parameter_list, true, declarator_name);table.insert(token_list, inner_token_list)
    
            get_all_declarators = false
         else
             --if nil, goto end_parse
            if(END_OF_FILE == token.t) then 
                goto end_parse
            end
             --else, it must be a declarator name
            token, inner_token_list, declarator_name, parameter_list = declarator(token,false,false);table.insert(token_list, inner_token_list)

            --If the parameter list is followed by a type name, then this is K&R C declaration
            --We don't need anything more.  Let's just skip until the {
            if((parameter_list ~= nil) and (is_specifier_qualifier(token))) then
               while(token.t ~= Tokens.TOK_OPENBRACE) do
                  token = at(token_list,token)
               end
            end
           
         end
      end
   end
 
   if((nil ~= token) and (END_OF_FILE ~= token.t)) then
      goto top
   end
 
   --Add the END_OF_FILE token
   table.insert(token_list,token)
 
 ::end_parse::
 
   return token_list
 
 end
 
 
add_idents = function(ident_list,typedef_found)
   if(nil == ident_list) then
      return
   end

   for _,ident in pairs(ident_list) do
      if(typedef_found) then
         add_ident(ident,NEW_TYPE)
      else
        add_ident(ident,nil)
      end
   end
end
 
line_directive_line_number = nil
line_directive_file_name = nil 
Buffer = nil
IdentTable = {}
InstrumentedText = {}
CoverageArrayIndex = 0

initialize_globals = function()
   --reset all globals
   IdentTable = {}
   IdentStack = {}
   CoverageData = {}
   CoverageResults = {}
   ResultsTemplate = {}
   InstrumentedText = {}
   expression_stack = ExpressionStack:create()
   last_buffer_loc_loop_detection_count = 0
   last_buffer_loc = 0

   CoverageEnabled = true
   line_directive_line_number = nil
   line_directive_file_name = nil 
   Buffer = nil
 end

write = function(s)
   table.insert(InstrumentedText,s)
end

has_child_boolean_expression = function(token_list)
   local list = token_list   
   local result = false

   --Note:  we don't need to do iterate through the whole list.  We start from the front of the
   --list and recursively check the list of tokens at the front of the list.  If we find there
   --is no boolean expression, then we return false.  This works out.  E.g, we want this function
   --to return false for expressions like "a(b && c)", because this isn't itself a boolean expression,
   --and it isn't a condition within a boolean expression.  
   if(token_list.expression_type == BOOLEAN_EXPRESSION) then
      return true
   end

   --Otherwise, iterate through the token list looking for a boolean expression
   for i=1,#list do
      if(list[i].expression_type == BOOLEAN_EXPRESSION) then    
         return true
      elseif((list[i].expression_type == NON_LOGICAL_EXPRESSION) or 
             (list[i].expression_type == RELATIONAL_EXPRESSION) or            
             (list[i].expression_type == COMMA_EXPRESSION) or      
             (list[i].expression_type == RELATIONAL_EXPRESSION) or                  
             (list[i].expression_type == CONDITIONAL_EXPRESSION) or                
             (list[i].expression_type == ARRAY_INDEX) or
             (list[i].expression_type == COMPOUND_STATEMENT_WITHIN_EXPRESSION) or             
             (list[i].expression_type == FUNCTION_PARAMETERS)) then
         --do nothing             
      elseif(nil == list[i].t) then
         return has_child_boolean_expression(list[i])
      end
   end

   return false
end
 
 parse_c_text = function(c_text)
   local token_list = {}
   Buffer = c_text
   BufferLength = Buffer:len()   
   local initial_token = {t = START_OF_FILE, line_number = 1, buffer_loc = 1}
   initial_token = at(token_list,initial_token)   
   
   local external_declaration_token_list = external_declaration(initial_token)
   table.insert(token_list,external_declaration_token_list)   
   return token_list
end
--End of code used for parsing

get_header_text = function()
   local header_text = [[
#define INST_MCDC(stack_loc,address,decision)  (tc_cov_offset_##stack_loc = 0,tc_temp_dec_##stack_loc = decision,]] .. ArrayName ..[[[address+tc_cov_offset_##stack_loc] = 1,(tc_temp_dec_##stack_loc))
#define INST_SINGLE(stack_loc,address,decision) (tc_temp_dec_##stack_loc = (decision),]] .. ArrayName ..[[[address] |= (1<<(tc_temp_dec_##stack_loc && 1)),(tc_temp_dec_##stack_loc))
#define INST_COND(stack_loc,offset,cond)  (tc_temp_cond_##stack_loc = (cond),tc_cov_offset_##stack_loc+=(offset*(1 && tc_temp_cond_##stack_loc)), (tc_temp_cond_##stack_loc))
#define COV_STATEMENT(address)  (]] .. ArrayName .. [[[address] = 1)
#define TC_COVERAGE_ARRAY_LENGTH (]] .. CoverageArrayIndex .. [[)
]]

   --Only create an extern if ArrayName is something custom, in which case
   --assume that it already exists in the source
   if(ArrayName == "tc_coverage") then
      header_text = header_text .. [[extern unsigned int tc_coverage[TC_COVERAGE_ARRAY_LENGTH];]] .. "\n";
   end
   return header_text
end

get_declarations_text = function()
   local declarations = [[
unsigned int ]] .. ArrayName .. "[" .. CoverageArrayIndex .. "];\n"
   
   return declarations
end

get_file_array_size = function()
   return CoverageArrayIndex - StartingArrayIndex
end

--Wrote this bitwise OR to allow this code to work with lua or luajit.
--Note that this works for up to 32 bits,
--due to the 31.
function bor(a,b)
   local result = 0
   for bit=0,31,1 do
       local r1 = ((a / (2 ^ (bit))) % 2) >= 1
       local r2 = ((b / (2 ^ (bit))) % 2) >= 1
       if(r1 or r2) then
           result = result + (2 ^ bit)
       end
   end
   return result
end

--Library function
function add_results(data_array)
   for index,data in ipairs(data_array) do
      if(CoverageData[index] == nil) then
         CoverageData[index] = tonumber(data)
      else
         CoverageData[index] = bor(CoverageData[index],tonumber(data))
      end   
   end  
end
 
--Library function
function generate_results(results_template)

   ResultsTemplate = {results_template}
   CoverageResults = {}

   local results_template_as_string = table.concat(ResultsTemplate)

   for statement in results_template_as_string:gmatch(".-%s-{.-}\n") do
      r,e = load(statement) 
      if(r == nil) then
         return "Error in results template"
      end
      r()
   end

   return table.concat(CoverageResults)
end

--Library function
function initialize_intrumenter()
   initialize_globals()
end

--Library function
function instrument_c_source(input_file_name, c_text, coverage_type, array_name, starting_array_index)
   initialize_globals()

   if(nil ~= array_name) then
      ArrayName = array_name
   end   

   if(nil ~= starting_array_index) then
      CoverageArrayIndex = starting_array_index
   end
   StartingArrayIndex = CoverageArrayIndex

   if(coverage_type == "MCDC") then
      MCDCCoverage = true
   elseif(coverage_type == "Statement") then
      StatementCoverage = true
   elseif(coverage_type == "Decision") then
      DecisionCoverage = true   
   elseif(coverage_type == "MCDC+Statement") then
      MCDCCoverage = true
      StatementCoverage = true
   elseif(coverage_type == "Decision+Statement") then
      DecisionCoverage = true
      StatementCoverage = true
   else
      return nil,  [[Incorrect coverage type.  Available Types:]] ..
      [[MCDC
      Statement
      Decision
      MCDC+Statement
      Decision+Statement
      ]]
   end

   local instrumentation_data = {}
   SrcFileName = input_file_name
   local r,token_list = pcall(parse_c_text,c_text)
   if(r == false) then
      local error_message = token_list
      return nil, error_message
   end

   r,message = pcall(evaluate_instrumentation_commands,token_list) 
   
   if(r == false) then
      local error_message = message
      return nil, error_message
   end

   local initial_results = get_initial_results()

   instrumentation_data.instrumented_source = table.concat(InstrumentedText)
   instrumentation_data.results_template = initial_results
   instrumentation_data.header = get_header_text()
   instrumentation_data.declarations = get_declarations_text()
   instrumentation_data.file_array_size = get_file_array_size()
   return instrumentation_data
end

--Copyright (c) 2023 Ryan Kluzak
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

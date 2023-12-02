#define INST_MCDC(stack_loc,address,decision)  (tc_cov_offset_##stack_loc = 0,tc_temp_dec_##stack_loc = decision,tc_coverage[address+tc_cov_offset_##stack_loc] = 1,(tc_temp_dec_##stack_loc))
#define INST_SINGLE(stack_loc,address,decision) (tc_temp_dec_##stack_loc = (decision),tc_coverage[address] |= (1<<(tc_temp_dec_##stack_loc && 1)),(tc_temp_dec_##stack_loc))
#define INST_COND(stack_loc,offset,cond)  (tc_temp_cond_##stack_loc = (cond),tc_cov_offset_##stack_loc+=(offset*(1 && tc_temp_cond_##stack_loc)), (tc_temp_cond_##stack_loc))
#define COV_STATEMENT(address)  (tc_coverage[address] = 1)
#define TC_COVERAGE_ARRAY_LENGTH (278)
extern unsigned int tc_coverage[TC_COVERAGE_ARRAY_LENGTH];

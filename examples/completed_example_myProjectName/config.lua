--Coverage = "MCDC"
--Coverage = "Statement"
--Coverage = "Decision"
--Coverage = "Decision+Statement"
Coverage = "MCDC+Statement"
ArrayName = "tc_coverage"
StartingArrayIndex = 0

--File names that are in this list will not be instrumented.
--They will be copied as is to the Instrumented folder.
DisableCoverage = {
}

--Example.
--DisableCoverage = {
--   "myFile.c",
--}


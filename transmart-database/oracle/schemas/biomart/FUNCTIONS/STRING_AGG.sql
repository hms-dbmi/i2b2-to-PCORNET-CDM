--------------------------------------------------------
--  DDL for Function STRING_AGG
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "BIOMART"."STRING_AGG" (p_input VARCHAR2)
RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING t_string_agg;
 
 
 
 
 
 
 

/

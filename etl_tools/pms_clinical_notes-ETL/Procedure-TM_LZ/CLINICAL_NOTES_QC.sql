create or replace PROCEDURE             CLINICAL_NOTES_QC AS 
 stepCt number(18,0);
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
BEGIN

 --SET Database name.
	SELECT sys_context('USERENV', 'CURRENT_SCHEMA') INTO databaseName FROM dual;
	procedureName := $$PLSQL_UNIT;

delete from  "TM_LZ"."Export_PMS_Clinical_Notes" where length(observation_blob)<3;

commit;

/* Set patient number = encounter number */
execute immediate 'update "TM_LZ"."Export_PMS_Clinical_Notes"
set patient_num=encounter_num';
  
  commit;
/* Need to modify algorithm for patient_num and encounter_num extraction */  
/* extract patient number */  
execute immediate 'update "TM_LZ"."Export_PMS_Clinical_Notes"
set patient_num=substr(patient_num,instr(patient_num,''_'',1)+1,(instr(patient_num,''-'',1)-(instr(patient_num,''_'',1)+1)))';
  
  commit;
  
/* extract encounter number */   
execute immediate 'update "TM_LZ"."Export_PMS_Clinical_Notes"
set encounter_num=substr(encounter_num,instr(encounter_num,''-'',1)+1,(instr(encounter_num,''.'',1)-(instr(encounter_num,''-'',1)+1)))';

stepCt := 0;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Filtering data with characters>3, update fields patient and encounter number','Done');

commit;
  NULL;
END CLINICAL_NOTES_QC;
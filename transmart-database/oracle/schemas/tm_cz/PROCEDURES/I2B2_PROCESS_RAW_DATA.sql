--------------------------------------------------------
--  DDL for Procedure I2B2_PROCESS_RAW_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_PROCESS_RAW_DATA" 
(
  trialID varchar2
)
AS

BEGIN

  --Record counts to counts table
  INSERT
  INTO I2B2_LZ.TPM_COUNTS
  (
    STUDY_ID,
    CATEGORY_CD,
    RECORD_COUNT,
    LOAD_DATE
  )
  select 
    study_id,
    category_cd, 
    count(*),
    sysdate
    from i2b2_lz.time_point_measurement
    where study_id = trialID
    group by 
      study_id,
      category_cd;
  commit;
    
  --Delete data from Time Point Measurement raw table where Trial Number and Category Code match.
  delete from i2b2_lz.time_point_measurement_raw
    where study_id = trialID
      and category_cd IN(select distinct category_cd from i2b2_lz.time_point_measurement where study_id = trialID);
  COMMIT;
  
  --Insert new records into Raw tables
  insert into 
    i2b2_lz.time_point_measurement_raw
  select * 
    from i2b2_lz.time_point_measurement
    where study_id = trialID;
  commit;
  
  --Clear the Working zone table
  delete from  i2b2_wz.time_point_measurement;
  
  --Load the new records
  insert into i2b2_wz.time_point_measurement
  select distinct * 
    from i2b2_lz.time_point_measurement a
      where data_value is not null
        and study_id = trialID;
  commit;
  
  --CATEGORY DATA
  --DELETE DATA from category table.
  delete 
    from i2b2_lz.category 
      where study_id = trialID
        and category_cd IN (Select category_cd from i2b2_lz.stg_category where study_id = trialID);
  COMMIT;

  --insert new records into the category table
  INSERT INTO I2B2_LZ.CATEGORY
    (study_id, category_cd, category_path)
  SELECT trialID, category_cd, category_path
    FROM i2b2_lz.stg_category;
  COMMIT;

  --clear the category table in the working zone
  delete  
    from i2b2_wz.category;

  --Insert the Category data converting the path to proper case
  INSERT INTO I2B2_WZ.CATEGORY
  select
    category_Cd, 
    initcap(category_path) as category_path,
    study_id
  FROM
    i2b2_lz.category
    where study_id = trialID;
  commit;

  --Fix category records
  UPDATE i2b2_wz.CATEGORY
  SET CATEGORY_PATH = REPLACE(CATEGORY_PATH, 'Elisa', 'ELISA')
  where category_path like '%Elisa%';
  commit;
  
  --Clean up LZ tables
  delete  
    from i2b2_lz.stg_category;
  
  delete 
    from i2b2_lz.time_point_measurement
      where study_id = trialID;
  commit;
END;

 
 
 
 

/

--------------------------------------------------------
--  DDL for Procedure I2B2_LOAD_NGS
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_LOAD_NGS" 
(
  trial_id 			IN	VARCHAR2
 ,top_node			in  varchar2
 ,secure_study		in varchar2 := 'N'
 ,highlight_study	in	varchar2 := 'N'
 ,currentJobID		IN	NUMBER := null
)
AS

	--	JEA@20110708	Cloned from i2b2_apply_curation_rules and i2b2_load_tpm_post_curation
	--	JEA@20111028	Changed source table to lt_src_clinical_data, this table will be loaded either through
	--					i2b2_clinical_data_extrnl_lt sp or through sqlldr where external tables are not feasible
	--	JEA@20111114	Added ctrl_vocab_code
	--	JEA@20111115	Reuse concept_cds, i2b2 and concept_dimension
	--	JEA@20111201	Added join to concept_dimension when setting datatype of N and xml for i2b2
	--	JEA@20111220	Don't delete patients that exist in de_subject_sample_mapping
	--	JEA@20111226	Change all & to ' and ' in category_cd, data_label or data_value
	--	JEA@20120103	Only check for dups for numeric data values, text won't cause problems on insert
	--	JEA@20120103	Remove setting c_basecode to null for folders
	--	JEA@20120104	Don't insert into observation_fact if lower-level leaf node exists
	--	JEA@20120105	Fix node_name in wt_trial_nodes for numeric data types wchere data_label is concatenation
	--	JEA@20120109	Added populate i2b2_id on insert to i2b2
	--	JEA@20120111	Added populate wt_clinical_data_dups table to easily identify duplicate records
	--	JEA@20120113	Change del_nodes to look for H in pos 2 of c_visualattributes
	--	JEA220120119	Don't run i2b2_create_patient_trial, delete/insert done as part of proc
	--	JEA@20120120	Comment out delete/insert to patient_trial, incorporated as part of i2b2_create_security_for_trial
	--	JEA@20120204	Remove data_label from last part of category_path and category_cd when they are the same
	--	JEA@20120215	Add : to where clause in delete patient_dimension
	--	JEA@20120229	Added replace of + with ' and ' to data_label and data_value
	--	JEA@20120318	Correct node_name where visit_name is not null
	--	JEA@20120318	Update node if node_name changed or changed from text to numeric
	--	JEA@20120319	Added third c_visualattributes = J for topNode
	--	JEA@20120402	Fixed update to patient_dimension to add coalesce for null values
	--	JEA@20120409	Add new parameter, highlight_study that will determine if J is set as third position of c_visualattributes for topNode
	--	JEA@20120411	Fix c_visualattribute issue when node changed from numeric leaf to folder
	--	JEA@20120411	Add DATALABEL, VISITNAME override to category_cd, add update of node_name in wt_trial_nodes
	--	JEA@20120421	Default sex_cd in patient_dimenstion to Unknown when null
	--	JEA220120425	Add single DATALABEL in category_cd to force drop of visit_name/VISITNAME
	--	JEA@20120507	Fix missing data_value when DATALABEL, VISITNAME in category_cd
	--	JEA@20120508	Add trial name to start audit text, change patient update to coalesce for sex_cd, race_cd, 
	--					remove case statement that set sex_cd to M/F/U
	--	JEA@20120510	Add root node using i2b2_add_root_node if missing
	--	JEA@20120511	Only insert unique leaf_nodes to concept_dimension
	--	JEA@20120517	Set visit_name to null if only DATALABEL in category_cd
	--	JEA@20120526	Set sourcesystem_cd, c_comment to null if any upper-level nodes added
	--	JEA@20120601	Change underscore (_) to space in data_label
	--	JEA@20120603	Raise exception if only one node in top_node
	--	JEA@20120604	Raise exception if category_cd, data_label, data_value has both null and non-null visit_name
  
  topNode		VARCHAR2(2000);
  topLevel		number(10,0);
  root_node		varchar2(2000);
  root_level	int;
  study_name	varchar2(2000);
  TrialID		varchar2(100);
  secureStudy	varchar2(200);
  etlDate		date;
  tPath			varchar2(2000);
  pCount		int;
  pExists		int;
  rtnCode		int;
  tText			varchar2(2000);
  
    --Audit variables
  newJobFlag INTEGER(1);
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
  jobID number(18,0);
  stepCt number(18,0);
  
  duplicate_values	exception;
  invalid_topNode	exception;
  multiple_visit_names	exception;
  
  CURSOR addNodes is
  select DISTINCT 
         leaf_node,
    		 node_name
  from  wt_trial_nodes a
  ;
   
	--	cursor to define the path for delete_one_node  this will delete any nodes that are hidden after i2b2_create_concept_counts

	CURSOR delNodes is
	select distinct c_fullname 
	from  i2b2
	where c_fullname like topNode || '%'
      and substr(c_visualattributes,2,1) = 'H';

BEGIN
  
 execute immediate('drop index TM_WZ.LEAF_NODE_IDX');
  
  
	TrialID := upper(trial_id);
	secureStudy := upper(secure_study);
	
	--Set Audit Parameters
	newJobFlag := 0; -- False (Default)
	jobID := currentJobID;

	SELECT sys_context('USERENV', 'CURRENT_SCHEMA') INTO databaseName FROM dual;
	procedureName := $$PLSQL_UNIT;
	
	select sysdate into etlDate from dual;
	
	--Audit JOB Initialization
	--If Job ID does not exist, then this is a single procedure run and we need to create it
	IF(jobID IS NULL or jobID < 1)
	THEN
		newJobFlag := 1; -- True
		cz_start_audit (procedureName, databaseName, jobID);
	END IF;
    	
	stepCt := 0;

	stepCt := stepCt + 1;
	tText := 'Start i2b2_load_clinical_data for ' || TrialId;
	cz_write_audit(jobId,databaseName,procedureName,tText,0,stepCt,'Done');
	
	if (secureStudy not in ('Y','N') ) then
		secureStudy := 'Y';
	end if;
	
	topNode := REGEXP_REPLACE('\' || top_node || '\','(\\\\\\\\)|(\\\\\\)|(\\\\)', '\');
	
	--	figure out how many nodes (folders) are at study name and above
	--	\Public Studies\Clinical Studies\Pancreatic_Cancer_Smith_GSE22780\: topLevel = 4, so there are 3 nodes
	--	\Public Studies\GSE12345\: topLevel = 3, so there are 2 nodes
	
	select length(topNode)-length(replace(topNode,'\','')) into topLevel from dual;
	
	if topLevel < 3 then
		raise invalid_topNode;
	end if;	
	--	delete any existing data from lz_src_clinical_data and load new data
	
	delete from lz_src_clinical_data
	where study_id = TrialId;
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete existing data from lz_src_clinical_data',SQL%ROWCOUNT,stepCt,'Done');
	commit;
	
	insert into lz_src_clinical_data
	(study_id
	,site_id
	,subject_id
	,visit_name
	,data_label
	,data_value
	,category_cd
	,etl_job_id
	,etl_date
	,ctrl_vocab_code)
	select study_id
		  ,site_id
		  ,subject_id
		  ,visit_name
		  ,data_label
		  ,data_value
		  ,category_cd
		  ,jobId
		  ,etlDate
		  ,ctrl_vocab_code
	from TM_LZ.lt_src_ngs;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert data into lz_src_clinical_data',SQL%ROWCOUNT,stepCt,'Done');
	commit;
		
	--	truncate wrk_clinical_data and load data from external file
	
	execute immediate('truncate table tm_wz.wrk_clinical_data');
	
	--	insert data from lt_src_NGS to wrk_clinical_data
	
	insert into wrk_clinical_data
	(study_id
	,site_id
	,subject_id
	,visit_name
	,data_label
	,data_value
	,category_cd
	,ctrl_vocab_code
	)
	select study_id
		  ,site_id
		  ,subject_id
		  ,visit_name
		  ,data_label
		  ,data_value
		  ,category_cd
		  ,ctrl_vocab_code
	from tm_lz.lt_src_NGS;
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Load lt_src_NGS to work table',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;  	

	-- Get root_node from topNode
  
	select parse_nth_value(topNode, 2, '\') into root_node from dual;
	
	select count(*) into pExists
	from table_access
	where c_name = root_node;
	
	if pExists = 0 then
		i2b2_add_root_node(root_node, jobId);
	end if;
	
	select c_hlevel into root_level
	from table_access
	where c_name = root_node;
	
	-- Get study name from topNode
  
	select parse_nth_value(topNode, topLevel, '\') into study_name from dual;
	
	--	Add any upper level nodes as needed
	
	tPath := REGEXP_REPLACE(replace(top_node,study_name,null),'(\\\\\\\\)|(\\\\\\)|(\\\\)', '\');
	select length(tPath) - length(replace(tPath,'\',null)) into pCount from dual;

	if pCount > 2 then
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Adding upper-level nodes',0,stepCt,'Done');
		i2b2_fill_in_tree(null, tPath, jobId);
	end if;
	
/*	Don't delete existing data, concept_cds will be reused
	--	delete any existing data
	
	i2b2_delete_all_nodes(topNode, jobId);
*/

	select count(*) into pExists
	from i2b2
	where c_fullname = topNode;
	
	--	add top node for study
	
	if pExists = 0 then
		i2b2_add_node(TrialId, topNode, study_name, jobId);
	end if;
  
	--	Set data_type, category_path, and usubjid 
  
	update wrk_clinical_data
	set data_type = 'T'
	   ,category_path = replace(replace(category_cd,'_',' '),'+','\')
	  -- ,usubjid = TrialID || ':' || site_id || ':' || subject_id;
	   ,usubjid = REGEXP_REPLACE(TrialID || ':' || site_id || ':' || subject_id,
                   '(::::)|(:::)|(::)', ':'); 
	 
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set columns in wrk_clinical_data',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
  
	--	Delete rows where data_value is null
  
	delete from wrk_clinical_data
	where data_value is null;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete null data_values in wrk_clinical_data',SQL%ROWCOUNT,stepCt,'Done');
	
	--Remove Invalid pipes in the data values.
	--RULE: If Pipe is last or first, delete it
	--If it is in the middle replace with a dash

	update wrk_clinical_data
	set data_value = replace(trim('|' from data_value), '|', '-')
	where data_value like '%|%';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Remove pipes in data_value',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;  
  
	--Remove invalid Parens in the data
	--They have appeared as empty pairs or only single ones.
  
	update wrk_clinical_data
	set data_value = replace(data_value,'(', '')
	where data_value like '%()%'
	   or data_value like '%( )%'
	   or (data_value like '%(%' and data_value NOT like '%)%');
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Remove empty parentheses 1',SQL%ROWCOUNT,stepCt,'Done');
	
	update wrk_clinical_data
	set data_value = replace(data_value,')', '')
	where data_value like '%()%'
	   or data_value like '%( )%'
	   or (data_value like '%)%' and data_value NOT like '%(%');
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Remove empty parentheses 2',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	--Replace the Pipes with Commas in the data_label column
	update wrk_clinical_data
    set data_label = replace (data_label, '|', ',')
    where data_label like '%|%';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Replace pipes with comma in data_label',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	--	set visit_name to null when there's only a single visit_name for the catgory
	
	update wrk_clinical_data tpm
	set visit_name=null
	where (tpm.category_cd) in
		  (select x.category_cd
		   from wrk_clinical_data x
		   group by x.category_cd
		   having count(distinct upper(x.visit_name)) = 1);

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set single visit_name to null',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;
	
  ---------------------------------------------------------------
  --BEGIN Using Node Curation table to convert values or set Suppression flag.
  ---------------------------------------------------------------
  
  --DATA_VALUE
  update wrk_clinical_data a
    set a.data_value = 
      (select replace(Upper(a.data_value), b.node_name, b.display_name)
        from node_curation b
      where b.node_type = 'DATA_VALUE'
        and upper(a.data_value) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'DATA_VALUE'
        and upper(a.data_value) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for DATA_VALUE',SQL%ROWCOUNT,stepCt,'Done');
	
  COMMIT;

  --DATA_LABEL
  update wrk_clinical_data a
    set a.data_label = 
      (select replace(Upper(a.data_label), b.node_name, b.display_name)
        from node_curation b
      where b.node_type = 'DATA_LABEL'
        and upper(a.data_label) = b.node_name  
        and active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'DATA_LABEL'
        and upper(a.data_label) = b.node_name  
        and active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for DATA_LABEL',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;

	
/*	--	set sample_type to null when there's only a single sample_type for the category except Samples and Timepoints
	
	update wrk_clinical_data tpm
	set sample_type=null
	where tpm.category_cd in
		 (select x.category_cd
		  from wrk_clinical_data x
		  group by x.category_cd
		  having count(distinct upper(x.sample_type)) = 1)
	  and upper(tpm.category_cd) not like 'SAMPLES_AND_TIMEPOINTS%';

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set single sample_type to null',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;
*/
	
	--	set data_label to null when it duplicates the last part of the category_path
	--	Remove data_label from last part of category_path when they are the same
	
	update wrk_clinical_data tpm
	--set data_label = null
	set category_path=substr(tpm.category_path,1,instr(tpm.category_path,'\',-2)-1)
	   ,category_cd=substr(tpm.category_cd,1,instr(tpm.category_cd,'+',-2)-1)
	where (tpm.category_cd, tpm.data_label) in
		  (select distinct t.category_cd
				 ,t.data_label
		   from wrk_clinical_data t
		   where upper(substr(t.category_path,instr(t.category_path,'\',-1)+1,length(t.category_path)-instr(t.category_path,'\',-1))) 
			     = upper(t.data_label)
		     and t.data_label is not null)
	  and tpm.data_label is not null;

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set data_label to null when found in category_path',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;

	--	set visit_name to null if same as data_label
	
	update wrk_clinical_data t
	set visit_name=null
	where (t.category_cd, t.visit_name, t.data_label) in
	      (select distinct tpm.category_cd
				 ,tpm.visit_name
				 ,tpm.data_label
		  from wrk_clinical_data tpm
		  where tpm.visit_name = tpm.data_label);

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set visit_name to null when found in data_label',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;
	
	--	set visit_name to null if same as data_value
	
	update wrk_clinical_data t
	set visit_name=null
	where (t.category_cd, t.visit_name, t.data_value) in
	      (select distinct tpm.category_cd
				 ,tpm.visit_name
				 ,tpm.data_value
		  from wrk_clinical_data tpm
		  where tpm.visit_name = tpm.data_value);

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set visit_name to null when found in data_value',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;
	
	--	set visit_name to null if only DATALABEL in category_cd
	
	update wrk_clinical_data t
	set visit_name=null
	where t.category_cd like '%DATALABEL%'
	  and t.category_cd not like '%VISITNAME%';

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set visit_name to null when only DATALABE in category_cd',SQL%ROWCOUNT,stepCt,'Done');
		
	commit;

/*	--	Remove sample_type if found in category_path
	
	update wrk_clinical_data t
	set sample_type = null
	where exists
	     (select 1 from wrk_clinical_data c
		  where instr(c.category_path,t.sample_type) > 0);
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Remove sample_type if already in category_path',SQL%ROWCOUNT,stepCt,'Done');
	commit;
*/
	--	comment out may need later
	
	--	change any % to Pct and & and + to ' and ' and _ to space in data_label only
	
	update wrk_clinical_data
	set data_label=replace(replace(replace(replace(data_label,'%',' Pct'),'&',' and '),'+',' and '),'_',' ')
	   ,data_value=replace(replace(replace(data_value,'%',' Pct'),'&',' and '),'+',' and ')
	   ,category_cd=replace(replace(category_cd,'%',' Pct'),'&',' and ')
	   ,category_path=replace(replace(category_path,'%',' Pct'),'&',' and ');

  --Trim trailing and leadling spaces as well as remove any double spaces, remove space from before comma, remove trailing comma

	update wrk_clinical_data
	set data_label  = trim(trailing ',' from trim(replace(replace(data_label,'  ', ' '),' ,',','))),
		data_value  = trim(trailing ',' from trim(replace(replace(data_value,'  ', ' '),' ,',','))),
--		sample_type = trim(trailing ',' from trim(replace(replace(sample_type,'  ', ' '),' ,',','))),
		visit_name  = trim(trailing ',' from trim(replace(replace(visit_name,'  ', ' '),' ,',',')));
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Remove leading, trailing, double spaces',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

    --1. DETERMINE THE DATA_TYPES OF THE FIELDS
	--	replaced cursor with update, used temp table to store category_cd/data_label because correlated subquery ran too long
	
	execute immediate('truncate table tm_wz.wt_num_data_types');
  
	insert into wt_num_data_types
	(category_cd
	,data_label
	,visit_name
	)
    select category_cd,
           data_label,
           visit_name
    from wrk_clinical_data
    where data_value is not null
    group by category_cd
	        ,data_label
            ,visit_name
      having sum(is_number(data_value)) = 0;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert numeric data into WZ wt_num_data_types',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	--	Check if any duplicate records of key columns (site_id, subject_id, visit_name, data_label, category_cd) for numeric data
	--	exist.  Raise error if yes
	
	execute immediate('truncate table tm_wz.wt_clinical_data_dups');
	
	insert into wt_clinical_data_dups
	(site_id
	,subject_id
	,visit_name
	,data_label
	,category_cd)
	select w.site_id, w.subject_id, w.visit_name, w.data_label, w.category_cd
	from wrk_clinical_data w
	where exists
		 (select 1 from wt_num_data_types t
		 where coalesce(w.category_cd,'@') = coalesce(t.category_cd,'@')
		   and coalesce(w.data_label,'@') = coalesce(t.data_label,'@')
		   and coalesce(w.visit_name,'@') = coalesce(t.visit_name,'@')
		  )
	group by w.site_id, w.subject_id, w.visit_name, w.data_label, w.category_cd
	having count(*) > 1;
		  
	pCount := SQL%ROWCOUNT;
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Check for duplicate key columns',pCount,stepCt,'Done');
			  
	--if pCount > 0 then
	--	raise duplicate_values;
	--end if;
	
	--	check for multiple visit_names for category_cd, data_label, data_value
	
     select max(case when x.null_ct > 0 and x.non_null_ct > 0
					 then 1 else 0 end) into pCount
      from (select category_cd, data_label, data_value
				  ,sum(decode(visit_name,null,1,0)) as null_ct
				  ,sum(decode(visit_name,null,0,1)) as non_null_ct
			from tm_lz.lt_src_NGS
			group by category_cd, data_label, data_value) x;
  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Check for multiple visit_names for category/label/value ',pCount,stepCt,'Done');
			  
	if pCount > 0 then
		raise multiple_visit_names;
	end if;
		
	update wrk_clinical_data t
	set data_type='N'
	where exists
	     (select 1 from wt_num_data_types x
	      where nvl(t.category_cd,'@') = nvl(x.category_cd,'@')
			and nvl(t.data_label,'**NULL**') = nvl(x.data_label,'**NULL**')
			and nvl(t.visit_name,'**NULL**') = nvl(x.visit_name,'**NULL**')
		  );
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Updated data_type flag for numeric data_types',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	-- Build all needed leaf nodes in one pass for both numeric and text nodes
 
	execute immediate('truncate table tm_wz.wt_trial_nodes');
	
	insert into wt_trial_nodes
	(leaf_node
	,category_cd
	,visit_name
	,data_label
	--,node_name
	,data_value
	,data_type
	)
    select DISTINCT 
    Case 
	--	Text data_type (default node)
	When a.data_type = 'T'
	     then case when a.category_path like '%DATALABEL%' and a.category_path like '%VISITNAME%'
		      then regexp_replace(topNode || replace(replace(a.category_path,'DATALABEL',a.data_label),'VISITNAME',a.visit_name) || '\' || a.data_value || '\','(\\\\\\\\)|(\\\\\\)|(\\\\)', '\')
			  when a.category_path like '%DATALABEL%'
			  then regexp_replace(topNode || replace(a.category_path,'DATALABEL',a.data_label) || '\' || a.data_value || '\','(\\\\\\\\)|(\\\\\\)|(\\\\)', '\')
			  else REGEXP_REPLACE(topNode || a.category_path || 
                   '\'  || a.data_label || '\' || a.data_value || '\' || a.visit_name || '\',
                   '(\\\\\\\\)|(\\\\\\)|(\\\\)', '\') 
			  end
	--	else is numeric data_type and default_node
	else case when a.category_path like '%DATALABEL%' and a.category_path like '%VISITNAME%'
		      then regexp_replace(topNode || replace(replace(a.category_path,'DATALABEL',a.data_label),'VISITNAME',a.visit_name) || '\','(\\\\\\\\)|(\\\\\\)|(\\\\)', '\')
			  when a.category_path like '%DATALABEL%'
			  then regexp_replace(topNode || replace(a.category_path,'DATALABEL',a.data_label) || '\','(\\\\\\\\)|(\\\\\\)|(\\\\)', '\')
			  else REGEXP_REPLACE(topNode || a.category_path || 
                   '\'  || a.data_label || '\' || a.visit_name || '\',
                   '(\\\\\\\\)|(\\\\\\)|(\\\\)', '\')
			  end
	end as leaf_node,
    a.category_cd,
    a.visit_name,
	a.data_label,
/*  moved to update below
	Case 
	--	Text data_type (default node)
	When a.data_type = 'T'
	    then a.data_value 
	--	Numeric data_type and Biomarker/Other category
	--else a.data_label
	else case when a.visit_name is not null and instr(a.visit_name,'\') > 0
            then case when length(a.visit_name)-length(replace(a.visit_name,'\',null)) = 1
                      then case when instr(a.visit_name,'\') between 2 and length(a.visit_name) -1
                           then substr(a.visit_name,instr(a.visit_name,'\',-1)+1)
                           else replace(a.visit_name,'\',null)
                           end
                       else substr(a.visit_name,instr(a.visit_name,'\',-1)+1)
                  end
            when a.visit_name is not null then a.visit_name
            when instr(a.data_label,'\',-1) > 0 then substr(a.data_label,instr(a.data_label,'\',-1)+1)
            else a.data_label
            end
	end as node_name,
*/
	decode(a.data_type,'T',a.data_value,null) as data_value
    ,a.data_type
	from  wrk_clinical_data a;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Create leaf nodes for trial',SQL%ROWCOUNT,stepCt,'Done');
	commit;
	
	--	set node_name
	
	update wt_trial_nodes
	set node_name=parse_nth_value(leaf_node,length(leaf_node)-length(replace(leaf_node,'\',null)),'\');
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Updated node name for leaf nodes',SQL%ROWCOUNT,stepCt,'Done');
	commit;	
  
  -- NEW INDEX
	execute immediate('CREATE INDEX  TM_WZ.LEAF_NODE_IDX ON TM_WZ.WT_TRIAL_NODES (LEAF_NODE)');
  
      
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Create new LEAF_NODE_IDX',SQL%ROWCOUNT,stepCt,'Done');
	commit;	

	DBMS_STATS.UNLOCK_TABLE_STATS('TM_WZ','WT_TRIAL_NODES');
	execute immediate('analyze table tm_wz.wt_trial_nodes compute statistics');
	
	--	insert subjects into patient_dimension if needed
	
	execute immediate('truncate table tmp_subject_info');

	insert into tmp_subject_info
	(usubjid,
     age_in_years_num,
     sex_cd,
     race_cd
    )
	select a.usubjid,
	      nvl(max(case when upper(a.data_label) = 'AGE'
					   then case when is_number(a.data_value) = 1 then 0 else to_number(a.data_value) end
		               when upper(a.data_label) like '%(AGE)' 
					   then case when is_number(a.data_value) = 1 then 0 else to_number(a.data_value) end
					   else null end),0) as age,
		  --nvl(max(decode(upper(a.data_label),'AGE',data_value,null)),0) as age,
		  nvl(max(case when upper(a.data_label) = 'SEX' then a.data_value
		           when upper(a.data_label) like '%(SEX)' then a.data_value
				   when upper(a.data_label) = 'GENDER' then a.data_value
				   else null end),'Unknown') as sex,
		  --max(decode(upper(a.data_label),'SEX',data_value,'GENDER',data_value,null)) as sex,
		  max(case when upper(a.data_label) = 'RACE' then a.data_value
		           when upper(a.data_label) like '%(RACE)' then a.data_value
				   else null end) as race
		  --max(decode(upper(a.data_label),'RACE',data_value,null)) as race
	from wrk_clinical_data a
	--where upper(a.data_label) in ('AGE','RACE','SEX','GENDER')
	group by a.usubjid;
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert subject information into temp table',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
	
	--	Delete dropped subjects from patient_dimension if they do not exist in de_subject_sample_mapping
	
	delete patient_dimension
	where sourcesystem_cd in
		 (select distinct pd.sourcesystem_cd from patient_dimension pd
		  where pd.sourcesystem_cd like TrialId || ':%'
		  minus 
		  select distinct cd.usubjid from wrk_clinical_data cd)
	  and patient_num not in
		  (select distinct sm.patient_id from de_subject_sample_mapping sm);
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete dropped subjects from patient_dimension',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;	
	
	--	update patients with changed information
	
	update patient_dimension pd
	set (sex_cd, age_in_years_num, race_cd, update_date) = 
		(select nvl(t.sex_cd,pd.sex_cd), t.age_in_years_num, nvl(t.race_cd,pd.race_cd), sysdate
		 from tmp_subject_info t
		 where t.usubjid = pd.sourcesystem_cd
		   and (coalesce(pd.sex_cd,'@') != t.sex_cd or
				pd.age_in_years_num != t.age_in_years_num or
				coalesce(pd.race_cd,'@') != t.race_cd)
		)
	where exists
		 (select 1 from tmp_subject_info x
		  where pd.sourcesystem_cd = x.usubjid
		    and (coalesce(pd.sex_cd,'@') != x.sex_cd or
				 pd.age_in_years_num != x.age_in_years_num or
				 coalesce(pd.race_cd,'@') != x.race_cd)
		 );
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Update subjects with changed demographics in patient_dimension',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;	

	--	insert new subjects into patient_dimension
	
	insert into patient_dimension
    (patient_num,
     sex_cd,
     age_in_years_num,
     race_cd,
     update_date,
     download_date,
     import_date,
     sourcesystem_cd
    )
    select seq_patient_num.nextval,
		   t.sex_cd,
		   t.age_in_years_num,
		   t.race_cd,
		   sysdate,
		   sysdate,
		   sysdate,
		   t.usubjid
    from tmp_subject_info t
	where t.usubjid in 
		 (select distinct cd.usubjid from tmp_subject_info cd
		  minus
		  select distinct pd.sourcesystem_cd from patient_dimension pd
		  where pd.sourcesystem_cd like TrialId || '%');
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert new subjects into patient_dimension',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
		
	--	insert data into patient_trial
	
	--i2b2_create_patient_trial(TrialId, topNode, jobId, rtnCode);
	
	--	bulk insert leaf nodes
	
	update concept_dimension cd
	set name_char=(select t.node_name from wt_trial_nodes t
				   where cd.concept_path = t.leaf_node
				     and cd.name_char != t.node_name)
	where exists (select 1 from wt_trial_nodes x
				  where cd.concept_path = x.leaf_node
				    and cd.name_char != x.node_name);
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Update name_char in concept_dimension for changed names',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
							
	
	insert into concept_dimension
    (concept_cd
	,concept_path
	,name_char
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	,table_name
	)
    select concept_id.nextval
	     ,x.leaf_node
		 ,x.node_name
		 ,sysdate
		 ,sysdate
		 ,sysdate
		 ,TrialId
		 ,'CONCEPT_DIMENSION'
	from (select distinct c.leaf_node
				,to_char(c.node_name) as node_name
		  from wt_trial_nodes c
		  where not exists
			(select 1 from concept_dimension x
			where c.leaf_node = x.concept_path)
		 ) x;
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Inserted new leaf nodes into I2B2DEMODATA concept_dimension',SQL%ROWCOUNT,stepCt,'Done');
    commit;
	
	--	update i2b2 if name or data type changed
	
	update i2b2 b
	set (c_name, c_columndatatype)=
		(select t.node_name, t.data_type from wt_trial_nodes t
		 where b.c_fullname = t.leaf_node
		   and (b.c_name != t.node_name or b.c_columndatatype != t.data_type))
	where exists
		(select 1 from wt_trial_nodes x
		 where b.c_fullname = x.leaf_node
		   and (b.c_name != x.node_name or b.c_columndatatype != x.data_type));
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Updated name and data type in i2b2 if changed',SQL%ROWCOUNT,stepCt,'Done');
    commit;
			   
	insert into i2b2
    (c_hlevel
	,c_fullname
	,c_name
	,c_visualattributes
	,c_synonym_cd
	,c_facttablecolumn
	,c_tablename
	,c_columnname
	,c_dimcode
	,c_tooltip
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	,c_basecode
	,c_operator
	,c_columndatatype
	,c_comment
	,i2b2_id
	)
    select (length(c.concept_path) - nvl(length(replace(c.concept_path, '\')),0)) / length('\') - 2 + root_level
		  ,c.concept_path
		  ,c.name_char
		  ,'FA'
		  ,'N'
		  ,'CONCEPT_CD'
		  ,'CONCEPT_DIMENSION'
		  ,'CONCEPT_PATH'
		  ,c.concept_path
		  ,c.concept_path
		  ,sysdate
		  ,sysdate
		  ,sysdate
		  ,c.sourcesystem_cd
		  ,c.concept_cd
		  ,'LIKE'
		  ,'T'
		  ,'trial:' || TrialID 
		  ,i2b2_id_seq.nextval
    from concept_dimension c
    where c.concept_path in
	     (select leaf_node from wt_trial_nodes)
	  and not exists
		 (select 1 from i2b2 x
		  where c.concept_path = x.c_fullname);
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Inserted leaf nodes into I2B2METADATA i2b2',SQL%ROWCOUNT,stepCt,'Done');
    COMMIT;

	--	delete from observation_fact all concept_cds for trial that are clinical data, exclude concept_cds from biomarker data
	
	delete from observation_fact f
	where f.modifier_cd = TrialId
	  and f.concept_cd not in
		 (select distinct concept_code as concept_cd from de_subject_sample_mapping
		  where trial_name = TrialId
		    and concept_code is not null
		  union
		  select distinct platform_cd as concept_cd from de_subject_sample_mapping
		  where trial_name = TrialId
		    and platform_cd is not null
		  union
		  select distinct sample_type_cd as concept_cd from de_subject_sample_mapping
		  where trial_name = TrialId
		    and sample_type_cd is not null
		  union
		  select distinct tissue_type_cd as concept_cd from de_subject_sample_mapping
		  where trial_name = TrialId
		    and tissue_type_cd is not null
		  union
		  select distinct timepoint_cd as concept_cd from de_subject_sample_mapping
		  where trial_name = TrialId
		    and timepoint_cd is not null
		  union
		  select distinct concept_cd as concept_cd from de_subject_snp_dataset
		  where trial_name = TrialId
		    and concept_cd is not null);
		  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete clinical data for study from observation_fact',SQL%ROWCOUNT,stepCt,'Done');
    COMMIT;		  
	
    --Insert into observation_fact
	
	insert into i2b2demodata.observation_fact
	(encounter_num,
    patient_num,
     concept_cd,
     modifier_cd,
     valtype_cd,
     tval_char,
     nval_num,
     sourcesystem_cd,
     import_date,
     valueflag_cd,
     provider_id,
     location_cd
	)
	select distinct 
  a.CTRL_VOCAB_CODE,
  c.patient_num,
		   i.c_basecode,
		   a.study_id,
		   a.data_type,
		   case when a.data_type = 'T' then a.data_value
				else 'E'  --Stands for Equals for numeric types
				end,
		   case when a.data_type = 'N' then a.data_value
				else null --Null for text types
				end,
		   c.sourcesystem_cd, 
		  sysdate, 
		   '@',
		   '@',
		   '@'
	from wrk_clinical_data a
		,patient_dimension c
		,wt_trial_nodes t
		,i2b2 i
	where a.usubjid = c.sourcesystem_cd
	  and nvl(a.category_cd,'@') = nvl(t.category_cd,'@')
	  and nvl(a.data_label,'**NULL**') = nvl(t.data_label,'**NULL**')
	  and nvl(a.visit_name,'**NULL**') = nvl(t.visit_name,'**NULL**')
	  and decode(a.data_type,'T',a.data_value,'**NULL**') = nvl(t.data_value,'**NULL**')
	  and t.leaf_node = i.c_fullname
	  and not exists		-- don't insert if lower level node exists
		 (select 1 from wt_trial_nodes x
		  where x.leaf_node like t.leaf_node || '%_')
	  and a.data_value is not null;
/*	join patient_dimension c
		 on c.sourcesystem_cd = a.usubjid
	join wt_trial_nodes t
		 on  nvl(a.category_cd,'@') = nvl(t.category_cd,'@')
		 and nvl(a.data_label,'**NULL**') = nvl(t.data_label,'**NULL**')
		 and nvl(a.visit_name,'**NULL**') = nvl(t.visit_name,'**NULL**')
		 and decode(a.data_type,'T',a.data_value,'**NULL**') = nvl(t.data_value,'**NULL**')
	join i2b2 i
		 on i.c_fullname = t.leaf_node
	where a.data_value is not null;
*/  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert trial into I2B2DEMODATA observation_fact',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	--Update I2b2 for correct data type
	
	update i2b2 b
	set c_columndatatype = 'T', c_metadataxml = null, c_visualattributes='F' || substr(b.c_visualattributes,2,2)
	where c_fullname in (select distinct x.leaf_node from wt_trial_nodes x)
	   or c_fullname in (select distinct x.c_fullname
						 from i2b2 x
							 ,wt_trial_nodes t
						 where t.leaf_node like x.c_fullname || '%'
						   and x.c_fullname != t.leaf_node
						   and x.c_visualattributes not like 'F%');
	--where c_fullname like '%' || topNode || '%';
  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Initialize data_type and xml in i2b2',SQL%ROWCOUNT,stepCt,'Done');
	commit;
	
	update i2b2
	SET c_columndatatype = 'N',
      --Static XML String
		c_metadataxml = '<?xml version="1.0"?><ValueMetadata><Version>3.02</Version><CreationDateTime>08/14/2008 01:22:59</CreationDateTime><TestID></TestID><TestName></TestName><DataType>PosFloat</DataType><CodeType></CodeType><Loinc></Loinc><Flagstouse></Flagstouse><Oktousevalues>Y</Oktousevalues><MaxStringLength></MaxStringLength><LowofLowValue>0</LowofLowValue><HighofLowValue>0</HighofLowValue><LowofHighValue>100</LowofHighValue>100<HighofHighValue>100</HighofHighValue><LowofToxicValue></LowofToxicValue><HighofToxicValue></HighofToxicValue><EnumValues></EnumValues><CommentsDeterminingExclusion><Com></Com></CommentsDeterminingExclusion><UnitValues><NormalUnits>ratio</NormalUnits><EqualUnits></EqualUnits><ExcludingUnits></ExcludingUnits><ConvertingUnits><Units></Units><MultiplyingFactor></MultiplyingFactor></ConvertingUnits></UnitValues><Analysis><Enums /><Counts /><New /></Analysis></ValueMetadata>'
	where c_basecode IN (
		  select xf.concept_cd
		  from observation_fact xf
			  ,concept_dimension xd
		  where xf.concept_cd = xd.concept_cd
		    and xd.concept_path in (select distinct x.leaf_node from wt_trial_nodes x)
		  having Max(xf.valtype_cd) = 'N'
		  group by xf.concept_Cd
		  )
      and c_fullname in (select distinct y.leaf_node from wt_trial_nodes y);
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Update c_columndatatype and c_metadataxml for numeric data types in I2B2METADATA i2b2',SQL%ROWCOUNT,stepCt,'Done');
	commit;
  
	--UPDATE VISUAL ATTRIBUTES for Leaf Active (Default is folder)
	update i2b2 a
    set c_visualattributes = 'LA'
    where 1 = (
      select count(*)
      from i2b2 b
      where b.c_fullname like (a.c_fullname || '%'))
      and a.c_fullname in (select distinct x.leaf_node from wt_trial_nodes x);
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Update visual attributes for leaf nodes in I2B2METADATA i2b2',SQL%ROWCOUNT,stepCt,'Done');
  
	COMMIT;
	
	--	update c_visualattribute to J for topNode if highlight_study=Y

	update i2b2 b
	set c_visualattributes=substr(b.c_visualattributes,1,2) || decode(highlight_study,'Y','J',null)
	where c_fullname = topNode;
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Update visual attributes for top node in I2B2METADATA i2b2',SQL%ROWCOUNT,stepCt,'Done');
  
	COMMIT;
	/*
	--Set c_basecode = null where type is a folder.
	--Basecode is not needed since no records exist on the Observation Fact for Folders.
	update i2b2 
    set c_basecode = ''
    where c_visualattributes = 'FA'
	  and c_fullname like '%' || TrialID || '%';
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set c_basecode to null for folders in I2B2METADATA i2b2',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
*/
	
/*	part of i2b2_create_security_for_trial

	--	insert patients to patient_trial table
	
	delete from patient_trial
	where trial  = TrialID;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete data for trial from I2B2DEMODATA patient_trial',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
  
	insert into i2b2demodata.patient_trial
	(patient_num
	,trial
	,secure_obj_token
	)
	select patient_num, 
		   TrialID,
		   decode(secureStudy,'Y','EXP:' || TrialID,'EXP:PUBLIC')
	from patient_dimension
	where sourcesystem_cd like TrialID || '%';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert data for trial into I2B2DEMODATA patient_trial',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
*/  
	-- final procs
  
	i2b2_fill_in_tree(TrialId, topNode, jobID);
	
	--	set sourcesystem_cd, c_comment to null if any added upper-level nodes
		
	update i2b2 b
	set sourcesystem_cd=null,c_comment=null
	where b.sourcesystem_cd = TrialId
	  and length(b.c_fullname) < length(topNode);
	  
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Set sourcesystem_cd to null for added upper-level nodes',SQL%ROWCOUNT,stepCt,'Done');
	commit;
	
	i2b2_create_concept_counts(topNode, jobID);
	
	--	delete each node that is hidden after create concept counts
	
	 FOR r_delNodes in delNodes Loop

    --	deletes hidden nodes for a trial one at a time

		i2b2_delete_1_node(r_delNodes.c_fullname);
		stepCt := stepCt + 1;
		tText := 'Deleted node: ' || r_delNodes.c_fullname;
		
		cz_write_audit(jobId,databaseName,procedureName,tText,SQL%ROWCOUNT,stepCt,'Done');

	END LOOP;  	

	i2b2_create_security_for_trial(TrialId, secureStudy, jobID);
	i2b2_load_security_data(jobID);
	
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'End i2b2_load_clinical_data',0,stepCt,'Done');
	

  
    ---Cleanup OVERALL JOB if this proc is being run standalone
	if newJobFlag = 1
	then
		cz_end_audit (jobID, 'SUCCESS');
	end if;

	rtnCode := 0;
  
	exception
	when duplicate_values then
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Duplicate values found in key columns',0,stepCt,'Done');	
		cz_error_handler (jobID, procedureName);
		cz_end_audit (jobID, 'FAIL');
		rtnCode := 16;		
	when invalid_topNode then
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Path specified in top_node must contain at least 2 nodes',0,stepCt,'Done');	
		cz_error_handler (jobID, procedureName);
		cz_end_audit (jobID, 'FAIL');
		rtnCode := 16;	
	when multiple_visit_names then
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Multiple visit_names exist for category/label/value',0,stepCt,'Done');	
		cz_error_handler (jobID, procedureName);
		cz_end_audit (jobID, 'FAIL');
		rtnCode := 16;
	when others then
    --Handle errors.
		cz_error_handler (jobID, procedureName);
    --End Proc
		cz_end_audit (jobID, 'FAIL');
		rtnCode := 16;
	
end;

 /*
  --PERIOD
  update wrk_clinical_data a
    set a.period = 
      (select replace(Upper(a.period), b.node_name, b.display_name)
        from node_curation b
      where b.node_type = 'PERIOD'
        and upper(a.period) = b.node_name  
        and active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'PERIOD'
        and upper(a.period) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for PERIOD',SQL%ROWCOUNT,stepCt,'Done');
  COMMIT;

  --SAMPLE_TYPE
  update wrk_clinical_data a
    set a.sample_type = 
      (select replace(Upper(a.sample_type), b.node_name, b.display_name)
        from node_curation b
      where b.node_type = 'SAMPLE_TYPE'
        and upper(a.sample_type) = b.node_name  
        and active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'SAMPLE_TYPE'
        and upper(a.sample_type) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for SAMPLE_TYPE',SQL%ROWCOUNT,stepCt,'Done');
  COMMIT;
 

  --CATEGORY_PATH
  update category a
    set a.category_path = 
      (select b.display_name
        from node_curation b
      where b.node_type = 'CATEGORY_PATH'
        and upper(a.category_path) = b.node_name  
        and active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'CATEGORY_PATH'
        and upper(a.category_path) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for CATEGORY_PATH',SQL%ROWCOUNT,stepCt,'Done');
  COMMIT; 
  
  --SUPPRESS VALUES BASED ON VISIT_NAME
  
  update wrk_clinical_data a
    set suppress_flag = 
      (select decode(b.display_in_ui,'N','Y',a.suppress_flag)
        from node_curation b
        where b.node_type = 'VISIT_NAME'
          and upper(a.visit_name) = b.node_name  
          and b.active_flag = 'Y'
          and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		  and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'VISIT_NAME'
        and upper(a.visit_name) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Suppress VISIT_NAME',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;

  --SUPPRESS VALUES BASED ON DATA_LABEL
  update wrk_clinical_data a
    set suppress_flag = 
      (select decode(b.display_in_ui,'N','Y',a.suppress_flag)
        from node_curation b
        where b.node_type = 'DATA_LABEL'
          and upper(a.visit_name) = b.node_name  
          and b.active_flag = 'Y'
          and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		  and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'DATA_LABEL'
        and upper(a.visit_name) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Suppress DATA_LABEL',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;

  --SUPPRESS VALUES BASED ON DATA_VALUE
  update wrk_clinical_data a
    set suppress_flag = 
      (select decode(b.display_in_ui,'N','Y',a.suppress_flag)
        from node_curation b
        where b.node_type = 'DATA_VALUE'
          and upper(a.visit_name) = b.node_name  
          and b.active_flag = 'Y'
          and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		  and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'DATA_VALUE'
        and upper(a.visit_name) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Suppress DATA_VALUE',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;
 
  --SUPPRESS VALUES BASED ON PERIOD
   update wrk_clinical_data a
    set suppress_flag = 
      (select decode(b.display_in_ui,'N','Y',a.suppress_flag)
        from node_curation b
        where b.node_type = 'PERIOD'
          and upper(a.visit_name) = b.node_name  
          and b.active_flag = 'Y'
          and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		  and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'PERIOD'
        and upper(a.visit_name) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Suppress PERIOD',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;
  

  --VISIT_NAME
  update wrk_clinical_data a
    set a.visit_name = 
      (select replace(Upper(a.visit_name), b.node_name, b.display_name)
        from node_curation b
        where b.node_type = 'VISIT_NAME'
          and upper(a.visit_name) = b.node_name  
          and b.active_flag = 'Y'
          and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		  and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
      )
    where exists
    (select 1 
      from node_curation b 
      where b.node_type = 'VISIT_NAME'
        and upper(a.visit_name) = b.node_name  
        and b.active_flag = 'Y'
        and (b.global_flag = 'Y' OR b.study_id = a.study_id)
		and b.global_flag =
			 (select min(x.global_flag) from node_curation x
			  where b.node_type = x.node_type
                and b.node_name = x.node_name
                and (x.global_flag = 'Y' or a.study_id = x.study_id)
             )
    );
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Node curation for VISIT_NAME',SQL%ROWCOUNT,stepCt,'Done');
	
  COMMIT;
*/

/

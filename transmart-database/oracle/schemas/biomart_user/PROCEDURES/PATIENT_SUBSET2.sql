--------------------------------------------------------
--  DDL for Procedure PATIENT_SUBSET2
--------------------------------------------------------

  CREATE OR REPLACE PROCEDURE "BIOMART_USER"."PATIENT_SUBSET2" (
  p_result_instance_id IN VARCHAR2,
  p_pathway IN VARCHAR2,
  p_refcur  OUT SYS_REFCURSOR) AS
  
  v_patients patients_tab;
  v_concept_cd concept_cd_tab;

BEGIN

SELECT patient_num BULK COLLECT INTO v_patients FROM (SELECT  
             DISTINCT a.patient_num
        FROM qt_patient_set_collection a, 
             qt_query_result_instance b, 
             qt_query_instance c, 
             qt_query_master d 
        WHERE a.result_instance_id = b.result_instance_id AND 
              b.query_instance_id = c.query_instance_id AND 
              c.query_master_id = d.query_master_id AND 
              b.result_instance_id = p_result_instance_id);
    
FOR record IN (SELECT SUBSTR(item_key,INSTR(item_key,'\',1,3)) AS concept_path  FROM (  
      SELECT extractValue(value(ik),'/item_key') item_key FROM (SELECT sys.xmltype.createXML(a.i2b2_request_xml) col 
        FROM qt_query_master a, 
             qt_query_instance b, 
             qt_query_result_instance c 
        WHERE a.query_master_id = b.query_master_id AND
              b.query_instance_id = c.query_instance_id AND 
              c.result_instance_id = p_result_instance_id) tab1,
              TABLE(xmlsequence(extract(col,'//ns4:request/query_definition/panel/item/item_key',                        
                                            'xmlns:ns4="http://www.i2b2.org/xsd/cell/crc/psm/1.1/"'))) ik))
LOOP                                            
   SELECT concept_cd BULK COLLECT INTO v_concept_cd FROM concept_dimension 
        WHERE concept_path like record.concept_path||'%';
END LOOP;
 
 
 FOR record IN (SELECT * FROM TABLE(CAST(v_concept_cd AS concept_cd_tab)))
 LOOP
 DBMS_OUTPUT.PUT_LINE(record.column_value);
 END LOOP;
 
OPEN p_refcur FOR
  SELECT DISTINCT a.probeset, a.gene_symbol, a.refseq, a.zscore, a.pvalue, b.patient_uid, a.assay_id
      FROM de_subject_assay_data a
      JOIN de_subject_sample_mapping b
        ON a.patient_id = b.patient_id
      JOIN de_pathway_gene c
        ON a.gene_symbol = c.gene_symbol
      JOIN de_pathway d
        ON d.id = c.pathway_id
      WHERE d.name = p_pathway
        AND b.patient_uid IN (SELECT * FROM TABLE(CAST(v_patients as patients_tab)))
        AND b.concept_code IN (CASE WHEN ( SELECT COUNT(*) FROM de_subject_sample_mapping 
                                       WHERE concept_code IN (SELECT * FROM TABLE(CAST(v_concept_cd AS concept_cd_tab)))) > 0 THEN
                                         (SELECT * FROM TABLE(CAST(v_concept_cd AS concept_cd_tab)))
                                       ELSE
                                         (SELECT concept_code FROM de_subject_sample_mapping)
                                      END);
                                         
END PATIENT_SUBSET2;

 
 
 
 
 



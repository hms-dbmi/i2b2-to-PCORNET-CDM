/usr/bin/time -v sqlplus -s biomart_user/dwtst@BCH_DWTST<<EOF

INSERT INTO I2B2METADATA.I2B2
SELECT DISTINCT C_HLEVEL+2,
'\\Under Development\\cTAKES\\SNOMED' || C_FULLNAME,
C_NAME,
C_SYNONYM_CD,
C_VISUALATTRIBUTES,
0,
I2B2_SNOMED.C_BASECODE,
null,
C_FACTTABLECOLUMN,
C_TABLENAME,
C_COLUMNNAME,
C_COLUMNDATATYPE,
C_OPERATOR,
C_DIMCODE,
'SNOMED',
C_TOOLTIP,
SYSDATE,
null,
null,
SOURCESYSTEM_CD,
null,
null,
M_APPLIED_PATH,
null,
C_PATH,
C_SYMBOL
FROM  "TM_LZ"."I2B2_SNOMED" INNER JOIN TRIMMED_CONCEPTS ON TRIMMED_CONCEPTS.C_BASECODE = TM_LZ.I2B2_SNOMED.C_BASECODE;


exit;
EOF

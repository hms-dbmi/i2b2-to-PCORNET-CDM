--------------------------------------------------------
--  File created - Wednesday-December-10-2014   
--------------------------------------------------------
 I2B2DEMODATA.QT_PRIVILEGE

Insert into I2B2DEMODATA.QT_PRIVILEGE (PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD,PLUGIN_ID) values ('PDO_WITHOUT_BLOB','DATA_LDS','USER',null);
Insert into I2B2DEMODATA.QT_PRIVILEGE (PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD,PLUGIN_ID) values ('PDO_WITH_BLOB','DATA_DEID','USER',null);
Insert into I2B2DEMODATA.QT_PRIVILEGE (PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD,PLUGIN_ID) values ('SETFINDER_QRY_WITH_DATAOBFSC','DATA_OBFSC','USER',null);
Insert into I2B2DEMODATA.QT_PRIVILEGE (PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD,PLUGIN_ID) values ('SETFINDER_QRY_WITHOUT_DATAOBFSC','DATA_AGG','USER',null);
Insert into I2B2DEMODATA.QT_PRIVILEGE (PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD,PLUGIN_ID) values ('UPLOAD','DATA_OBFSC','MANAGER',null);
exit;

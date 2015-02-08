--------------------------------------------------------
--  File created - Wednesday-December-10-2014   
--------------------------------------------------------

Insert into I2B2HIVE.CRC_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','/Demo/','@','i2b2demodata','java:QueryToolDemoDS','ORACLE','Demo',null,null,null,null);
Insert into I2B2HIVE.CRC_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','/Demo2/','@','i2b2demodata2','java:QueryToolDemo2DS','ORACLE','Demo2',null,null,null,null);
Insert into I2B2HIVE.CRC_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','/sample/','@','i2b2demodata','java:QueryToolDemoDS','ORACLE','Sample',null,null,null,null);

Insert into I2B2HIVE.HILOSEQUENCES (SEQUENCENAME,HIGHVALUES) values ('general',0);

Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('durpublisher','dynsub');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('publisher','dynsub');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('guest','guest');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('j2ee','guest');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('john','guest');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('durpublisher','john');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('publisher','john');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('subscriber','john');
Insert into I2B2HIVE.JMS_ROLES (ROLEID,USERID) values ('noacc','nobody');

Insert into I2B2HIVE.JMS_USERS (USERID,PASSWD,CLIENTID) values ('dynsub','dynsub',null);
Insert into I2B2HIVE.JMS_USERS (USERID,PASSWD,CLIENTID) values ('nobody','nobody',null);
Insert into I2B2HIVE.JMS_USERS (USERID,PASSWD,CLIENTID) values ('john','needle','DurableSubscriberExample');
Insert into I2B2HIVE.JMS_USERS (USERID,PASSWD,CLIENTID) values ('j2ee','j2ee',null);
Insert into I2B2HIVE.JMS_USERS (USERID,PASSWD,CLIENTID) values ('guest','guest',null);

Insert into I2B2HIVE.ONT_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','Demo/','@','i2b2metadata','java:OntologyDemoDS','ORACLE','Metadata',null,null,null,null);
Insert into I2B2HIVE.ONT_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','Demo2/','@','i2b2metadata2','java:OntologyDemo2DS','ORACLE','Metadata2',null,null,null,null);
Insert into I2B2HIVE.ONT_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','sample/','@','i2b2sampledata','java:OntologySampleDS','ORACLE','SampleMetadata',null,null,null,null);

Insert into I2B2HIVE.TIMERS (TIMERID,TARGETID,INITIALDATE,TIMERINTERVAL) values ('1417642250491','[target=jboss.j2ee:service=EJB3,ear=QP1.ear,jar=QP-An-EJB.jar,name=LargeCronEjb]',to_timestamp('03-DEC-14 10.31.59.592000000 PM','DD-MON-RR HH.MI.SS.FF AM'),60000);
Insert into I2B2HIVE.TIMERS (TIMERID,TARGETID,INITIALDATE,TIMERINTERVAL) values ('1417642250490','[target=jboss.j2ee:service=EJB3,ear=QP1.ear,jar=QP-An-EJB.jar,name=CronEjb]',to_timestamp('03-DEC-14 10.31.59.563000000 PM','DD-MON-RR HH.MI.SS.FF AM'),60000);

Insert into I2B2HIVE.WORK_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','Demo/','@','i2b2workdata','java:WorkplaceDemoDS','ORACLE','Workplace',null,null,null,null);
Insert into I2B2HIVE.WORK_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2demo','Demo2/','@','i2b2workdata2','java:WorkplaceDemo2DS','ORACLE','Workplace2',null,null,null,null);
Insert into I2B2HIVE.WORK_DB_LOOKUP (C_DOMAIN_ID,C_PROJECT_PATH,C_OWNER_ID,C_DB_FULLSCHEMA,C_DB_DATASOURCE,C_DB_SERVERTYPE,C_DB_NICENAME,C_DB_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('i2b2sample','sample/','@','i2b2sampledata','java:WorkplaceSampleDS','ORACLE','Sample',null,null,null,null);

Insert into I2B2PM.PM_CELL_DATA (CELL_ID,PROJECT_PATH,NAME,METHOD_CD,URL,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('CRC','/','Data Repository','REST','http://localhost:9090/i2b2/rest/QueryToolService/',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_CELL_DATA (CELL_ID,PROJECT_PATH,NAME,METHOD_CD,URL,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('ONT','/','Ontology Cell','REST','http://localhost:9090/i2b2/rest/OntologyService/',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_CELL_DATA (CELL_ID,PROJECT_PATH,NAME,METHOD_CD,URL,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('WORK','/','Workplace Cell','REST','http://localhost:9090/i2b2/rest/WorkplaceService/',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_CELL_DATA (CELL_ID,PROJECT_PATH,NAME,METHOD_CD,URL,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('FRC','/','File Repository ','SOAP','http://localhost:9090/i2b2/services/FRService/',1,null,null,null,'A');

Insert into I2B2PM.PM_CELL_PARAMS (ID,DATATYPE_CD,CELL_ID,PROJECT_PATH,PARAM_NAME_CD,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values (1,'T','ONT','/','OntSynonyms',1,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_CELL_PARAMS (ID,DATATYPE_CD,CELL_ID,PROJECT_PATH,PARAM_NAME_CD,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values (2,'T','ONT','/','OntHiddens',1,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_CELL_PARAMS (ID,DATATYPE_CD,CELL_ID,PROJECT_PATH,PARAM_NAME_CD,CAN_OVERRIDE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values (3,'T','ONT','/','OntMax',1,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');


Insert into I2B2PM.PM_HIVE_DATA (DOMAIN_ID,HELPURL,DOMAIN_NAME,ENVIRONMENT_CD,ACTIVE,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('hive','www.i2b2.org','i2b2demo','DEVELOPMENT',1,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');

Insert into I2B2PM.PM_PROJECT_DATA (PROJECT_ID,PROJECT_NAME,PROJECT_WIKI,PROJECT_KEY,PROJECT_PATH,PROJECT_DESCRIPTION,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','http://www.i2b2.org',null,null,null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');

Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','root','ADMIN',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','root','MANAGER',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','root','USER',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','root','DATA_OBFSC',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','OBFSC_SERVICE_ACCOUNT','USER',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','OBFSC_SERVICE_ACCOUNT','DATA_OBFSC',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','ADMIN',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','MANAGER',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','DATA_OBFSC',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','AGG_SERVICE_ACCOUNT','USER',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','AGG_SERVICE_ACCOUNT','DATA_OBFSC',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','AGG_SERVICE_ACCOUNT','DATA_AGG',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','DATA_DEID',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','DATA_OBFSC',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','DATA_AGG',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','DATA_LDS',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','EDITOR',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','DATA_AGG',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','DATA_DEID',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','DATA_LDS',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','USER',null,null,null,'A');
Insert into I2B2PM.PM_PROJECT_USER_ROLES (PROJECT_ID,USER_ID,USER_ROLE_CD,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','Demo','USER',null,null,null,'A');

Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_HIVE_DATA','@','@','ADMIN',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_HIVE_PARAMS','@','@','ADMIN',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_PROJECT_DATA','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_PROJECT_USER_ROLES','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_USER_DATA','@','@','ADMIN',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_PROJECT_PARAMS','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_PROJECT_USER_PARAMS','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_USER_PARAMS','@','@','ADMIN',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_CELL_DATA','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_CELL_PARAMS','@','@','MANAGER',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_ROLE_REQUIREMENT (TABLE_CD,COLUMN_CD,READ_HIVEMGMT_CD,WRITE_HIVEMGMT_CD,NAME_CHAR,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('PM_GLOBAL_PARAMS','@','@','ADMIN',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');

Insert into I2B2PM.PM_USER_DATA (USER_ID,FULL_NAME,PASSWORD,EMAIL,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('root','i2b2 root','1d258c244a8d19e716292b231e3190','root@recomdata.com',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_USER_DATA (USER_ID,FULL_NAME,PASSWORD,EMAIL,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('Demo','demo','9117d59a69dc49807671a51f10ab7f','demo@recomdata.com',to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_USER_DATA (USER_ID,FULL_NAME,PASSWORD,EMAIL,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('OBFSC_SERVICE_ACCOUNT','OBFSC_SERVICE_ACCOUNT','9117d59a69dc49807671a51f10ab7f',null,to_date('28-FEB-12','DD-MON-RR'),to_date('28-FEB-12','DD-MON-RR'),'Upgrade From 1.3','A');
Insert into I2B2PM.PM_USER_DATA (USER_ID,FULL_NAME,PASSWORD,EMAIL,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('demo','i2b2 User','9117d59a69dc49807671a51f10ab7f',null,null,null,null,'A');
Insert into I2B2PM.PM_USER_DATA (USER_ID,FULL_NAME,PASSWORD,EMAIL,CHANGE_DATE,ENTRY_DATE,CHANGEBY_CHAR,STATUS_CD) values ('AGG_SERVICE_ACCOUNT','AGG_SERVICE_ACCOUNT','9117d59a69dc49807671a51f10ab7f',null,null,null,null,'A');


Insert into I2B2WORKDATA.WORKPLACE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_NAME,C_USER_ID,C_GROUP_ID,C_SHARE_ID,C_INDEX,C_PARENT_INDEX,C_VISUALATTRIBUTES,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('demo','WORKPLACE','N',0,'root','root','Demo','N','z5edP6Me8mVnK01M5fFl',null,'CA ',null,to_date('23-FEB-09','DD-MON-RR'),null,null);
Insert into I2B2WORKDATA.WORKPLACE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_NAME,C_USER_ID,C_GROUP_ID,C_SHARE_ID,C_INDEX,C_PARENT_INDEX,C_VISUALATTRIBUTES,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('demo','WORKPLACE','N',0,'SHARED','shared','demo','Y','100',null,'CA ','SHARED',null,null,null);
Insert into I2B2WORKDATA.WORKPLACE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_NAME,C_USER_ID,C_GROUP_ID,C_SHARE_ID,C_INDEX,C_PARENT_INDEX,C_VISUALATTRIBUTES,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('demo','WORKPLACE','N',0,'@','@','@','N','0',null,'CA ','@',null,null,null);
Insert into I2B2WORKDATA.WORKPLACE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_NAME,C_USER_ID,C_GROUP_ID,C_SHARE_ID,C_INDEX,C_PARENT_INDEX,C_VISUALATTRIBUTES,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('demo','WORKPLACE','N',0,'xia','xia','Demo','N','nGYHmF59FdV7NSy88ykz',null,'CA ',null,to_date('10-FEB-09','DD-MON-RR'),null,null);
Insert into I2B2WORKDATA.WORKPLACE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_NAME,C_USER_ID,C_GROUP_ID,C_SHARE_ID,C_INDEX,C_PARENT_INDEX,C_VISUALATTRIBUTES,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD) values ('demo','WORKPLACE','N',0,'Demo','Demo','Demo','N','UthCgeBvy9FhEG4Ukhpr',null,'CA ',null,to_date('24-FEB-09','DD-MON-RR'),null,null);

Insert into I2B2METADATA.TABLE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_FACTTABLECOLUMN,C_DIMTABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD,VALUETYPE_CD) values ('Public Studies','i2b2','N',0,'\Public Studies\','Public Studies','N','CA ',0,'NULL','concept_cd','concept_dimension','concept_path','T','LIKE','\Public Studies\','\Public Studies\',null,null,'A',null);
Insert into I2B2METADATA.TABLE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_FACTTABLECOLUMN,C_DIMTABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD,VALUETYPE_CD) values ('HEGP','i2b2','N',0,'\HEGP\','HEGP','N','CA ',null,null,'concept_cd','concept_dimension','concept_path','T','LIKE','\HEGP\','\HEGP\',to_date('04-MAY-13','DD-MON-RR'),null,null,null);
Insert into I2B2METADATA.TABLE_ACCESS (C_TABLE_CD,C_TABLE_NAME,C_PROTECTED_ACCESS,C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_FACTTABLECOLUMN,C_DIMTABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_TOOLTIP,C_ENTRY_DATE,C_CHANGE_DATE,C_STATUS_CD,VALUETYPE_CD) values ('PMS_DN','i2b2','N',0,'\PMS_DN\','PMS_DN','N','CA ',0,null,'concept_cd','concept_dimension','concept_path','T','LIKE','\PMS_DN\','\PMS_DN\',to_date('19-SEP-14','DD-MON-RR'),null,null,null);

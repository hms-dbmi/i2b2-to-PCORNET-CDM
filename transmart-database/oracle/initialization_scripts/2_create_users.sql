
CREATE USER BIOMART_USER IDENTIFIED BY BIOMART_USER DEFAULT TABLESPACE BIOMART;
CREATE USER BIOMART IDENTIFIED BY BIOMART DEFAULT TABLESPACE BIOMART;
CREATE USER I2B2PM IDENTIFIED BY I2B2PM DEFAULT TABLESPACE I2B2_DATA;
CREATE USER I2B2HIVE IDENTIFIED BY I2B2HIVE DEFAULT TABLESPACE I2B2_DATA;
CREATE USER I2B2METADATA IDENTIFIED BY I2B2METADATA DEFAULT TABLESPACE I2B2_DATA;
CREATE USER I2B2WORKDATA IDENTIFIED BY I2B2WORKDATA DEFAULT TABLESPACE TRANSMART;
CREATE USER I2B2SAMPLEDATA IDENTIFIED BY I2B2SAMPLEDATA DEFAULT TABLESPACE TRANSMART;
CREATE USER I2B2DEMODATA IDENTIFIED BY I2B2DEMODATA DEFAULT TABLESPACE TRANSMART;
CREATE USER SEARCHAPP IDENTIFIED BY SEARCHAPP DEFAULT TABLESPACE BIOMART;
CREATE USER DEAPP IDENTIFIED BY DEAPP DEFAULT TABLESPACE DEAPP;
CREATE USER TM_LZ IDENTIFIED BY TM_LZ DEFAULT TABLESPACE TRANSMART;
CREATE USER TM_CZ IDENTIFIED BY TM_CZ DEFAULT TABLESPACE TRANSMART;
CREATE USER TM_WZ IDENTIFIED BY TM_WZ DEFAULT TABLESPACE TRANSMART;

ALTER USER BIOMART QUOTA 1000M ON BIOMART;
ALTER USER BIOMART QUOTA 1000M ON INDX;
ALTER USER SEARCHAPP QUOTA 1000M ON BIOMART;
ALTER USER BIOMART_USER QUOTA 1000M ON BIOMART;
ALTER USER TM_LZ QUOTA 1000M ON TRANSMART;
ALTER USER TM_CZ QUOTA 1000M ON TRANSMART;
ALTER USER TM_WZ QUOTA 1000M ON TRANSMART;
ALTER USER I2B2PM QUOTA 1000M ON I2B2_DATA;
ALTER USER I2B2SAMPLEDATA QUOTA 1000M ON I2B2_DATA;
ALTER USER I2B2METADATA QUOTA 1000M ON I2B2_DATA;
ALTER USER I2B2HIVE QUOTA 1000M ON I2B2_DATA;
ALTER USER I2B2DEMODATA QUOTA 1000M ON I2B2_DATA;
ALTER USER I2B2WORKDATA QUOTA 1000M ON I2B2_DATA;
ALTER USER DEAPP QUOTA 1000M ON DEAPP;
ALTER USER DEAPP QUOTA 1000M ON INDX;
ALTER USER DEAPP QUOTA 1000M ON TRANSMART;
ALTER USER TM_LZ QUOTA 1000M ON INDX;
ALTER USER TM_CZ QUOTA 1000M ON INDX;
ALTER USER TM_WZ QUOTA 1000M ON INDX;

GRANT SELECT ANY TABLE, DELETE ANY TABLE, UPDATE ANY TABLE, INSERT ANY TABLE TO BIOMART_USER;
GRANT SELECT ANY TABLE, DELETE ANY TABLE, UPDATE ANY TABLE, INSERT ANY TABLE TO TM_CZ;
GRANT SELECT ANY SEQUENCE TO TM_CZ;
GRANT SELECT ANY SEQUENCE TO BIOMART_USER;
GRANT DROP ANY TABLE TO TM_CZ;
GRANT ANALYZE ANY TO TM_CZ;
GRANT ALTER ANY INDEX TO TM_CZ;

ALTER USER I2B2DEMODATA QUOTA UNLIMITED ON TRANSMART;
ALTER USER I2B2WORKDATA QUOTA UNLIMITED ON TRANSMART;
ALTER USER BIOMART_USER QUOTA UNLIMITED ON TRANSMART;

GRANT CREATE SESSION TO BIOMART_USER;
GRANT CREATE SESSION TO TM_CZ;
GRANT CREATE SESSION TO TM_LZ;
GRANT CREATE SESSION TO I2B2DEMODATA;
GRANT CREATE SESSION TO I2B2METADATA;
GRANT CREATE SESSION TO I2B2PM;
GRANT CREATE SESSION TO I2B2HIVE;
GRANT CREATE SESSION TO I2B2SAMPLEDATA;
GRANT CREATE SESSION TO I2B2WORKDATA;


exit;

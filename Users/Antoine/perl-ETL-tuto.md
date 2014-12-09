## ETL perl scripts

### create directory structure

	+ control_files  
	+ data  
		+ i2b2_load_tables
		+ source
	+ log_files  
	+ mapping_files  
	+ scripts 
	(+ raw)
	(+ working)

### create mapping from directory

the corresponding perl script can be found at: 

		perl-ETL/scripts/creatingMapping/create_column_mapping_from_directory.pl
		
		
the script takes 2 arguments: 

	- source directory
	- top level node
	
Data files must be in tab separated format, and have a '.txt' extension. You can use the script 'scripts/csv2tsv.sh' to parse csv files to tsv 

you can specify 2 optional files: 

- columns.omit: contains the list of columns to omit in **ALL** the files (one column header per line)
- special columns: contains the references of special columns in **ALL** the files (Column Header \t SpecialName)


### set environment variables
oracle database connection via DBI package requires 2 environment variables: (on transmartdev2)

	ORACLE_HOME=/app/oracle/product/11.2.0/client_1
	LD_LIBRARY_PATH=/app/oracle/product/11.2.0/client_1/lib
	
### run main
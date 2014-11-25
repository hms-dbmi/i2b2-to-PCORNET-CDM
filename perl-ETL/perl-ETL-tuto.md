## ETL perl scripts

### create mapping from directory

the corresponding perl script can be found at: 

		perl-ETL/scripts/creatingMapping/create_column_mapping_from_directory.pl
		
the script takes 2 arguments: 

	- source directory
	- top level node
	
you can specify 2 optional files: 

- columns.omit: contains the list of columns to omit in **ALL** the files (one column per line)
- special columns: contains the references of special columns in **ALL** the files (NumberOf the column \t NameOfTheColumn)

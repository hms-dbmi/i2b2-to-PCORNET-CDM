--------------------------------------------------------
--  DDL for Procedure CREATE_FILE_FROM_QUERY
--------------------------------------------------------

  CREATE OR REPLACE PROCEDURE "BIOMART_USER"."CREATE_FILE_FROM_QUERY" ( p_query in varchar2,
                                  p_dir   in varchar2,
                                  p_filename in varchar2 )
IS
     l_output        utl_file.file_type;
     l_theCursor     INTEGER DEFAULT dbms_sql.open_cursor;
     l_columnValue   VARCHAR2(4000);
     l_status        INTEGER;
     l_query         VARCHAR2(1000);
     l_colCnt        NUMBER := 0;
     l_separator     VARCHAR2(1);
     l_descTbl       dbms_sql.desc_tab2;
BEGIN
     l_output := utl_file.fopen( p_dir, p_filename, 'w', 32767);
     EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';
     
     dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.NATIVE );
     dbms_sql.describe_columns2( l_theCursor, l_colCnt, l_descTbl );
     for i in 1 .. l_colCnt loop
         utl_file.put( l_output, l_separator || '"' || l_descTbl(i).col_name|| '"' );
         dbms_output.put_line('Column Type :: ' || l_descTbl(i).col_type);
         --col_type = 112 : 112 is the # for CLOB data-type
         IF (l_desctbl(i).col_type = 112) THEN
            dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000000000);
         else
            dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
         END IF;
         l_separator := ',';
     end loop;
     utl_file.new_line( l_output );
     l_status := dbms_sql.execute(l_theCursor);
     while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
         l_separator := '';
         FOR i IN 1 .. l_colCnt loop
             dbms_sql.column_value( l_theCursor, i, l_columnValue );
             IF (l_desctbl(i).col_type = 112) THEN
                l_columnValue := rtrim(rtrim(dbms_lob.substr(replace(l_columnValue,'"','""'))));
             END IF;
             utl_file.put( l_output, l_separator || l_columnValue );
             l_separator := ',';
         end loop;
         utl_file.new_line( l_output );
     end loop;
     dbms_sql.close_cursor(l_theCursor);
     utl_file.fclose( l_output );
     execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
exception
    when utl_file.invalid_path then
       raise_application_error(-20100,'Invalid Path');
    when utl_file.invalid_mode then
       raise_application_error(-20101,'Invalid Mode');
    when utl_file.invalid_operation then
       raise_application_error(-20102,'Invalid Operation');
    when utl_file.invalid_filehandle then
       raise_application_error(-20103,'Invalid FileHandle');
    when utl_file.write_error then
       raise_application_error(-20104,'Write Error');
    when utl_file.read_error then
       raise_application_error(-20105,'Read Error');
    when utl_file.internal_error then
       raise_application_error(-20106,'Internal Error');
    when others then
         utl_file.fclose( l_output );
         execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
         raise;
end;


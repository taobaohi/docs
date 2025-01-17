-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- stored procedure to generate csharp model class
-- CALL `dietplandb`.`GenCSharpModel`('<<table name>>');
-- written by Anupama  http://www.code4copy.com
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenCSharpModel`(in pTableName VARCHAR(255) )
BEGIN
DECLARE vClassName varchar(255);
declare vClassCode mediumtext;
declare v_codeChunk varchar(1024);
DECLARE v_finished INTEGER DEFAULT 0;
DEClARE code_cursor CURSOR FOR 
    SELECT code FROM temp1; 

DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET v_finished = 1;

set vClassCode ='';
/* Make class name*/
	SELECT (CASE WHEN col1 = col2 THEN col1 ELSE concat(col1,col2)  END) into vClassName
	FROM(
	SELECT CONCAT(UCASE(MID(ColumnName1,1,1)),LCASE(MID(ColumnName1,2))) as col1,
	CONCAT(UCASE(MID(ColumnName2,1,1)),LCASE(MID(ColumnName2,2))) as col2
	FROM
	(SELECT SUBSTRING_INDEX(pTableName, '_', -1) as ColumnName2,
		SUBSTRING_INDEX(pTableName, '_', 1) as ColumnName1) A) B;

	/*store all properties into temp table*/
	CREATE TEMPORARY TABLE IF NOT EXISTS  temp1 ENGINE=MyISAM  
	as (
	select concat( 'public ', ColumnType , ' ' , FieldName,' { get; set; }') code
	FROM(
	SELECT (CASE WHEN col1 = col2 THEN col1 ELSE concat(col1,col2)  END) AS FieldName, 
	case DATA_TYPE 
            when 'bigint' then 'long'
            when 'binary' then 'byte[]'
            when 'bit' then 'bool'
            when 'char' then 'string'
            when 'date' then 'DateTime'
            when 'datetime' then 'DateTime'
            when 'datetime2' then 'DateTime'
            when 'datetimeoffset' then 'DateTimeOffset'
            when 'decimal' then 'decimal'
            when 'float' then 'float'
            when 'image' then 'byte[]'
            when 'int' then 'int'
            when 'money' then 'decimal'
            when 'nchar' then 'char'
            when 'ntext' then 'string'
            when 'numeric' then 'decimal'
            when 'nvarchar' then 'string'
            when 'real' then 'double'
            when 'smalldatetime' then 'DateTime'
            when 'smallint' then 'short'
			when 'mediumint' then 'INT'
            when 'smallmoney' then 'decimal'
            when 'text' then 'string'
            when 'time' then 'TimeSpan'
            when 'timestamp' then 'DateTime'
            when 'tinyint' then 'byte'
            when 'uniqueidentifier' then 'Guid'
            when 'varbinary' then 'byte[]'
            when 'varchar' then 'string'
			when 'year' THEN 'UINT'
            else 'UNKNOWN_' + DATA_TYPE
        end ColumnType
	FROM(
	select CONCAT(UCASE(MID(ColumnName1,1,1)),LCASE(MID(ColumnName1,2))) as col1,
	CONCAT(UCASE(MID(ColumnName2,1,1)),LCASE(MID(ColumnName2,2))) as col2, DATA_TYPE
	from
	(SELECT SUBSTRING_INDEX(COLUMN_NAME, '_', -1) as ColumnName2,
	SUBSTRING_INDEX(COLUMN_NAME, '_', 1) as ColumnName1,
	DATA_TYPE, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS  WHERE table_name = pTableName) A) B)C);

	set vClassCode = '';
	/* concat all properties*/
	OPEN code_cursor;
 
			get_code: LOOP
		 
				FETCH code_cursor INTO v_codeChunk;
		 
				IF v_finished = 1 THEN 
					LEAVE get_code;
				END IF;
				
				-- build code
				select  CONCAT(vClassCode,'\r\n', v_codeChunk) into  vClassCode ;
		 
			END LOOP get_code;
	 
		CLOSE code_cursor;

drop table temp1;
/*make class*/
select concat('public class ',vClassName,'\r\n{', vClassCode,'\r\n}');
END
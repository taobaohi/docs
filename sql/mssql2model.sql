-- Creating C# model class from SQL query
-- https://community.dynamics.com/365/b/livingintechnology/archive/2019/06/05/sql-script-to-generate-c-model

declare @TableName sysname = 'User'

-- table  MS_Description
declare @TableDescription sql_variant
SELECT @TableDescription=ds.value FROM sys.extended_properties ds  LEFT JOIN sysobjects tbs ON ds.major_id=tbs.id  WHERE  ds.minor_id=0 and tbs.name=@TableName;

declare @Result nvarchar(max) = '
/// <summary>
/// '+CAST(@TableDescription AS nvarchar(255))+'
/// </summary>
public class ' + @TableName + '
{'

select @Result = @Result + '
    /// <summary>c
    /// '+CAST(column_description AS nvarchar(255))+'
    /// </summary>
    public ' + (CASE WHEN ColumnName = 'RowVersion' THEN 'byte[]' ELSE ColumnType END) + NullableSign + ' ' + ColumnName + ' { get; set; }
'
from
(
    select 
        replace(col.name, ' ', '_') ColumnName,
        column_id ColumnId,
        ext.value as column_description,
        case typ.name 
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
            when 'nchar' then 'string'
            when 'ntext' then 'string'
            when 'numeric' then 'decimal'
            when 'nvarchar' then 'string'
            when 'real' then 'double'
            when 'smalldatetime' then 'DateTime'
            when 'smallint' then 'short'
            when 'smallmoney' then 'decimal'
            when 'text' then 'string'
            when 'time' then 'TimeSpan'
            when 'timestamp' then 'timestamp'
            when 'rowversion' then 'byte[]'
            when 'tinyint' then 'byte'
            when 'uniqueidentifier' then 'Guid'
            when 'varbinary' then 'byte[]'
            when 'varchar' then 'string'
            else 'UNKNOWN_' + typ.name
        end ColumnType,
        case 
            when col.is_nullable = 1 and typ.name in ('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier') 
            then '?' 
            else '' 
        end NullableSign
    from sys.columns col
        join sys.types typ on
            col.system_type_id = typ.system_type_id AND col.user_type_id = typ.user_type_id
            LEFT JOIN sys.extended_properties ext ON ext.major_id = col.object_id AND ext.minor_id = col.column_id
    where object_id = object_id(@TableName)
) t
order by ColumnId

set @Result = @Result  + '
}'

print @Result
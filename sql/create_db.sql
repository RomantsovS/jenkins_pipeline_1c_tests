use master
DECLARE @mydb nvarchar(50);
set @mydb = '$(restoreddb)';
if db_id(@mydb) is null
begin
	PRINT N'DB is not exists.';
	declare @sqltext nvarchar(50);
	set @sqltext = 'create database '+@mydb;
	exec(@sqltext)
end
else
	PRINT N'DB already exists.';
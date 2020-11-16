declare @typeFile int = 0; -- for backup files or 1 for report files.
declare @folderPath varchar(max) = N''; --The folder to delete files.
declare @fileExtension varchar(100) = N'bak'; --File extension.
declare @cutOffDate datetime = DATEADD(hour , -12, getdate()); --The cut off date for what files need to be deleted.
declare @subFolder int = 0; --0 to ignore subFolders, 1 to delete files in subFolders.

set @folderPath = '$(folderPath)';

if @folderPath = N''
	RAISERROR ('Error, incorrect path', 11, 1)

declare @cmdpath nvarchar(60)
set @cmdpath = 'MD '+ @folderPath
exec master.dbo.xp_cmdshell @cmdpath

EXECUTE master.dbo.xp_delete_file @typeFile, @folderPath, @fileExtension, @subFolder;
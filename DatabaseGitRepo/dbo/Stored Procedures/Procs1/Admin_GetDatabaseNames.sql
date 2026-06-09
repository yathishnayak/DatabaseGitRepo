CREATE PROCEDURE [dbo].[Admin_GetDatabaseNames]
AS BEGIN
	SELECT [name]	FROM sys.databases
	WHERE			[name] NOT IN ('master','tempdb','model','msdb','distribution') AND [name] not LIKE '%Prev%'
					AND [name] not LIKE '%Repl%' AND [name] not LIKE '%App_Model%' AND [name] not LIKE '%App_Security%'
					AND [name] not LIKE '%Logs%' AND [name] not LIKE '%Maint%' AND [name] not LIKE '%Northwind%'
END
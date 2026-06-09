

CREATE PROCEDURE [dbo].[Admin_GetDBPathandSize]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseFilesJson NVARCHAR(MAX);
    DECLARE @DriveUsageJson NVARCHAR(MAX);
    DECLARE @FinalJson NVARCHAR(MAX);

    -- Query 1: Database File Details
    SET @DatabaseFilesJson = (
        SELECT 
            d.name AS DatabaseName,
            mf.name AS LogicalFileName,
            mf.type_desc AS FileType,
            mf.physical_name AS PhysicalFilePath,
            CAST(mf.size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS SizeGB,
            CASE 
                WHEN mf.is_percent_growth = 1 THEN 
                    CAST(mf.growth AS VARCHAR(10)) + '%'
                ELSE 
                    CAST(mf.growth * 8 / 1024 AS VARCHAR(10)) + ' MB'
            END AS GrowthSetting,
            CASE 
                WHEN mf.max_size = -1 THEN 'Unlimited'
                WHEN mf.max_size = 268435456 THEN '2 TB (Default Max)'
                ELSE CAST(mf.max_size * 8.0 / 1024 / 1024 AS VARCHAR(20)) + ' GB'
            END AS MaxSize
        FROM sys.master_files mf
        JOIN sys.databases d ON mf.database_id = d.database_id
		WHERE d.name not in  ('master','model','tempdb','msdb','Northwind')
        ORDER BY d.name, mf.type_desc
        FOR JSON PATH
    );

    -- Query 2: Drive Usage Summary
    SET @DriveUsageJson = (
        SELECT 
            LEFT(mf.physical_name, 2) AS DriveLetter,
            CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS TotalSizeGB,
            COUNT(*) AS FileCount
        FROM sys.master_files mf
		JOIN sys.databases d ON mf.database_id = d.database_id
		WHERE d.name not in  ('master','model','tempdb','msdb','Northwind')
        GROUP BY LEFT(mf.physical_name, 2)
        ORDER BY LEFT(mf.physical_name, 2) ASC
        FOR JSON PATH
    );

    -- Combine both into final JSON
    SET @FinalJson = 
        '{ "DatabaseFiles": ' + ISNULL(@DatabaseFilesJson, '[]') + ', ' +
        '"DriveUsage": ' + ISNULL(@DriveUsageJson, '[]') + ' }';

    SELECT @FinalJson AS ResultJson;
END;
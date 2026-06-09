

CREATE PROCEDURE Admin_GetDBPathandSize_Delete
AS
BEGIN
    SET NOCOUNT ON;

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
       ORDER BY d.name, mf.type_desc

        SELECT 
            LEFT(mf.physical_name, 2) AS DriveLetter,
            CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS TotalSizeGB,
            COUNT(*) AS FileCount
        FROM sys.master_files mf
        GROUP BY LEFT(mf.physical_name, 2)
        ORDER BY TotalSizeGB DESC

END
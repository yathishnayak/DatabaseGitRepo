


CREATE PROCEDURE [dbo].[DB_GetCompareTables]

AS


 WITH q AS (    
		SELECT			c.TABLE_SCHEMA,
						c.TABLE_NAME,
						c.ORDINAL_POSITION,
						c.COLUMN_NAME,
						c.DATA_TYPE,
						CASE
							WHEN c.DATA_TYPE IN ( N'binary', N'varbinary'                    ) THEN ( CASE c.CHARACTER_OCTET_LENGTH   WHEN -1 THEN N'(max)' ELSE CONCAT( N'(', c.CHARACTER_OCTET_LENGTH  , N')' ) END )
							WHEN c.DATA_TYPE IN ( N'char', N'varchar', N'nchar', N'nvarchar' ) THEN ( CASE c.CHARACTER_MAXIMUM_LENGTH WHEN -1 THEN N'(max)' ELSE CONCAT( N'(', c.CHARACTER_MAXIMUM_LENGTH, N')' ) END )
							WHEN c.DATA_TYPE IN ( N'datetime2', N'datetimeoffset'            ) THEN CONCAT( N'(', c.DATETIME_PRECISION, N')' )
							WHEN c.DATA_TYPE IN ( N'decimal', N'numeric'                     ) THEN CONCAT( N'(', c.NUMERIC_PRECISION , N',', c.NUMERIC_SCALE, N')' )
						END AS DATA_TYPE_PARAMETER,
						CASE c.IS_NULLABLE
							WHEN N'NO'  THEN N' NOT NULL'
							WHEN N'YES' THEN     N' NULL'
						END AS IS_NULLABLE2
		FROM			INFORMATION_SCHEMA.COLUMNS AS c
		WHERE			C.TABLE_NAME NOT LIKE '%syncobj%' AND C.TABLE_NAME NOT LIKE '%MSpeer%' AND C.TABLE_NAME NOT LIKE '%_Base%'
						AND C.TABLE_NAME NOT LIKE '%_Delete%' AND C.TABLE_NAME NOT LIKE '%_Test%' AND C.TABLE_NAME NOT LIKE '%_Praveen%'
						AND C.TABLE_NAME NOT LIKE '%_2024%' AND C.TABLE_NAME NOT LIKE '%PowerBI_%' AND C.TABLE_NAME NOT LIKE '%_Prev%'
	)


	SELECT				q.TABLE_SCHEMA,
						q.TABLE_NAME,
						q.ORDINAL_POSITION,
						q.COLUMN_NAME,
						CONCAT( q.DATA_TYPE, ISNULL( q.DATA_TYPE_PARAMETER, N'' ), q.IS_NULLABLE2 ) AS FULL_DATA_TYPE,
						CAST(0 AS BIT) AS ISPROC,
						B.create_date CREATE_DATE,
						b.modify_date AS MODIFY_DATE, 
						(SELECT DB_NAME()) DBNAME
	INTO				#TMPData
	FROM				q 
	LEFT OUTER JOIN		sys.tables b ON q.TABLE_NAME = B.[name]
	UNION ALL
	SELECT				'',name,'','','',CAST(1 AS BIT), create_Date,modify_date, (SELECT DB_NAME()) DBName
	FROM				Sys.procedures 
	-- WHERE				create_Date > GETDATE()-60
	--ORDER BY			q.TABLE_SCHEMA,q.TABLE_NAME,q.ORDINAL_POSITION;



	DECLARE @JsonResult NVARCHAR(MAX) = ''
SET @JsonResult = (SELECT  * FROM		#TMPData
FOR JSON PATH)

SELECT @JsonResult AS JsonResult

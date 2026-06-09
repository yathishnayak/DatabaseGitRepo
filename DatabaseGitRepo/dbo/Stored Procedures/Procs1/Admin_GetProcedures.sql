

CREATE PROCEDURE	[dbo].[Admin_GetProcedures] -- Admin_GetProcedures ''
(
	@SearchText		VARCHAR(200) = '',
	@FromDate		DATETIME =   '2024-12-15' ,
	@ToDate			DATETIME =  '2024-12-20',
	@IsCreated		BIT = 0
)

AS

BEGIN
	
	SET @SearchText = ISNULL(@SearchText,'')

	IF(ISNULL(@FromDate,'') = '')
		BEGIN
			SET @FromDate = '2018-01-01'
		END

	IF(ISNULL(@ToDate,'') = '')
		BEGIN
			SET @ToDate = GETDATE()
		END

	SET @FromDate = CAST(CONVERT(VARCHAR,@FromDate,101) AS DATETIME)
	SET @ToDate = CAST(CONVERT(VARCHAR,@ToDate+1,101) AS DATETIME)

	-- SELECT @FromDate, @ToDate

	SELECT		*
	FROM		(SELECT		DISTINCT 'JCBDB' DBname, o.name AS ProcName, o.type_desc--, m.definition
							, o.create_date AS Created_Date, o.modify_date AS Updated_Date
				FROM		sys.sql_modules m
				INNER JOIN	sys.objects o ON m.object_id = o.object_id
				WHERE		(m.definition LIKE '%' + @SearchText + '%'  OR '' = @SearchText)
							AND CASE WHEN @IsCreated = 0 THEN o.modify_date ELSE o.create_date END BETWEEN @FromDate AND @ToDate
				UNION ALL
				SELECT		DISTINCT 'Integration' DBName, o.name AS Object_Name, o.type_desc--, m.definition
							, o.create_date AS Created_Date, o.modify_date AS Updated_Date
				FROM		Integration_JCB.sys.sql_modules m
				INNER JOIN	Integration_JCB.sys.objects o ON m.object_id = o.object_id
				WHERE		(m.definition LIKE '%' + @SearchText + '%'  OR '' = @SearchText)
							AND CASE WHEN @IsCreated = 0 THEN o.modify_date ELSE o.create_date END BETWEEN @FromDate AND @ToDate) A
	ORDER BY	ProcName
END


/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"SearchText":"OAK","FromDate":"","ToDate":"","IsCreated":true}'
SET	@IsDebug  = 0

EXEC [Admin_SearchDatabaseObjectsBytext] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PROCEDURE	[dbo].[Admin_SearchDatabaseObjectsBytext] -- Admin_SearchDatabaseObjectsBytext 'CNB'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)

AS

BEGIN

	DECLARE 	@SearchText		VARCHAR(200) = '',
				@FromDate		DATETIME =   '' ,
				@ToDate			DATETIME =  '',
				@IsCreated		BIT = 0  

	SELECT		@SearchText = SearchText, @FromDate = FromDate, @ToDate = ToDate, @IsCreated = IsCreated
	FROM		OPENJSON(@JSONString, '$')
				WITH (
						SearchText		VARCHAR(200) '$.SearchText',
						FromDate		DATETIME	 '$.FromDate',
						ToDate			DATETIME	 '$.ToDate',
						IsCreated		BIT			 '$.IsCreated'
					)
	
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
	INTO		#TMPDATA
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
							AND CASE WHEN @IsCreated = 0 THEN o.modify_date ELSE o.create_date END BETWEEN @FromDate AND @ToDate ) A
	-- ORDER BY	ProcName    FOR JSON PATH

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult =	(SELECT		TypeDescDetails = (SELECT DISTINCT type_desc FROM #TMPDATA FOR JSON PATH),
							Details = (SELECT * FROM #TMPDATA FOR JSON PATH)  FOR JSON PATH) 


	SELECT @JSONResult AS JSONResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'
END
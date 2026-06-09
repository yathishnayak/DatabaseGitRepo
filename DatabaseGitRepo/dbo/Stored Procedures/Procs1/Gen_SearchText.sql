-- =============================================
-- Author:		Sumantha
-- Create date: 2025-12-22 21:36:57.313
-- Description:	Gets the table name and column name of the search text.
-- =============================================
CREATE PROCEDURE Gen_SearchText 
	@Text nvarchar(MAX) = ''
AS
BEGIN
	SET NOCOUNT ON;
	
	IF(ISNULL(@Text,'') = '') RETURN;

	DECLARE @SQL NVARCHAR(MAX) = '';

	SELECT @SQL = @SQL + '
	SELECT DISTINCT
		''' + t.name + ''' AS TableName,
		''' + c.name + ''' AS ColumnName
	FROM ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '
	WHERE TRY_CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)) LIKE ''%' + @Text + '%''
	UNION ALL '
	FROM sys.tables t WITH(NOLOCK) 
	INNER JOIN sys.schemas s WITH(NOLOCK) ON t.schema_id = s.schema_id
	INNER JOIN sys.columns c WITH(NOLOCK) ON t.object_id = c.object_id
	INNER JOIN sys.types ty WITH(NOLOCK) ON c.user_type_id = ty.user_type_id
	WHERE ty.name IN ('varchar','nvarchar','char','nchar','text','ntext');

	-- Remove last UNION ALL
	SET @SQL = LEFT(@SQL, LEN(@SQL) - 10);

	EXEC sp_executesql @SQL;
END

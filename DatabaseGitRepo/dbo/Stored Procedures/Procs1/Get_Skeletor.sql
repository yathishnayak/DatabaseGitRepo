
CREATE proc [dbo].[Get_Skeletor]
(
@Table_Name	varchar(max) = '',
@searchCol VARCHAR(MAX) = ''
)
as 
BEGIN

SET @Table_Name = LTRIM(RTRIM(ISNULL(@Table_Name,' ')));
SET @searchCol = LTRIM(RTRIM(ISNULL(@searchCol,' ')));

IF(@Table_Name <> '')
	BEGIN
		SELECT 'table name' = @Table_Name
		SELECT
		   COLUMN_NAME, 
		   UPPER(DATA_TYPE) + 
			CASE 
				WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN 
					'(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH in (-1, 255) THEN 'MAX' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR) END + ')'
				WHEN DATA_TYPE IN ('decimal', 'numeric') THEN 
					'(' + CAST(NUMERIC_PRECISION AS VARCHAR) + ',' + CAST(NUMERIC_SCALE AS VARCHAR) + ')'
				ELSE 
					''
			END AS DATATYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @Table_Name
		ORDER BY ORDINAL_POSITION;
	END

-- get tables having @searchCol
IF(@searchCol != '')
	BEGIN
		SELECT 'Column Name' = @searchCol;
		SELECT 
			'partition' = ROW_NUMBER() OVER(
				PARTITION BY T.[type_desc]
				ORDER BY IC.TABLE_NAME
			),
			'TABLE NAME' = IC.TABLE_NAME,
			'TYPE' = T.[type_desc]
		FROM INFORMATION_SCHEMA.COLUMNS IC 
			INNER JOIN sys.all_objects	T ON IC.TABLE_NAME = T.[name]
		WHERE (COLUMN_NAME = @searchCol);

		RETURN;
	END

IF(@Table_Name = '' AND @searchCol = '')
	BEGIN
		SELECT 'ERROR' = 'Search Params Cannot be Empty'
	END

END

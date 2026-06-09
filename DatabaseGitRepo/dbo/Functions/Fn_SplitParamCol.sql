
CREATE FUNCTION [dbo].[Fn_SplitParamCol]
(
	@ListValue VARCHAR(MAX)
)
RETURNS 
@ParsedList TABLE
(
	[Value] VARCHAR(100)
)
AS
BEGIN
	DECLARE @Param VARCHAR(100), @List INT

	SET @ListValue = LTRIM(RTRIM(@ListValue))+ ':'
	SET @List = CHARINDEX(':', @ListValue, 1)

	IF REPLACE(@ListValue, ':', '') <> ''
		BEGIN
			WHILE @List > 0
			BEGIN
				SET @Param = LTRIM(RTRIM(LEFT(@ListValue, @List - 1)))
				IF @Param <> ''
				BEGIN
					INSERT INTO @ParsedList ([Value]) 
					VALUES (@Param) --Use Appropriate conversion
				END
				SET @ListValue = RIGHT(@ListValue, LEN(@ListValue) - @List)
				SET @List = CHARINDEX(':', @ListValue, 1)

			END
		END	
	RETURN
END

CREATE FUNCTION [dbo].[Fn_SplitParamTest]
(
	@ListValue VARCHAR(500)
)
RETURNS 
@ParsedList TABLE
(
	[Value] VARCHAR(20)
)
AS
BEGIN
	DECLARE @Param VARCHAR(20), @List INT
	DECLARE @Count smallint

	SET @ListValue = LTRIM(RTRIM(@ListValue))+ '/'
	SET @List = CHARINDEX(':', @ListValue, 1)

	IF REPLACE(@ListValue, '/', '') <> ''
		BEGIN
			WHILE @List > 0
			BEGIN
				SET @Count=1
				SET @Param = LTRIM(RTRIM(LEFT(@ListValue, @List - 1)))
				IF @Param <> ''
				BEGIN
					INSERT INTO @ParsedList ([Value]) 
					VALUES (@Param) --Use Appropriate conversion
				END
				SET @ListValue = RIGHT(@ListValue, LEN(@ListValue) - @List)
				SET @List = CHARINDEX('/', @ListValue, 1)

			END
		END	
	RETURN
END

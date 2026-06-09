-- select * from [Fn_SplitTwoParam] ('205-5,206-8')
-- select  CHARINDEX(',', '205-5,206-8', 1)
CREATE FUNCTION [dbo].[Fn_SplitTwoParam]
(
	@ListValue VARCHAR(500)
)
RETURNS 
@ParsedList TABLE
(
	[Value1] VARCHAR(20),
	[Value2] VARCHAR(20)
)
AS
BEGIN
	DECLARE @Param1 VARCHAR(20), @List INT
	DECLARE @Param2 VARCHAR(20)
	DECLARE @Param3 VARCHAR(20)

	SET @ListValue = LTRIM(RTRIM(@ListValue))+ ','
	SET @List = CHARINDEX(',', @ListValue, 1)

	IF REPLACE(@ListValue, ',', '') <> ''
		BEGIN
			WHILE @List > 0
			BEGIN
				SET @Param1 = LTRIM(RTRIM(LEFT(@ListValue, @List - 1)))
				IF @Param1 <> ''
				BEGIN
					SET @Param2= CHARINDEX('-', @Param1, 1)					
					SET @Param3= RIGHT(@Param1,LEN(@Param1)- @Param2)
					SET @Param1= LEFT(@Param1,(CHARINDEX('-', @Param1, 1)-1))

					INSERT INTO @ParsedList ([Value1],[Value2]) 
					VALUES (@Param1,@Param3) --Use Appropriate conversion
				END
				SET @ListValue = RIGHT(@ListValue, LEN(@ListValue) - @List)
				SET @List = CHARINDEX(',', @ListValue, 1)

			END
		END	
	RETURN
END

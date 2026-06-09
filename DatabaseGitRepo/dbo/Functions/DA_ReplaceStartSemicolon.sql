

CREATE FUNCTION [dbo].[DA_ReplaceStartSemicolon]
(
    @InputString NVARCHAR(MAX)  -- Input parameter to accept the string
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Result VARCHAR(5000)
    -- Replace semicolon with a blank
	SET @InputString = RTRIM(LTRIM(@InputString))

	IF(LEFT(@InputString,1)) = ';'
		BEGIN
			SET @Result =  RIGHT(@InputString,LEN(@InputString)-1)
		END
	ELSE
		BEGIN
			SET @Result =  RTRIM(LTRIM(@InputString))
		END

	RETURN LTRIM(RTRIM(@Result))
END

-- SELECT dbo.DA_ReplaceStartSemicolon('Hello;World;SQL;Server;')

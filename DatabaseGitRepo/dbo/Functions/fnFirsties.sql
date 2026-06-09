CREATE FUNCTION [dbo].[fnFirsties] ( @str NVARCHAR(4000) )
RETURNS NVARCHAR(2000)
AS
BEGIN
    DECLARE @retval NVARCHAR(2000);
	 DECLARE @retval1 NVARCHAR(2000);

    SET @str= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@str)),'(',''),'-',''),'&',''),')',''),'24-7',''),'7','');
	SET @retval=LEFT(@str,1);
    SET @retval1=LEFT(@str,3);

    WHILE CHARINDEX(' ',@str,1)>0 
	BEGIN
        SET @str=LTRIM(RIGHT(@str,LEN(@str)-CHARINDEX(' ',@str,1)));
        SET @retval+=LEFT(@str,1);
    END
	IF LEN(@retval)=2
	BEGIN
		SET @retval= @retval+RIGHT(@str,1)
	END
	IF LEN(@retval)=1
	BEGIN
		SET @retval= @retval1
	END
	IF LEN(@retval)>3
	BEGIN
		SET @retval= LEFT(@retval,3)
	END
    RETURN @retval;
END

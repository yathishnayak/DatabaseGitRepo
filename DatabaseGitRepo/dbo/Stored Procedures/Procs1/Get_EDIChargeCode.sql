CREATE PROCEDURE [dbo].[Get_EDIChargeCode] -- Get_EDIChargeCode ''
@SearchString	VARCHAR(200)=''
AS

BEGIN
	SELECT Code, [Description] FROM EDIChargeCode
	WHERE @SearchString='' OR Code like '%'+@SearchString +'%' OR [Description] LIKE '%'+@SearchString +'%'
	ORDER BY [Description] ASC
	FOR JSON PATH
END
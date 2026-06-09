CREATE PROCEDURE [dbo].[Get_MenuDetail]
/*
UserRoleandPermissionDL
*/
--@UserKey	INT= 0,
--@UserName	INT = NULL,
--@Password	VARCHAR(50)= NULL
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT MenuKey, MenuName, StatusName 
	FROM dbo.Menu M 
		LEFT JOIN [Status] S ON S.StatusKey=M.StatusKey
	WHERE StatusName='Active' 
	ORDER BY MenuName asc
END

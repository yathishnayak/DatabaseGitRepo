/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_VersionHistory_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_VersionHistory_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		VersionNumber, VersionDate, VersionDetail, ISNULL(U1.UserName,'NA') LastUpdateUser, 
		ISNULL(V.UpdateDate,V.CreateDate) as LastUpdateDate
	FROM VersionHistory V WITH(NOLOCK)
	LEFT JOIN [User] U1  WITH(NOLOCK) on ISNULL(V.UpdateUserKey, V.CreateUserKey) = U1.userKey
	ORDER BY VersionDate Desc
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END
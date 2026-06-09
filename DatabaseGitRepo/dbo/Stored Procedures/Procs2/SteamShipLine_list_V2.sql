/*
DECLARE 
	@UserKey INT = 1144, 
	@JSONString NVARCHAR(MAX) = '',
	@Status BIT = 0,
	@Reason VARCHAR(1000), 
	@IsDebug BIT = 1 
EXEC [SteamShipLine_list_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
 
CREATE PROCEDURE [dbo].[SteamShipLine_list_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
		SELECT LineKey,ScacCode,LineName, IsActive, CreateUser, CreateDate, UpdateUser, UpdateDate,
		U.UserName as CreateUserName, U1.UserName as UpdateUserName
		FROM SteamShipLine A WITH(NOLOCK)
		LEFT JOIN [User] U WITH(NOLOCK) ON A.CreateUser = U.UserKey
		LEFT JOIN [User] U1 WITH(NOLOCK) ON A.UpdateUser = U1.UserKey
		ORDER BY LineName
            
        FOR JSON PATH
	);
 
	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';

END
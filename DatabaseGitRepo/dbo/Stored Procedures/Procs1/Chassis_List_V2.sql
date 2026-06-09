CREATE PROCEDURE [dbo].[Chassis_List_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE  @MarketLocationKey INT;
	--SELECT @MarketLocationKey = MarketLocationKey
	--from OPENJSON(@JSONString, '$')
	--with (
	--		MarketLocationKey int '$.MarketLocationKey'
	--	 )
	--DECLARE @JSONOutput NVARCHAR(MAX) = N'';
	--SET @JSONOutput = (

	SELECT			ChassisKey, ChassisNo, C.CreateDate, ChassisType, StatusKey, CompanyKey, IsEditable,
					CreateUser, C.UpdateDate, UpdateUser, U1.UserName AS CreateUserName, u2.UserName as UpdateUserName,C.IsActive,IsDelete, ML.MarketLocationKey,ML.MarketLocation
					
	FROM			CHASSIS C WITH (NOLOCK)
	LEFT JOIN		[User] U1 WITH (NOLOCK)ON C.CREATEUSER = U1.USERKEY
	LEFT JOIN		[USER] U2 WITH (NOLOCK) ON C.UPDATEUSER = U2.UserKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON (ML.MarketLocationKey=C.MarketLocationKey)
	--WHERE (@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.MarketLocationKey,0) END = @marketLocationKey)
		WHERE ISNULL(C.IsDelete,0) = 0
	ORDER BY		ChassisNo
	FOR JSON PATH
	
	--SELECT @JSONOutput AS JSONOutput;
	SET @Status = 1
		SET @Reason = 'Success'
   
END
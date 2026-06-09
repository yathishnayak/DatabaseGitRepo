CREATE proc [dbo].[Chassis_List] -- Chassis_List
@MarketLocationKey	INT=0
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT			chassisKey, chassisNo, C.CreateDate, ChassisType, StatusKey, CompanyKey, IsEditable,
					CreateUser, C.UpdateDate, UpdateUser, U1.UserName AS CreateUserName, u2.UserName as UpdateUserName,C.IsActive,IsDelete, ML.MarketLocationKey,MarketLocation
	FROM			CHASSIS C WITH (NOLOCK)
	LEFT JOIN		[User] U1 WITH (NOLOCK)ON C.CREATEUSER = U1.USERKEY
	LEFT JOIN		[USER] U2 WITH (NOLOCK) ON C.UPDATEUSER = U2.UserKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON (ML.MarketLocationKey=C.MarketLocationKey)
	--WHERE (@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.MarketLocationKey,0) END = @marketLocationKey)
	ORDER BY		chassisNo
	FOR JSON PATH
	
END

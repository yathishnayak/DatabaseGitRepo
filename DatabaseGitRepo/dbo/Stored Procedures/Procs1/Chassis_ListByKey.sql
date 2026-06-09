CREATE proc [dbo].[Chassis_ListByKey] -- Chassis_ListByKey 597
(
	@chassisKey		INT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT			chassisKey, chassisNo, CreateDate, ChassisType, StatusKey, CompanyKey, IsEditable,
					CreateUser, UpdateDate, UpdateUser, U1.UserName AS CreateUserName, u2.UserName as UpdateUserName,IsActive,IsDelete
	FROM			CHASSIS C WITH (NOLOCK)
	LEFT JOIN		[User] U1 WITH (NOLOCK)ON C.CREATEUSER = U1.USERKEY
	LEFT JOIN		[USER] U2 WITH (NOLOCK) ON C.UPDATEUSER = U2.UserKey
	WHERE			chassisKey = @chassisKey 
	ORDER BY		chassisNo
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	
END


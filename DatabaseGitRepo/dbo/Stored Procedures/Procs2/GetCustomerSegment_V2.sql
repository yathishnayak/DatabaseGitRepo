/*
DECLARE @UserKey		INT=488,
	@JsonString		VARCHAR(MAX)='{"CustomerSegmentKey":3}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	EXEC GetCustomerSegment_V2 @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[GetCustomerSegment_V2]
(
	@UserKey      INT=488,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT CustomerSegmentKey,CustomerSegment,BasePercent, U.UserName AS CreatedUser, U2.UserName AS UpdatedUser,
	IsNacCustomer,CS.MarketKey,FSFPercent,EffectiveDate, EffectiveFrom
	FROM CustomerSegments CS WITH (NOLOCK)
	LEFT JOIN [User] U WITH (NOLOCK) ON CS.CreatedUser = U.UserKey
	LEFT JOIN [User] U2 WITH (NOLOCK) ON CS.UpdateUser = U2.UserKey
	WHERE isnull(CS.IsDeleted,0)=0 
	FOR JSON PATH;

	SET @Reason='Success';
	SET @Status =1
END
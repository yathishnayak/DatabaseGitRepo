CREATE PROCEDURE [dbo].[Update_ConfirmRouteRate]
@Routekey   INT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.[Routes] 
	SET IsRateVerified= 1, 
		RateVerifiedDate = GETDATE(),
		RateVerifiedUserKey= @UserKey
	WHERE RouteKey = @Routekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1;
	END;	
END

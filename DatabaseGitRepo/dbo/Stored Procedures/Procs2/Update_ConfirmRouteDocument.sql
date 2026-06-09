CREATE PROCEDURE [dbo].[Update_ConfirmRouteDocument]
@Routekey   INT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.[Routes] 
	SET IsDocumentVerified= 1, 
		DocumentVerifiedDate = GETDATE(),
		DocumentVerifiedUserKey= @UserKey
	WHERE RouteKey = @Routekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1;
	END;	
END

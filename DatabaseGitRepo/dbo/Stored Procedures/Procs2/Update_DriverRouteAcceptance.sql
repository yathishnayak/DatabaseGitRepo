CREATE PROCEDURE [dbo].[Update_DriverRouteAcceptance]
@RouteKey INT,
@Status VARCHAR(50),
@ReasonKey smallint,
@ReasonText varchar(50),
@AcceptanceKey	INT=0
AS
BEGIN
	DECLARE @UserKey INT, @DriverKey INT

	SET @UserKey=( SELECT DriverKey FROM dbo.[routes] WHERE RouteKey=@RouteKey)
	SET @DriverKey=( SELECT DriverKey FROM dbo.[routes] WHERE RouteKey=@RouteKey)

	IF @Status='Reject'
	BEGIN
		UPDATE dbo.[routes]
		SET DriverKey= NULL
		WHERE RouteKey=@RouteKey

		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END
	--IF ( SELECT COUNT(1) FROM DriverRouteAcceptance WHERE RouteKey=@RouteKey AND [Description] IN ('Reject','Accept'))>0
	--BEGIN
	--	UPDATE DriverRouteAcceptance
	--	SET [Description]=@Status
	--	WHERE RouteKey=@RouteKey and driverKey=@DriverKey
	--END
	--ELSE
	--BEGIN
		IF(@AcceptanceKey=0)
		BEGIN
		INSERT INTO DriverRouteAcceptance (RouteKey,[Description], RejectReasonKey, RejectReasonDescr,CreateUserKey, DriverKey)
		SELECT @RouteKey,@Status, @ReasonKey, @ReasonText,@UserKey, @DriverKey
		END
		ELSE
		BEGIN
		UPDATE DriverRouteAcceptance
		SET [Description]=@Status, ActionDate=GETDATE()
		WHERE RouteKey=@RouteKey
		END
	--END
END

/** 
Declare 
	@UserKey		INT =  1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey" : 569361, "Description" : "Accept", "ReasonKey" : 0, "ReasonText" : null, "AcceptanceKey" : 0}'
	EXEC [Update_DriverRouteAcceptance_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_DriverRouteAcceptance_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
			BEGIN
				SET		@Status = 0
				SET		@Reason = 'Parameters not found'
				RETURN
			END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE @RouteKey INT,
			@Description VARCHAR(50),
			@ReasonKey smallint,
			@ReasonText varchar(50),
			@AcceptanceKey	INT=0


	SELECT 
		@RouteKey			=		RouteKey,
		@Description		=		Description,
		@ReasonKey 			=		ReasonKey,
		@ReasonText 		=		ReasonText,
		@AcceptanceKey		=		AcceptanceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey			INT					'$.RouteKey',
		Description			VARCHAR(50)			'$.Description',
		ReasonKey			SMALLINT			'$.ReasonKey',
		ReasonText			VARCHAR(50)			'$.ReasonText',
		AcceptanceKey		INT					'$.AcceptanceKey'
	)

	DECLARE 
	-- @UserKey INT, 
	@DriverKey INT

	-- SET @UserKey=( SELECT DriverKey FROM dbo.[routes] WHERE RouteKey=@RouteKey)
	SET @DriverKey=( SELECT DriverKey FROM dbo.[routes] WITH(NOLOCK) WHERE RouteKey=@RouteKey)

	IF @Description='Reject'
	BEGIN
		UPDATE dbo.[routes]
		SET DriverKey= NULL
		WHERE RouteKey=@RouteKey

		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END
	--IF ( SELECT COUNT(1) FROM DriverRouteAcceptance WHERE RouteKey=@RouteKey AND [Description] IN ('Reject','Accept'))>0
	--BEGIN
	--	UPDATE DriverRouteAcceptance
	--	SET [Description]=@Description
	--	WHERE RouteKey=@RouteKey and driverKey=@DriverKey
	--END
	--ELSE
	--BEGIN
		IF(@AcceptanceKey=0)
		BEGIN
		INSERT INTO DriverRouteAcceptance (RouteKey,[Description], RejectReasonKey, RejectReasonDescr,CreateUserKey, DriverKey)
		SELECT @RouteKey,@Description, @ReasonKey, @ReasonText,@UserKey, @DriverKey
		END
		ELSE
		BEGIN
		UPDATE DriverRouteAcceptance
		SET [Description]=@Description, ActionDate=GETDATE()
		WHERE RouteKey=@RouteKey
		END
	--END
	SET @Status = 1
	SET @Reason = 'Success'
END
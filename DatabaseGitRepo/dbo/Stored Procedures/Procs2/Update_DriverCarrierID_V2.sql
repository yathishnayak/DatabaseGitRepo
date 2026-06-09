/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey":648, "DriverID":"146-VK ALONZO TRUCKI"}'
	EXEC [Update_DriverCarrierID_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_DriverCarrierID_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
	@DriverKey  INT,
	@DriverID   VARCHAR(50)

	SELECT
	@DriverKey  =   DriverKey,
	@DriverID   =   DriverID 
	FROM OPENJSON(@JSONString)
	WITH
	(
	DriverKey			INT				'$.DriverKey'	,
	DriverID			VARCHAR(50)		'$.DriverID'	
	)

	IF(@DriverKey = 0)
	BEGIN 
		SET @Status = 0
		SET @Reason = 'Driver Key required'
		RETURN;
    END

	IF(ISNULL(@DriverID,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Driver ID Can''t be blank'
		RETURN;
	END

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM Driver WITH (NOLOCK) WHERE DriverID = @DriverID AND DriverKey <> @DriverKey

	IF(@CNT > 0)
	BEGIN
	   SET @Status = 0
	   SET @Reason = 'Driver ID already exists'
	   return;
	END

	UPDATE Driver SET DriverID = @DriverID
	WHERE DriverKey = @DriverKey
	SET @Status = 1
	SET @Reason = 'Updated Successfully'
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),'','Driver',@DriverId,@DriverKey,null,'Text','Driver Id updated'
	RETURN;
END
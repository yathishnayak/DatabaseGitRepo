/*
DECLARE 
	@UserKey INT = 952,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":0,"RouteKey":0, "DriverNotes":""}',
	@Status	BIT = 0, 
	@IsDebug BIT = 1,
	@Reason	VARCHAR(100) =''
	EXec [UpdaeDriverInstruction_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":47694,"RouteKey":177964, "DriverNotes":"Hello"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 1,
	@Reason	VARCHAR(100) =''
	EXec [UpdaeDriverInstruction_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[UpdaeDriverInstruction_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE 	
		@OrderDetailKey	INT,
		@RouteKey		INT=0,
		@DriverNotes	VARCHAR(500)

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
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

	SELECT 
		@OrderDetailKey	= OrderDetailKey,
		@RouteKey		= RouteKey,
		@DriverNotes	= DriverNotes
	FROM OPENJSON(@JSONSTRING)
	WITH
	(
		OrderDetailKey		INT				'$.OrderDetailKey',
		RouteKey			INT				'$.RouteKey',
		DriverNotes			VARCHAR(500)	'$.DriverNotes'
	)

	--UPDATE dbo.OrderDetail
	--SET DriverNotes = @DriverNotes
	--WHERE OrderDetailKey=@OrderDetailKey

	UPDATE dbo.Routes
	SET DriverInstructions = @DriverNotes
	WHERE RouteKey=@RouteKey

	SET @Status=1
	SET @Reason='Success'
END
/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":200077,"VesselETA":"1900-01-02"}',
	@Status	BIT=0, 
	@IsDebug BIT = 1, 
	@Reason	VARCHAR(100)=''
	EXec [Update_OrderDetail_VesselETA_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Update_OrderDetail_VesselETA_V2]
/*
Update detail data from Container Screen
*/
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

	DECLARE 
		@OrderDetailKey		INT,
		@VesselETA			DateTime
	-- @UpdateUserKey		INT

	SELECT 
		@OrderDetailKey		=		OrderDetailKey,
		@VesselETA			=		VesselETA
	-- @UpdateUserKey		=		UpdateUserKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey			INT				'$.OrderDetailKey',
		VesselETA				DATETIME		'$.VesselETA'
	)

	-- SET @Status=0;
	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey

	UPDATE OrderDetail 
	SET VesselETA= @VesselETA, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey
	
	UPDATE Container_GnosisData 
	SET ETA_ATA = @VesselETA,ETA_ATAChangedByUser=CASE WHEN ISNULL(@VesselETA,'')<>ISNULL(ETA_ATA,'') THEN 1 ELSE ETA_ATAChangedByUser END
	WHERE OrderDetailKey= @OrderDetailKey

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			 null,'Text','VesselETA is updated by '+@UserName

	SET @Status=1
	SET @Reason = 'Success'
END

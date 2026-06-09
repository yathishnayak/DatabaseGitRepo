/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 47697, "ContainerSizeKey" : 15}'
	EXEC [Update_ContainerSize_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_ContainerSize_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@OrderDetailKey		int,
		@ContainerSizeKey	int

	SELECT 
		@OrderDetailKey	   =  OrderDetailKey,	
		@ContainerSizeKey   =  ContainerSizeKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey				INT				'$.OrderDetailKey',	
		ContainerSizeKey			INT				'$.ContainerSizeKey'
	)

	DECLARE @CNT INT = 0,
			@UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)
	set @Status = 0
	SELECT @CNT = COUNT(1) FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey
	IF(@CNT > 0)
	BEGIN
		SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey			
		SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
		
		UPDATE OrderDetail
		SET ContainerSizeKey = @ContainerSizeKey, UpdateUserKey = @UserKey
		where OrderDetailKey = @OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','Container size is updated by '+@UserName

		set @Status = 1
		SET @Reason = 'Success'
	END
END
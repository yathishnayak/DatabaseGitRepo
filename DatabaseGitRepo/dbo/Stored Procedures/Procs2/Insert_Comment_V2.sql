/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"Description":"<p>abc</p>","IsUserComment":true,"OrderKey":185658}'
	EXEC [Insert_Comment_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Insert_Comment_V2]
/*
dbo.fn_insert_comment
*/
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
			RETURN
		END	

	DECLARE 
	@Description	NVARCHAR(max),
	-- @City			VARCHAR(255),
	-- @CreateUserKey	INT	,
	@IsUsercomment  BIT = 0,
	@ParentCommentKey INT,
	@Commentkey		INT,
	@OrderdetailKey	INT,
	@OrderKey		INT

	SELECT 
	@Description			=		Description,	
	-- @City					=		City,				
	@IsUsercomment			=		IsUserComment,		
	@ParentCommentKey		=		ParentCommentKey,	
	@Commentkey				=		CommentKey,
	@OrderdetailKey			=       OrderdetailKey,
	@OrderKey				=		OrderKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	Description				NVARCHAR(MAX)			'$.Description',		
	-- City					VARCHAR(255)			'$.City',				
	IsUserComment			BIT						'$.IsUserComment',		
	ParentCommentKey		INT						'$.ParentCommentKey',
	CommentKey				INT						'$.CommentKey',
	OrderdetailKey			INT						'$.OrderDetailKey',
	OrderKey				INT						'$.OrderKey'
	)

	DECLARE @UserName NVARCHAR(MAX)='',@ContainerNo VARCHAR(20)='', @OrderNo VARCHAR(20)=''
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	
	IF ISNULL(@OrderDetailKey, 0) = 0 AND ISNULL(@OrderKey, 0) = 0
	BEGIN
		SET @Status = 0
		SET @Reason = 'OrderDetailKey or OrderKey is required'
		RETURN
	END

	INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey,IsUsercomment,ParentCommentKey)
	VALUES (@Description, GETDATE(),@UserKey,@IsUsercomment,@ParentCommentKey)

	SET @CommentKey=0;
	SET @CommentKey = ( SELECT SCOPE_IDENTITY());

	IF ISNULL(@OrderDetailKey, 0) <> 0
	BEGIN
		SELECT @ContainerNo=ISNULL(ContainerNo, '') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderdetailKey

		INSERT INTO dbo.OrderDetailComments(OrderDetailKey, Commentkey)
		VALUES (@OrderDetailKey, @CommentKey)

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Comment added by ' +@UserName
	END

	IF ISNULL(@OrderKey, 0) <> 0
	BEGIN
		SELECT @OrderNo=ISNULL(OrderNo, '') FROM OrderHeader WITH(NOLOCK) WHERE OrderKey = @OrderKey

		INSERT INTO dbo.OrderHeaderComments(OrderKey, Commentkey)
		VALUES (@OrderKey, @CommentKey)

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Order',@OrderNo,@OrderKey,null,'Text','Comment added by ' +@UserName
	END

	--INSERT INTO dbo.OrderDetailComments(OrderDetailKey,Commentkey)
	--VALUES (@OrderdetailKey, @CommentKey);
	
	--DECLARE @UserName NVARCHAR(MAX)='',@ContainerNo VARCHAR(20)=''
	--SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	--SELECT @ContainerNo=ISNULL(ContainerNo, '') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey=@OrderdetailKey

	--INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	--SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Comment added by ' +@UserName

	SET @Status = 1
	SET @Reason = 'Success'
	
END
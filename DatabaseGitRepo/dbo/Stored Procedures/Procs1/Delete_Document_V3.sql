/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentKey" : "596697"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Delete_Document_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_Document_V3] --exec delete_document 574712 951
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Status=0;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@DocumentKey	INT 

	SELECT
		@DocumentKey		=		DocumentKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKey			INT		'$.DocumentKey'
	)


	UPDATE dbo.Document  
	SET IsDeleted = 1 , DeletedDate = GETDATE(),DeletedUserKey = @UserKey
	WHERE DocumentKey = @DocumentKey;

	DECLARE @UserName NVARCHAR(MAX)='',@ContainerNo VARCHAR(20)='',@OrderDetailKey INT=0
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	SET @ContainerNo = ISNULL((SELECT ContainerNo FROM OrderDetail WITH(NOLOCK)
					  WHERE OrderDetailKey = (SELECT OrderDetailKey FROM OrderDetailDocuments WITH(NOLOCK) WHERE DocumentKey = @DocumentKey)), '')
	SELECT @OrderDetailKey = OrderDetailKey FROM OrderDetailDocuments WITH(NOLOCK) WHERE DocumentKey = @DocumentKey

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Document deleted by ' + @UserName

  SET @Status = 1;
  SET @Reason = 'Success'
	
END

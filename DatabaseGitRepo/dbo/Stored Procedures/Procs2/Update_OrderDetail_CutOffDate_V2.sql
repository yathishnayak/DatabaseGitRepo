/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":207075,"CutOffDate":"2025-03-29"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 1, 
	@Reason	VARCHAR(100) = ''
	EXec [Update_OrderDetail_CutOffDate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Update_OrderDetail_CutOffDate_V2]
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
-- @UpdateUserKey INT,
-- @Status		   BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE
		@OrderDetailKey		INT,
		@CutOffDate		Datetime

	SELECT 
		@OrderDetailKey		=		OrderDetailKey,
		@CutOffDate			=		CutOffDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey			INT			'$.OrderDetailKey',
		CutOffDate				DATETIME	'$.CutOffDate'
	)

	SET @Status=0;
	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey

	UPDATE OrderDetail 
	SET CutOffDate= @CutOffDate, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey 

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			 null,'Text','Schedule T is updated by '+@UserName

	SET @Status=1
	SET @Reason = 'Success'
END

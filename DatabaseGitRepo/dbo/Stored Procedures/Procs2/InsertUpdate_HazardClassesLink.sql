/**
DECLARE 
	@UserKey INT=951,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":226005,"ClassKey":7,"IsSelected":1}',
	@Status	BIT=0, @IsDebug	BIT=1, @Reason VARCHAR(100)=''
	EXEC InsertUpdate_HazardClassesLink @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason
**/
CREATE PROCEDURE [dbo].[InsertUpdate_HazardClassesLink]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderDetailKey			INT,
			@ClassKey				INT,
			@IsSelected				BIT,
			@UserName				VARCHAR(100),
			@ContainerNo			NVARCHAR(20),
			@Comments				NVARCHAR(500)=''

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @OrderDetailKey = 0
		SET @ClassKey = 0
		SET @IsSelected =0
	END
	ELSE
	BEGIN
		
		SELECT @OrderDetailKey = OrderDetailKey, @ClassKey = ClassKey, @IsSelected = IsSelected
		FROM OPENJSON(@JsonString, '$')
		WITH (
			OrderDetailKey		INT				'$.OrderDetailKey',
			ClassKey			INT				'$.ClassKey',
			IsSelected			BIT				'$.IsSelected'
		)
	END

	SELECT @ContainerNo=ISNULL(ContainerNo,'') FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	SELECT @Comments=ISNULL(Description,'') FROM Container_HazardClasses WITH (NOLOCK) WHERE ClassKey=@ClassKey
	SELECT @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey

	IF(@IsSelected=1)
	BEGIN
		INSERT INTO HazardClassesLink
				(OrderDetailKey,ClassKey,IsSelected)
		SELECT  @OrderDetailKey,@ClassKey,@IsSelected

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','HazardClass '+@Comments+' added to container '+@ContainerNo
	END
	ELSE IF(@IsSelected=0)
	BEGIN
		DELETE FROM HazardClassesLink
		WHERE OrderDetailKey=@OrderDetailKey AND ClassKey=@ClassKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','HazardClass '+@Comments+' removed from container '+@ContainerNo
	END
	ELSE
	BEGIN
		SET @Status=0
		SET @Reason='FAILURE'
		RETURN;
	END
	SET @Status=1
	SET @Reason='SUCCESS'
END
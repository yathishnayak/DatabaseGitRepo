CREATE PROCEDURE [dbo].[InsertUpdate_ContainerTypeLink_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"OrderDetailKey":226005,"ContainerTypeKey":12,"IsSelected":1}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderDetailKey			INT,
			@ContainerTypeKey		INT,
			@IsSelected				BIT,
			@UserName				VARCHAR(100),
			@ContainerNo			NVARCHAR(20),
			@Comments				NVARCHAR(500)=''

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @OrderDetailKey = 0
		SET @ContainerTypeKey = 0
		SET @IsSelected =0
	END
	ELSE
	BEGIN
		SELECT @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey
		
		SELECT @OrderDetailKey = OrderDetailKey, @ContainerTypeKey = ContainerTypeKey, @IsSelected = IsSelected
		FROM OPENJSON(@JsonString, '$')
		WITH (
			OrderDetailKey		INT				'$.OrderDetailKey',
			ContainerTypeKey	INT				'$.ContainerTypeKey',
			IsSelected			BIT				'$.IsSelected'
		)
	END
	SELECT @ContainerNo=ISNULL(ContainerNo,'') FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	SELECT @Comments=ISNULL(ShortCode,'') FROM ContainerTypes WITH (NOLOCK) WHERE ContainerTypeKey=@ContainerTypeKey

	IF(@IsSelected=1)
	BEGIN
		INSERT INTO ContainerTypesLink
				(OrderDetailKey,ContainerTypeKey, CommentKey,IsSelected)
		SELECT  @OrderDetailKey,@ContainerTypeKey, 0,@IsSelected

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Property '+@Comments+' added to container '+@ContainerNo
	END
	ELSE IF(@IsSelected=0)
	BEGIN
		DELETE FROM ContainerTypesLink
		WHERE OrderDetailKey=@OrderDetailKey AND ContainerTypeKey=@ContainerTypeKey

		IF (@ContainerTypeKey = 1)
		BEGIN
		    DELETE FROM HazardClassesLink
		    WHERE OrderDetailKey = @OrderDetailKey;

			INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Hazard Classes removed from container '+@ContainerNo
		END

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Property '+@Comments+' removed from container '+@ContainerNo
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
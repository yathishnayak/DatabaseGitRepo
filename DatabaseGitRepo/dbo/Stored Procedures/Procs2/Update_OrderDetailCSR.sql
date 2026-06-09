/**

	DECLARE @UserKey  INT=953,
	@JSONString   NVARCHAR(MAX)='{"OrderDetailKey":176257,"csr":56}',
	--@JSONOutput   NVARCHAR(MAX) = '',
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = ''

	EXEC [Update_OrderDetailCSR] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status, @Reason

**/

CREATE PROC [dbo].[Update_OrderDetailCSR]
(
	@UserKey	INT				=	953,
	@JSONString	NVARCHAR(MAX)	=	'',
	@Status		BIT				=	0	OUTPUT,
	@Reason		VARCHAR(1000)	=	''	OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	IF(ISNULL(@JSONString, '')= '')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter missing';
	END

	DECLARE	@OrderDetailKey	INT,
			@CSRKey			INT,
			@UserName NVARCHAR(100)='',
			@ContainerNo	NVARCHAR(20)='',
			@PrevCSRName	NVARCHAR(100)='',
			@CSRName		NVARCHAR(100)=''

	SELECT @UserName=ISNULL(UserName,'') FROM [User] WHERE UserKey=@UserKey

	Select @OrderDetailKey = OrderDetailKey, @CSRKey = CsrKey
			From OPENJSON(@JSONString, '$')WITH
			(
				OrderDetailKey		INT '$.OrderDetailKey',
				CsrKey				INT	'$.csr'
			)
	SELECT @ContainerNo=ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey
	SELECT @PrevCSRName=ISNULL(TRIM(CsrName),'') FROM CSR WHERE CsrKey=(SELECT ISNULL(CSRKey,0) FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey)
	SELECT @CSRName=ISNULL(TRIM(CsrName),'') FROM CSR WHERE CsrKey=@CSRKey
	print @OrderDetailKey
	print @CSRKey

	IF (ISNULL(@OrderDetailKey, 0) <> 0 AND ISNULL(@CsrKey, 0) <> 0)
	BEGIN
		UPDATE OrderDetail
		--SET CsrKey = CASE 
		--				WHEN ISNULL(@CsrKey, 0) <> 0 THEN @CsrKey 
		--				ELSE CsrKey 
		--			END
		SET CsrKey = @CsrKey
		WHERE OrderDetailKey = @OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','CSR changed from '+@PrevCSRName+' to '+@CSRName + ' by '+@UserName

		SET @Status=1;
		SET @Reason='Success';

		--Select CsrKey, CsrName from CSR WHERE CsrKey = @CSRKey FOR JSON PATH
	END
	ELSE
	BEGIN
		SET @Status=0;
		SET @Reason='Failed to save check OrderDetailKey Or CsrKey';
	END

END

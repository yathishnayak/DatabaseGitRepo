/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKey" : 124252}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_VoucherRevised_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_VoucherRevised_V3]
(
	@UserKey		INT = 1144,
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

	DECLARE
		@VoucherKey INT
	SELECT
		@VoucherKey = VoucherKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey		INT			'$.VoucherKey'
	)

	DECLARE 
			@UserName	VARCHAR(50)

	SELECT TOP 1 @UserName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey

	SET @Status=0;

	UPDATE dbo.VoucherHeader
	SET StatusKey = 1, IsPaymentApproved=0, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsRevised = 1 -- is payment approved condition added by SS-7/20
	WHERE StatusKey in (2,3) and VoucherKey = @voucherKey;

	UPDATE VoucherHeader SET InternalNote = ISNULL(InternalNote,'') + 'Voucher Revised by ' + @UserName + ' on ' 
			+ CONVERT(VARCHAR, GETDATE(),101) + ' ' + CONVERT(VARCHAR, GETDATE(),108) + '; ' + '<br>' 
			+ CASE WHEN ISNULL(IsPaid,0) = 1 THEN '[Revised after Paid]' ELSE '' END
			WHERE VoucherKey = @voucherKey
	
	SET @Status=1
	SET @Reason = 'Updated Succesfully'

	--AUDILOG
	DECLARE 
    @VoucherNo      VARCHAR(20) = '',
    @ContainerNo    VARCHAR(20) = '',
    @OrderDetailKey INT = 0,
	@RouteKey INT = 0;

SELECT @VoucherNo = ISNULL(VoucherNo, '')FROM VoucherHeader WITH (NOLOCK) WHERE VoucherKey = @VoucherKey;

SELECT TOP 1 @RouteKey = RouteKey FROM VoucherDetail WITH (NOLOCK)WHERE VoucherKey = @VoucherKey;

SELECT TOP 1 @OrderDetailKey = OrderDetailKey FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey;

SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey;


INSERT INTO AuditLogDetail
(DateCreated, CreateUser, RefType, RefId,RefKey,Stage,CommentType,Comments)
SELECT GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL,'Text', 'Voucher ' + @VoucherNo + ' revised';

END
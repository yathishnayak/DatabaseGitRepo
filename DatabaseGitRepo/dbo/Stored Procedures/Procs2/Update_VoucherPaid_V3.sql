/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKeys" : "343920,343921"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_VoucherPaid_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_VoucherPaid_V3]
/*
Voucher Screen
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
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @Status=0;

	--CREATE Table #VoucherKey
	--(
	--	VoucherKey INT
	--);

	
	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@VoucherKey		VARCHAR(max),-- Comma Separated Values
		@IsAllSelected	bit = 0
	SELECT
		@VoucherKey			=		VoucherKey		,
		@IsAllSelected		=		IsAllSelected	
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey				VARCHAR(MAX)		'$.VoucherKeys'		,
		IsAllSelected			BIT					'$.IsAllSelected'	
	)


	SELECT Value AS VoucherKey INTO #VoucherKey FROM dbo.Fn_SplitParam(@VoucherKey);

	Declare @StatusKey int = 0;
	select @StatusKey = StatusKey from VoucherStatus WITH(NOLOCK) where Description = 'Paid Vouchers' -- @StatusKey = 3

	if(ISNULL(@IsAllSelected, 0) = 0)
	begin
		--INSERT INTO #VoucherKey (VoucherKey)
		--SELECT [Value] FROM Fn_SplitParamCol(@VoucherKey);	

		UPDATE dbo.VoucherHeader
		SET IsPaid=1,PaidUserKey=@UserKey, StatusKey = @StatusKey, PaidDate = GetDate()
		WHERE VoucherKey IN ( SELECT DISTINCT VoucherKey FROM #VoucherKey );
	end

	if(@IsAllSelected = 1)
	begin
		UPDATE dbo.VoucherHeader
		SET IsPaid=1,PaidUserKey=@UserKey, StatusKey = @StatusKey, PaidDate = GetDate()
		WHERE StatusKey = 2; -- Approved Status

		   DELETE FROM #VoucherKey;

        INSERT INTO #VoucherKey (VoucherKey)
        SELECT VoucherKey FROM VoucherHeader WITH(NOLOCK) WHERE StatusKey = @StatusKey;
	End

	SET @Status=1
	SET @Reason = 'Updated Sucessfully'

		DECLARE @UserName VARCHAR(50) = '';
		SELECT @UserName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey;

		INSERT INTO AuditLogDetail(DateCreated,CreateUser, RefType, RefId, RefKey, Stage,CommentType,Comments)
		SELECT GETDATE(), @UserName, 'Container', OD.ContainerNo,OD.OrderDetailKey, NULL,'Text','Voucher ' + VH.VoucherNo + ' marked as paid'
		FROM #VoucherKey VK
		INNER JOIN VoucherHeader VH WITH(NOLOCK)  ON VH.VoucherKey = VK.VoucherKey
		INNER JOIN VoucherDetail VD WITH(NOLOCK)     ON VD.VoucherKey = VK.VoucherKey
		INNER JOIN Routes RT WITH(NOLOCK)         ON RT.RouteKey = VD.RouteKey
		INNER JOIN OrderDetail OD WITH(NOLOCK)      ON OD.OrderDetailKey = RT.OrderDetailKey

END;
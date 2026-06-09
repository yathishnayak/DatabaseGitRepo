/*
DECLARE
@VoucherKey VARCHAR(max) = 256934,
@UserKey	INT = 1144,
@IsAllSelected	bit = 0,
@OutPut		BIT
EXEC [Update_VoucherPaid] @VoucherKey, @UserKey, @IsAllSelected, @OutPut OUTPUT
SELECT @Output AS OUTPUT
*/
CREATE PROCEDURE [dbo].[Update_VoucherPaid]
/*
Voucher Screen
*/
@VoucherKey VARCHAR(max),-- Colon Separated Values
@UserKey	INT,
@IsAllSelected	bit = false,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	--CREATE Table #VoucherKey
	--(
	--	VoucherKey INT
	--);

	SELECT Value AS VoucherKey INTO #VoucherKey FROM dbo.Fn_SplitParamCol(@VoucherKey);

	Declare @StatusKey int = 0;
	select @StatusKey = StatusKey from VoucherStatus WITH(NOLOCK) where Description = 'Paid Vouchers' -- @StatusKey = 3

	if(@IsAllSelected = 0)
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



	SET @OutPut=1;

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
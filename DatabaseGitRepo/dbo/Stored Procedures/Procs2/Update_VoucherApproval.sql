

CREATE PROCEDURE [dbo].[Update_VoucherApproval]
/*
Voucher Screen
*/
@VoucherKey VARCHAR(300),-- Colon Separated Values
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	CREATE Table #VoucherKey
	(
		VoucherKey INT
	);

	Declare @StatusKey int = 0;
	select @StatusKey = StatusKey from VoucherStatus where Description = 'Approved'

	INSERT INTO #VoucherKey (VoucherKey)
	SELECT [Value] FROM Fn_SplitParamCol(@VoucherKey);	

	UPDATE dbo.VoucherHeader
	SET IsPaymentApproved=1,PmtApprovedUser=@UserKey, 
		StatusKey = @StatusKey,UpdateDate = GetDate(), UpdateuserKey = @UserKey
	WHERE VoucherKey IN ( SELECT DISTINCT VoucherKey FROM #VoucherKey );

	/* COMMENTED AS THE STATUS CHANGE MAKES CONTAINER INVISIBLE IN SCHEDULER SCREEN
	UPDATE OD
	SET OD.Status= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Approved for Invoice/Driver Pay' ),StatusDate=GETDATE()
	FROM DBO.VoucherDetail ID 
		INNER JOIN DBO.[Routes] RT on RT.RouteKey=ID.RouteKey
		INNER JOIN dbo.OrderDetail OD ON OD.OrderDetailKey=RT.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH ON Oh.OrderKey=OD.OrderKey
	WHERE ID.Voucherkey IN ( SELECT DISTINCT VoucherKey FROM #VoucherKey );
	*/

	SET @OutPut=1;
END;

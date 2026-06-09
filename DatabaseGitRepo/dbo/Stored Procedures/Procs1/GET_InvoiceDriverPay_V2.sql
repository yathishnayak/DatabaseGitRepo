/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"InvoiceKey":38513}'
 
EXEC [GET_InvoiceDriverPay_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[GET_InvoiceDriverPay_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @InvoiceKey	INT;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @InvoiceKey = 0
	END
	ELSE
	BEGIN
		SELECT @InvoiceKey =  InvoiceKey
		FROM OpenJSON(@JSONString, '$')
		WITH (
			InvoiceKey			INT				'$.InvoiceKey'
		)
	END
 
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult = (
		select A.InvoiceKey, sum(isnull(A.VoucherAmount,0)) DriverPay from (
		select distinct ID.InvoiceKey, VH.voucherkey, VoucherAmount
		from Invoicedetail ID WITH(NOLOCK)
		inner join Routes R WITH(NOLOCK) on ID.OrderDetailKey = R.OrderDetailKey
		inner join VoucherDetail VD WITH(NOLOCK) on R.RouteKey = VD.RouteKey
		inner join VoucherHeader VH WITH(NOLOCK) on VD.Voucherkey = VH.VoucherKey
		where InvoiceKey = @InvoiceKey
	) A
	group by A.InvoiceKey
            
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	);
 
	SELECT @JSONResult AS JSONResult

	SET @Status = 1;
	SET @Reason = 'Success';

END
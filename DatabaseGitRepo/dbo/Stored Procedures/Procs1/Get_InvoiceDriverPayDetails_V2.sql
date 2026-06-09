/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"InvoiceKey" : 192218, "ContainerNo" : "YMLU8648441"}'
EXEC [Get_InvoiceDriverPayDetails_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Get_InvoiceDriverPayDetails_V2] -- Get_InvoiceDriverPayDetails 192218, 'CMAU4349715'
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
Begin

	IF ISNULL(@JSONString, '') = ''
			BEGIN
				SET		@Status = 0
				SET		@Reason = 'Parameters not found'
				RETURN
			END	

	DECLARE
		@InvoiceKey int = 24,
		@ContainerNo varchar(20) = 'BMOU2392710'

	SELECT 
		@InvoiceKey   = InvoiceKey,  
		@ContainerNo  = ContainerNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey  	INT				'$.InvoiceKey',  
		ContainerNo		VARCHAR(20)		'$.ContainerNo'
	)

	select  distinct IH.InvoiceKey, IH.InvoiceNo, ID.Container,R.RouteKey,L.LegID, 
	IH.InvoiceAmount, isnull(VH.VoucherKey,0) as VoucherKey,
	isnull(VH.VoucherNo,'NA') as VoucherNo, convert(varchar,VH.VoucherDate,101) VoucherDate,
	isnull(VD.ExtCost,0) as DPayTotal, isnull(RE.OExp,0) as OtherExp, 
	isnull(VS.Description,'Not Created') as StatusDescr, D.DriverID, ISNULL(D.FirstName,'')+' '+ISNULL(D.LastName,'') AS DriverName
	from InvoiceHeader IH WITH (NOLOCK)
	inner join Invoicedetail ID WITH (NOLOCK) on IH.InvoiceKey = Id.InvoiceKey
	inner join OrderDetail OD WITH (NOLOCK) on ID.OrderDetailKey = OD.OrderDetailKey
	left join Routes R WITH (NOLOCK) on OD.OrderDetailKey = R.OrderDetailKey
	left join Leg L WITH (NOLOCK) on R.LegKey = L.LegKey
	left join 
	(
		select voucherkey,  routekey, sum(extcost) extCost from VoucherDetail WITH (NOLOCK) group by voucherkey , routekey
	) VD on VD.RouteKey = R.RouteKey
	left join VoucherHeader VH WITH (NOLOCK) on VD.Voucherkey = VH.VoucherKey
	left join 
	(
		select Routekey, sum(OE.Qty * isnull(OE.UnitCost, I.UnitCost)) as OExp
		from OrderExpense OE WITH (NOLOCK)
		inner join Item I WITH (NOLOCK) on OE.Itemkey = I.ItemKey
		group by Routekey 
	) RE on R.RouteKey =RE.RouteKey and R.RouteKey is null
	left join VoucherStatus VS WITH (NOLOCK) on VH.StatusKey = VS.StatusKey
	INNER JOIN Driver D WITH (NOLOCK) ON D.DriverKey=R.DriverKey
	where IH.InvoiceKey =@InvoiceKey and OD.ContainerNo = TRIM(@ContainerNo)

	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
end
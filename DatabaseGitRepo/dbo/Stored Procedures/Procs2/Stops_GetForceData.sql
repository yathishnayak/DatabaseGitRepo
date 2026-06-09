
-- SELECT FromRouteKey, ToRouteKey,* FROM ORDERDETAILSTOPS  WHERE OrderDetailStopKey IN (678682,678683)
/*    

 declare @UserKey  INT=952,    
 --@JsonString  VARCHAR(MAX)='{"OrderDetailKey":226476,"PrevOrderDetailStopKey":678682,"NextOrderDetailStopKey":678683}',    
 --@JsonString  VARCHAR(MAX)='{"OrderDetailKey":226464,"PrevOrderDetailStopKey":678598,"NextOrderDetailStopKey":678599}',    
 @JsonString  VARCHAR(MAX)='{"OrderDetailKey":226144,"PrevOrderDetailStopKey":677315,"NextOrderDetailStopKey":677316}',    
 @IsDebug  BIT = 1,     @Status   BIT = 0 ,     @Reason   NVARCHAR(1000) = ''     
    
 exec [Stops_GetForceData] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output    
 select @Reason,@Status    
    
 */    
CREATE proc [dbo].[Stops_GetForceData]
(
	@UserKey  INT=512,  
	@JsonString  VARCHAR(MAX)='',  
	@IsDebug  BIT = 1,  
	@Status   BIT = 0 OUTPUT,  
	@Reason   NVARCHAR(1000) = '' OUTPUT  
)
as
begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	IF(ISNULL(@JsonString,'')='')  
	BEGIN  
		SET @Status=0;  
		SET @Reason='Parameter not found';  
		RETURN;  
	END  

	Declare @OrderDetailKey				int = 0,
			@PrevOrderDetailStopKey		int = 0 ,
			@NextOrderDetailStopKey		int = 0

	SELECT  @OrderDetailKey=OrderDetailKey ,
			@PrevOrderDetailStopKey = PrevOrderDetailStopKey,
			@NextOrderDetailStopKey = NextOrderDetailStopKey
	FROM OPENJSON(@JsonString, '$')  
	WITH(   
		OrderDetailKey			INT  '$.OrderDetailKey'  ,
		PrevOrderDetailStopKey  INT  '$.PrevOrderDetailStopKey'  ,
		NextOrderDetailStopKey	INT  '$.NextOrderDetailStopKey'  
	)

	IF(@OrderDetailKey = 0 or @PrevOrderDetailStopKey = 0 OR @NextOrderDetailStopKey = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Incorrect data. Please verify data sent ' + @JsonString
		RETURN
	END
	DECLARE @ROUTEKEY	INT = 0,
			@STATUSKEY	INT = 0,
			@STATUSNAME	VARCHAR(50) = '',
			@EXPENCECOUNT	INT = 0,
			@IsVoucherCreated	BIT = 0,
			@VOUCHERNO		VARCHAR(50),
			@VOUCHERDATE	DATE,
			@IsInvoiceCreated	BIT = 0,
			@INVOICENO			VARCHAR(50),
			@INVOICEDATE		DATE

	SELECT @ROUTEKEY = RouteKey, @STATUSKEY = RT.Status, @STATUSNAME = RS.Description
	FROM ROUTES RT WITH (NOLOCK) 
	INNER JOIN RouteStatus RS WITH (NOLOCK)  ON RT.Status = RS.Status
	WHERE FromODStopKey = @PrevOrderDetailStopKey AND ToODStopKey = @NextOrderDetailStopKey

	SELECT @IsVoucherCreated = 1, @VOUCHERNO = VH.VoucherNo, @VOUCHERDATE = VH.VoucherDate
	FROM RouteVouchers RV WITH (NOLOCK) 
	INNER JOIN VoucherHeader VH WITH (NOLOCK)  ON RV.VoucherKey = VH.VoucherKey
	WHERE RV.RouteKey = @ROUTEKEY

	SELECT  @IsInvoiceCreated = 1, @INVOICENO = IH.InvoiceNo, @INVOICEDATE = InvoiceDate
	FROM InvoiceContainers  IC WITH (NOLOCK) 
	INNER JOIN InvoiceHeader IH WITH (NOLOCK)  ON IC.InvoiceKey = IH.InvoiceKey
	WHERE IC.OrderDetailsKey = @OrderDetailKey
	
	Set @Status = case when @IsVoucherCreated = 1 OR @IsInvoiceCreated = 1 then 0 else 1 end
	set @Reason = case when @IsVoucherCreated = 1 then 'Voucher Created already (No. ' + @VOUCHERNO + ', dated: ' + convert(varchar,@VOUCHERDATE,101) +') \n' else '' end +
		Case when @IsInvoiceCreated = 1 then 'Invoice Created already (No. ' + @INVOICENO + ', dated: ' + convert(varchar,@INVOICEDATE,101) +') \n' else '' end
	

	SELECT @ROUTEKEY AS RouteKey,
			@STATUSKEY as StatusKey,
			@STATUSNAME as StatusName,
			@IsVoucherCreated as IsVoucherCreated,
			@VOUCHERNO as VoucherNo,
			@VOUCHERDATE as VoucherDate,
			@IsInvoiceCreated as IsInvoiceCreated,
			@INVOICENO as InvoiceNo,
			@INVOICEDATE as InvoiceDate,
			IsAllowChanges = @status,
			@Reason as Reason
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
end

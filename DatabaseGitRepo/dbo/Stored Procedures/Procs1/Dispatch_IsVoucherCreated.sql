
create Procedure [dbo].[Dispatch_IsVoucherCreated]  -- [Dispatch_IsVoucherCreated] 272 3 or 272
(
	@RouteKey			Int,
	@IsVoucherCreated	BIT OUTPUT
)
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @IsVoucherCreated=0  
		
	If EXISTS(	
		select 	VD.RouteKey  
		from VoucherDetail VD
		Where VD.RouteKey  = @RouteKey
	)
	BEGIN  
		SET @IsVoucherCreated=1  
	END  
	
End




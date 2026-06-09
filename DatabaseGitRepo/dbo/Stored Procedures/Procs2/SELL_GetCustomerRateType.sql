/*
Declare @InvoiceKey int = 0, @custKey int = 0, @OutputType varchar(5) = ''
exec  SELL_GetCustomerRateType @InvoiceKey, @custKey, @OutputType output
Select @OutputType
*/
CREATE Proc [dbo].[SELL_GetCustomerRateType] 
(
	@InvoiceKey		int = 0,
	@CustKey		int = 0,
	@OutputType		varchar(5) = 'NAC' output -- SMB /ENT / NAC / NA
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	-- reference only. To verify Customer and their segments
	--SELECT Cs.CustomerSegment, RT.RateType, C.CustKey
	--		FROM CUSTOMER C
	--		LEft JOIN CustomerRateType RT ON C.RateTypeKey = RT.RateTypeKey
	--		Left join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
	--order by Cs.CustomerSegment, RT.RateType, C.CustKey

	--Update CustomerSegments set CustomerSegment = 'ENT' where CustomerSegment = 'Enterprise'

	IF(ISNULL(@InvoiceKey,0) <> 0)
	BEGIN
		SELECT @CustKey = CustKey
		FROM InvoiceHeader 
		WHERE InvoiceKey = @InvoiceKey
	END
	--select @CustKey
	if(isnull(@CustKey,0) = 0)
	BEGIN
		SET @OutputType = 'NA'
		RETURN
	END

	IF(@CustKey > 0)
	BEGIN
		SELECT @OutputType = Case when isnull(c.RateTypeKey,0) = 0 then 'NAC'
			when C.RateTypeKey = 2 then 'NAC'
			when C.RateTypeKey = 1 then CS.CustomerSegment
			else 'NAC' end
		FROM CUSTOMER C
		LEFT JOIN CustomerRateType RT ON C.RateTypeKey = RT.RateTypeKey
		Left join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
		where C.CustKey = @CustKey
	END
END

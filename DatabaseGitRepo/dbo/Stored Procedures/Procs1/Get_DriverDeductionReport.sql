Create proc Get_DriverDeductionReport  -- EXEC Get_DriverDeductionReport  @voucherNo = 26
(
	@weekNumber		int = 0,
	@DriverKey		int	= 0,
	@ItemKey		int = 0,
	@VoucherNo		int = 0
)
as
BEGIN
	select H.WeekNumber, H.DriverKey, A.DriverID, a.OrgName, A.FirstName, A.LastName, A.City, A.OrgCity, A.OrgState, A.OrgCountry, A.OrgZipCode,
		D.ItemKey, I.ItemID, I.Description, D.UnitCost, D.Qty, D.ExtCost, H.DriverVoucherNumber, h.DriverVoucherdate, H.DriverVoucherAmount
	from DriverVoucherDeduction H
	inner join DriverVoucherDeductionDetail D on H.DriverVoucherKey = D.DriverVoucherKey
	inner join VDriverAll A on H.DriverKey = A.DriverKey
	inner join Item I on D.ItemKey = I.ItemKey
	where
		(@weekNumber = 0 OR H.WeekNumber = @weekNumber) AND
		(@DriverKey = 0  OR H.DriverKey = @DriverKey) And
		(@ItemKey = 0 OR D.ItemKey = @ItemKey ) AND
		(@VoucherNo = '' OR convert(int,replace(H.DriverVoucherNumber,'D-','')) = @VoucherNo)
 END

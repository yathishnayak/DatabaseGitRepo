
create function fn_Get_CustomerBaseRatePerContainer(
		@OrderDetailKey	int = 0,
		@ItemKey	int = 0
	)
	RETURNS DECIMAL(18,2)
	AS
	BEGIN
		DECLARE @rtnVal decimal(18,2) = 0
		select top 1 @rtnVal =  LI.UnitPrice
		from Routes R
		inner join OrderDetail OD on R.OrderDetailKey = OD.OrderDetailKey
		inner join Address A on R.DestinationAddrKey = A.AddrKey
		left join CustomerItemRate LI on A.CityKey = LI.CityKey
		where OD.OrderDetailKey = @OrderDetailKey and itemkey = @ItemKey and EffectiveDate<= getdate()
		order by EffectiveDate desc

		if(@rtnVal = 0)
		begin
			select top 1 @rtnVal = UnitCost from Item where ItemKey = @ItemKey
		end

		RETURN @RTNVAL
	END

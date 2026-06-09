
CREATE procedure GetYardStopOffLogic
(
	@OrderDetailKey		int,
	@OrderType		varchar(10)		= '' OUTPUT,
	@YardTypeChain	varchar(100)	= '' OUTPUT,
	@LocationChain	varchar(20)		= '' OUTPUT,
	@IsStopOff		bit				=  0 OUTPUT,
	@IsShuttle		bit				=  0 OUTPUT,
	@IsCustomerApplicable	Bit		=  0 OUTPUT
)
as
Begin
		Declare @CustKey	int = 0
		Select Custkey, Custname into #ExcemptCustomers from Customer where Custname like '%Amazon%'

		select LegNo, FromLocation, ToLocation, LegType, isnull(YardType,ToLocation) as YardType
		into #TempRoutes
		from  (
		select RT.legno, 
			case L.FromLocation when 'Depot' then 'Yard' when 'Shipper' then 'Consignee' when 'Warehouse' then 'Yard' 
				else L.FromLocation End as FromLocation, 
			case L.ToLocation when 'Depot' then 'Yard' when 'Shipper' then 'Consignee' when 'Customer' then 'Consignee' 
				when 'Warehouse' then 'Yard' when 'Scale' then 'Yard' 
				else L.ToLocation End as ToLocation, 
			L.LegType, 
			YardType  
		from routes RT  WITH (NOLOCK)
		inner join OrderDetail OD  WITH (NOLOCK) on Rt.OrderDetailKey = Od.OrderDetailKey
		inner join Leg L  WITH (NOLOCK) on Rt.LegKey = L.LegKey
		LEft join Yard Y WITH (NOLOCK) on Rt.DestinationAddrKey = Y.AddrKey and L.ToLocation in ('Depot','Yard','Warehouse')
		where Rt.orderdetailkey = @OrderDetailKey
		) A
		order by LegNo

		select @OrderType = Ot.OrderType, @custkey = OH.CustKey
		from OrderDetail OD  WITH (NOLOCK)
		LEft join OrderType OT WITH (NOLOCK) on OD.OrderTypeKey = OT.OrderTypeKey
		Inner join Orderheader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey
		where OrderDetailKey = @OrderDetailKey

		if((Select count(1) from #ExcemptCustomers where Custkey = @custkey) > 0 )
		Begin
			Set @IsCustomerApplicable = 0
		End
		Else
		Begin
			Set @IsCustomerApplicable = 1
		End

		SELECT @LocationChain = 
		  LEFT((SELECT FromLocation FROM #TempRoutes WHERE legno = 1), 1)
		  + '-' +
		  (SELECT STRING_AGG(LEFT(ToLocation,1), '-') WITHIN GROUP (ORDER BY legno)
		   FROM #TempRoutes) ;

		SELECT @YardTypeChain = 
		  (SELECT FromLocation FROM #TempRoutes WHERE legno = 1)
		  + '-' +
		  (SELECT STRING_AGG(YardType, '-') WITHIN GROUP (ORDER BY legno)
		   FROM #TempRoutes) ;

		Select @IsShuttle = Case when count(1) > 0 then convert(bit, 1) else Convert(Bit,0) end 
			from #TempRoutes where LegType = 'Shuttle'
		Select @IsStopOff = Case when count(1) > 0 then convert(bit, 1) else Convert(Bit,0) end 
			from #TempRoutes where LegType = 'Stop-Off'
		--select @YardTypeChain, @LocationChain
End

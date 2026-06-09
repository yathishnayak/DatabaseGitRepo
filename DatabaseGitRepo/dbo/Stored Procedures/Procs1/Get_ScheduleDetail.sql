


--select * from orderdetail where containerno like 'BNSF1111%'
CREATE PROCEDURE [dbo].[Get_ScheduleDetail]   -- Get_ScheduleDetail 183
@OrderDetailKey INT=169
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @PickupLocation		VARCHAR(100)
	DECLARE @DeliveryLocation	VARCHAR(100)
	DECLARE @PickupAddrKey		INT
	DECLARE @DeliveryAddrKey	INT

	DECLARE @PickupAddressName	VARCHAR(100)
	DECLARE @PickupAddress1	VARCHAR(100)
	DECLARE @PickupCity	VARCHAR(100)
	DECLARE @PickupState	VARCHAR(100)
	DECLARE @PickupCountry	VARCHAR(100)
	DECLARE @PickupZipcode	VARCHAR(100)

	DECLARE @DeliveryAddressName	VARCHAR(100)
	DECLARE @DeliveryAddress1	VARCHAR(100)
	DECLARE @DeliveryCity	VARCHAR(100)
	DECLARE @DeliveryState	VARCHAR(100)
	DECLARE @DeliveryCountry	VARCHAR(100)
	DECLARE @DeliveryZipcode	VARCHAR(100)

	SELECT	@PickupAddrKey= SR.AddrKey, 
			@PickupAddressName = SR.AddrName ,
			@PickupAddress1 = SR.Address1 ,
			@PickupCity= SR.City ,
			@PickupState= SR.[State] ,
			@PickupZipcode =SR.ZipCode ,
			@PickupCountry= SR.Country ,
			@DeliveryAddrKey= DT.AddrKey  ,
			@DeliveryAddressName=DT.AddrName ,
			@DeliveryAddress1 =DT.Address1 ,
			@DeliveryCity=DT.City ,
			@DeliveryState=DT.[State] ,
			@DeliveryZipcode=DT.ZipCode ,
			@DeliveryCountry=DT.Country 
	FROM dbo.OrderDetail OD 	
		LEFT JOIN dbo.[Address] SR ON SR.AddrKey=OD.SourceAddrKey
		LEFT JOIN dbo.[Address] DT ON DT.AddrKey=OD.DestinationAddrKey
	WHERE OrderDetailKey= @OrderDetailKey;	

	SELECT 
		RT.OrderDetailkey,	
		RT.RouteKey,		
		LT.LegTypeID AS LegType,
		RT.SourceAddrKey AS Pickup,
		RT.DestinationAddrKey AS Delivery,
		Sour.AddrName AS FromLocation, 
		Dst.AddrName AS ToLocation ,
		--CONVERT(DateTime, SWITCHOFFSET(RT.PickupDateFrom, DATEPART(TZOFFSET, RT.PickupDateFrom AT TIME ZONE 'Pacific Standard Time'))) as PickupDateFrom, 
		--CONVERT(DateTime, SWITCHOFFSET(RT.PickupDateTo, DATEPART(TZOFFSET, RT.PickupDateTo AT TIME ZONE 'Pacific Standard Time'))) as PickupDateTo, 
		--CONVERT(DateTime, SWITCHOFFSET(RT.DeliveryDateFrom, DATEPART(TZOFFSET, RT.DeliveryDateFrom AT TIME ZONE 'Pacific Standard Time'))) as DeliveryDateFrom, 
		--CONVERT(DateTime, SWITCHOFFSET(RT.DeliveryDateTo, DATEPART(TZOFFSET, RT.DeliveryDateTo AT TIME ZONE 'Pacific Standard Time'))) as DeliveryDateTo, 
		RT.PickupDateFrom,
		RT.PickupDateTo,
		RT.DeliveryDateFrom,
		RT.DeliveryDateTo,
		isnull(RT.ConfirmationNo,'') ConfirmationNo,
		isnull(RT.DelConfirmationNo,'') DelConfirmationNo,
		L.LegID as LegDescription,
		L.LegKey ,
		L.LegTypeKey,
		RT.LegNo,
		CASE WHEN IV.Orderdetailkey IS NOT NULL OR V.RouteKey IS NOT NULL THEN 0 ELSE 1 END AS [CanDelete],
		--@PickupAddressName as PickupAddressName, 
		--		@PickupAddress1 as PickupAddress1,
		--	@PickupCity as PickupCity,
		--	@PickupState as PickupState,
		--	@PickupZipcode as PickupZipcode ,
		--	@PickupCountry as PickupCountry,
		--	@DeliveryAddrKey as DeliveryAddrKey,
		--	@DeliveryAddressName as DeliveryAddressName,
		--	@DeliveryAddress1 as DeliveryAddress1,
		--	@DeliveryCity as DeliveryCity,
		--	@DeliveryState as DeliveryState,
		--	@DeliveryZipcode as DeliveryZipcode,
		--	@DeliveryCountry as DeliveryCountry
		
		Sour.AddrName as PickupAddressName, 
				Sour.Address1 as PickupAddress1,
			Sour.City as PickupCity,
			Sour.[State] as PickupState,
			Sour.ZipCode as PickupZipcode ,
			Sour.Country as PickupCountry,
			Sour.AddrKey  PickupAddrKey,
			Dst.AddrKey  DeliveryAddrKey,
			Dst.AddrName as DeliveryAddressName,
			Dst.Address1 as DeliveryAddress1,
			Dst.City as DeliveryCity,
			Dst.[State] as DeliveryState,
			Dst.ZipCode as DeliveryZipcode,
			Dst.Country as DeliveryCountry
			, RT.Status
			, case when RT.Status in (1,2) then 0 else 1 end as CanDisable
			, RT.IsDryRun

	FROM  	
	 dbo.[Routes] RT
		LEFT JOIN  dbo.Leg L		ON L.LegKey=RT.LegKey
		LEFT JOIN  dbo.LegType LT	ON LT.LegtypeKey=L.LegTypeKey
		LEFT JOIN  dbo.[Address] Sour ON Sour.AddrKey=RT.SourceAddrKey
		LEFT JOIN  dbo.[Address] Dst ON Dst.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ( SELECT DISTINCT Orderdetailkey FROM Invoicedetail ) IV ON IV.OrderDetailKey=RT.OrderDetailKey
		LEFT JOIN ( SELECT DISTINCT RouteKey FROM VoucherDetail) V ON V.RouteKey=RT.RouteKey		
	WHERE  RT.Orderdetailkey =@OrderDetailKey
	ORDER BY RT.OrderDetailkey,	RT.RouteKey


END;



CREATE PROCEDURE [dbo].[GET_ContainerLeg]
/*
Scheduler Screen
*/
@LegTypeKey		INT=0,
@OrderDetailKey	INT=0
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
	DECLARE @VesselETA		DateTime

	--SET @PickupLocation= (	SELECT AD.AddrName
	--						FROM dbo.OrderDetail OD 
	--							INNER JOIN dbo.[Address] AD ON AD.AddrKey=OD.SourceAddrKey
	--						WHERE OrderDetailKey=@OrderDetailKey 
	--					 );

	--					 SET @PickupAddrKey= (	SELECT AD.AddrKey
	--						FROM dbo.OrderDetail OD 
	--							INNER JOIN dbo.[Address] AD ON AD.AddrKey=OD.SourceAddrKey
	--						WHERE OrderDetailKey=@OrderDetailKey 
	--					 );

	--SET @DeliveryLocation= (SELECT AD.AddrName
	--						FROM dbo.OrderDetail OD 
	--							INNER JOIN dbo.[Address] AD ON AD.AddrKey=OD.DestinationAddrKey
	--						WHERE OrderDetailKey=@OrderDetailKey 
	--					);
						
	--SET @DeliveryAddrKey= (SELECT AD.AddrKey
	--						FROM dbo.OrderDetail OD 
	--							INNER JOIN dbo.[Address] AD ON AD.AddrKey=OD.DestinationAddrKey
	--						WHERE OrderDetailKey=@OrderDetailKey 
	--					);

	--SELECT C.LegKey,A.Instruction AS WorkFlow ,C.[Action],C.[Description], A.LegTypeKey,
	--		@PickupLocation AS PickUpLocation, @DeliveryLocation AS DeliveryLocation,@PickupAddrKey AS Pickup,@DeliveryAddrKey AS Delivery
	--FROM [LegType] A 
	--	  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey	
	--	  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
	--	WHERE S.StatusName='Active' AND A.LegtypeKey= @LegTypeKey
	--ORDER BY A.LegTypeKey;

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
			@DeliveryCountry=DT.Country ,
			@VesselETA = OD.VesselETA
	FROM dbo.OrderDetail OD 
		INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=OD.OrderKey
		LEFT JOIN dbo.[Address] SR ON SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN dbo.[Address] DT ON DT.AddrKey=OH.DestinationAddrKey
	WHERE OrderDetailKey= @OrderDetailKey;



	SELECT C.LegKey,A.Instruction AS WorkFlow ,C.[Action],C.[Description], A.LegTypeKey,
			@PickupLocation AS PickUpLocation, @DeliveryLocation AS DeliveryLocation,@PickupAddrKey AS Pickup,@DeliveryAddrKey AS Delivery,
			@PickupAddressName as PickupAddressName, 
				@PickupAddress1 as PickupAddress1,
			@PickupCity as PickupCity,
			@PickupState as PickupState,
			@PickupZipcode as PickupZipcode ,
			@PickupCountry as PickupCountry,
			@DeliveryAddrKey as DeliveryAddrKey,
			@DeliveryAddressName as DeliveryAddressName,
			@DeliveryAddress1 as DeliveryAddress1,
			@DeliveryCity as DeliveryCity,
			@DeliveryState as DeliveryState,
			@DeliveryZipcode as DeliveryZipcode,
			@DeliveryCountry as DeliveryCountry,
			@VesselETA as VesselETA
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey	
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
		WHERE S.StatusName='Active' AND A.LegtypeKey= @LegTypeKey
	ORDER BY A.LegTypeKey;

END

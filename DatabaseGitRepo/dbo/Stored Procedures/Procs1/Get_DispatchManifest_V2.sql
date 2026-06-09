/** 
Declare 
	@UserKey		INT = 488,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"CustKey" : 3232}'
	EXEC [Get_DispatchManifest_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status Status, @Reason Reason
**/


CREATE PROCEDURE [dbo].[Get_DispatchManifest_V2]
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN 
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CustomerKey					int = 0,
	        @ScheduledPickupDateFrom		Datetime = '2022-01-01', -- Pickup Date From
	        @ScheduledPickupDateTo			DateTime = '2050-12-31', -- Pickup Date To
	        @ActualPickupDateFrom			Datetime = '2022-01-01', -- Delivery Date From
	        @ActualPickupDateTo				DateTime = '2050-12-31'  -- Delivery Date To 

			
			IF ISNULL(@JSONString,'') = '' OR ISJSON(@JSONString) <> 1
			BEGIN
				  SET @Status = 0
				  SET @Reason = 'Invalid JSON input'
                  RETURN
			END

	SELECT @CustomerKey = CustomerKey, @ScheduledPickupDateFrom = ScheduledPickupDateFrom, @ScheduledPickupDateTo = ScheduledPickupDateTo, @ActualPickupDateFrom = ActualPickupDateFrom, 
			@ActualPickupDateTo=ActualPickupDateTo
	from OPENJSON(@JSONString, '$')
	with (
			CustomerKey			            int			'$.CustKey',
			ScheduledPickupDateFrom			DATE        '$.ScheduledPickupDateFrom',
			ScheduledPickupDateTo		    DATE        '$.ScheduledPickupDateTo',
			ActualPickupDateFrom			DATE        '$.ActualPickupDateFrom',
			ActualPickupDateTo			    DATE        '$.ActualPickupDateTo'
			
		 )


	set @ScheduledPickupDateFrom = CONVERT(date,@ScheduledPickupDateFrom)
	set @ScheduledPickupDateTo = CONVERT(date,@ScheduledPickupDateTo+1)
	set @ActualPickupDateFrom = CONVERT(date,@ActualPickupDateFrom)
	set @ActualPickupDateTo = CONVERT(date,@ActualPickupDateTo+1)

	if(@ScheduledPickupDateFrom='2022-01-01' OR @ScheduledPickupDateFrom='' OR @ScheduledPickupDateFrom IS NULL)
	BEGIN
		set @ScheduledPickupDateFrom=GETDATE()- 60
	END
	if(@ScheduledPickupDateTo='2050-12-31' OR @ScheduledPickupDateTo='' OR @ScheduledPickupDateTo IS NULL)
	BEGIN
		set @ScheduledPickupDateTo=GETDATE()
	END
	if(@ActualPickupDateFrom='2022-01-01' OR @ActualPickupDateFrom='' OR @ActualPickupDateFrom IS NULL)
	BEGIN
		set @ActualPickupDateFrom=GETDATE()-60
	END
	if(@ActualPickupDateTo='2050-12-31' OR @ActualPickupDateTo='' Or @ActualPickupDateTo IS NULL)
	BEGIN
		set @ActualPickupDateTo=GETDATE()
	END

	set @ScheduledPickupDateFrom = CONVERT(date,@ScheduledPickupDateFrom)
	set @ScheduledPickupDateTo = CONVERT(date,@ScheduledPickupDateTo)
	set @ActualPickupDateFrom = CONVERT(date,@ActualPickupDateFrom)
	set @ActualPickupDateTo = CONVERT(date,@ActualPickupDateTo)

	print @ScheduledPickupDateFrom
	print @ScheduledPickupDateTo
	print @ActualPickupDateFrom
	print @ActualPickupDateTo

	select top 500 oh.OrderNo,od.ContainerNo,r.RouteKey,r.LegKey,l.LegID, --Convert(Varchar, r.ActualArrival,101) as Deliverydate,
	ISNULL(Convert(Varchar(16), r.DeliveryDateFrom,120),'') as Deliverydate,
	--convert(varchar,r.ScheduledPickupDate,101) as scheduledpickUP, 
	ISNULL(convert(varchar(16),r.PickupDateFrom,120),'') as scheduledpickUP,
	r.SourceAddrKey,
	--sa.AddrName as PickupName,
	REPLACE(REPLACE(REPLACE(sa.AddrName, CHAR(3), ''), CHAR(0), ''), CHAR(1), '') AS PickupName,
	--sa.Address1 as PickupAddress,
	REPLACE(REPLACE(REPLACE(sa.Address1, CHAR(3), ''), CHAR(0), ''), CHAR(1), '') AS PickupAddress,
	sa.City as PickupCity,sa.State as PickupState, sa.ZipCode as PickupZip,
	r.DestinationAddrKey,
	--da.AddrName as DeliverName,
	REPLACE(REPLACE(REPLACE(da.AddrName, CHAR(3), ''), CHAR(0), ''), CHAR(1), '') AS DeliverName,
	--da.Address1 as DeliverAddress,
	REPLACE(REPLACE(REPLACE(da.Address1, CHAR(3), ''), CHAR(0), ''), CHAR(1), '') AS DeliverAddress,
	da.city as DeliveryCity,da.state as DeliveryState,da.ZipCode as DeliveryZip,
	Convert(Varchar, r.ActualArrival,108) as DeliveryTime,d.DriverID,(d.FirstName + d.LastName) as DriverName,
	C.CustID, C.CustName, CASE WHEN R.Status=5 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsLegCompleted,
	(SELECT COUNT(1) FROM ContainerDocuments WHERE OrderDetailKey=od.OrderDetailKey) AS DocumentCount,
	isnull(csr.CsrName,'') as  CsrName,
	sa.Country AS PickupCountry,DA.Country AS DeliveryCountry, OCT.Description AS ContainerProperties
	from OrderHeader oh (nolock)
	Left join Customer C  with (nolock) on oh.CustKey = C.CustKey
	Inner join OrderDetail od (nolock) ON oh.OrderKey=od.OrderKey
	INNER JOIN Routes r (nolock) ON od.OrderDetailKey=r.OrderDetailKey
	Inner Join Address sa with(nolock) on r.SourceAddrKey = sa.AddrKey
	Inner Join Address da (nolock) On r.DestinationAddrKey=da.AddrKey
	Left Join Driver d (nolock) ON r.DriverKey=d.DriverKey
	Inner Join Leg l (nolock) On r.LegKey=l.LegKey
	LEFT JOIN RouteStatus Rs WITH (NOLOCK) ON RS.Status=R.Status
	LEFT JOIN CSR csr WITH (NOLOCK) ON csr.CsrKey=oh.CsrKey
	--inner join Legtype lg (nolock) On lg.LegtypeKey=l.LegTypeKey
	LEFT JOIN vOrderContainerTypes OCT WITH (NOLOCK) ON OCT.OrderDetailKey=OD.OrderDetailKey
	where 1=1  -- L.LegID like '%to consignee%'
		--and OrderNo like 'FL0%'--- this query is for flexport orders
		and (ISNULL(@CustomerKey,0) = 0 OR C.CustKey = @CustomerKey )
		--and (ISNULL(@ScheduledPickupDateFrom,convert(Date,'2022-01-01')) = convert(Date,'2022-01-01') 
		--	OR isnull(R.PickupDateFrom, '1/1/2022') >= @ScheduledPickupDateFrom) 
		--and (ISNULL(@ScheduledPickupDateTo,convert(Date,'2050-12-31')) = convert(Date,'2050-12-31') 
		--	OR isnull(R.PickupDateTo, '1/1/2022')  <= @ScheduledPickupDateTo) 
		and (ISNULL(@ScheduledPickupDateFrom,convert(Date,'2022-01-01')) = convert(Date,'2022-01-01') 
			OR isnull(R.PickupDateFrom, '1/1/2022') between @ScheduledPickupDateFrom and @ScheduledPickupDateTo ) 
		--and (ISNULL(@ActualPickupDateFrom,convert(Date,'2022-01-01')) = convert(Date,'2022-01-01') 
		--	OR isnull(R.DeliveryDateFrom, '1/1/2022')  between  @ActualPickupDateFrom) 
		--and (ISNULL(@ActualPickupDateTo,convert(Date,'2050-12-31')) = convert(Date,'2050-12-31') 
		--	OR isnull(R.DeliveryDateTo, '1/1/2022')   <= @ActualPickupDateTo)
		and (ISNULL(@ActualPickupDateTo,convert(Date,'2050-12-31')) = convert(Date,'2050-12-31') 
			OR isnull(R.DeliveryDateFrom, '1/1/2022')   between @ActualPickupDateFrom and  @ActualPickupDateTo)
			and od.Status<>1
	order by r.DeliveryDateFrom Desc

	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'

END

/*
SELECT		A.DataKey,A.ContainerKey, B.StopKey, C.TMS_SourceAddrKey
FROM		Integration_JCB.dbo.CNB_ContainerList A
INNER JOIN	Integration_JCB.dbo.CNB_StopList B ON A.ContainerKey = B.ContainerKey AND B.stopType = 'Returned To'
INNER JOIN	Integration_JCB.dbo.CNB_StopList C ON A.ContainerKey = C.ContainerKey AND C.stopType = 'Ship From' 
WHERE		DataKey = 1
FOR JSON PATH
*/

CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_CNB_Return] -- TMS_integration_InsertOrder_CNB_Return 1
(
	@JsonData			NVARCHAR(MAX) = '[{"DataKey":1,"ContainerKey":1,"StopKey":9,"TMS_SourceAddrKey":21466}]'
)
AS
BEGIN

DECLARE @SiteId VARCHAR(20),   @ContainerKey INT, @DelStopKey INT, @RouteKey INT, @TMS_LegKey INT, @DataKey INT

DECLARE @OrdDetailKey INT,@OrderKey INT,@RTSourceAddrKey INT,@RTDeliveryAddrKey INT, @UserKey INT

SELECT		@DataKey = Datakey, @ContainerKey = ContainerKey, @DelStopKey = StopKey, @RTDeliveryAddrKey = TMS_SourceAddrKey, @RTSourceAddrKey = TMS_DestinationAddrKey
FROM		OPENJSON(@JsonData, '$')
			WITH (
				DataKey					INT		'$.DataKey',
				ContainerKey			INT		'$.ContainerKey',
				StopKey					INT		'$.StopKey',
				TMS_SourceAddrKey		INT		'$.TMS_SourceAddrKey',
				TMS_DestinationAddrKey	INT		'$.TMS_DestinationAddrKey')

SET @SiteId = 'CNB'
SET	@TMS_LegKey = 19
SET @OrderKey = (SELECT TMS_OrderKey FROM JCBDB_Live.dbo.TMS_Integration_Header WHERE SiteID = 'CNB' AND DataKey = @DataKey )
SET @OrdDetailKey = (SELECT OrderDetailKey FROM JCBDB_Live.dbo.OrderDetail WHERE OrderKey = @OrderKey)
SET @UserKey = 714

INSERT INTO		JCBDB_Live.dbo.[Routes]
				(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], 
					[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
					[SwitchTo], 
					[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
					[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
					[Status], [DriverKey], [ActualDeparture], [ActualArrival], 
					[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey , LastUpdateDate
					--,ScheduledDeparture, ScheduledArrival, ScheduledPickupDate, PickupDateFrom, DeliveryDateFrom
				)
select			@OrdDetailKey,@OrderKey,@TMS_LegKey,1,@RTSourceAddrKey,
				null,NULL,null,null,null,
				null,
				NULL,NULL,NULL,NULL,
				NULL,NULL,@RTDeliveryAddrKey,null,null,
				1,null, NULL,NULL,
				NULL,NULL, @UserKey,GETDATE(),NULL , Getdate()
				--,@SchPickup, @SchDeliv, @SchPickup, @SchPickup, @SchDeliv
Set				@RouteKey = SCOPE_IDENTITY()


insert into JCBDB_Live.dbo.TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

---------------------------------Patch-----------------------------------------
DELETE		IR
FROM		TMS_Integration_Routes IR
LEFT JOIN	Integration_JCB.dbo.CNB_StopList SL ON IR.ContainerKey = SL.ContainerKey AND IR.StopKey = SL.StopKey
WHERE		IR.DataKey = @DataKey AND SiteID = 'CNB' AND SL.StopKey IS NULL
----------------------------------------------------------------------------------------------

END

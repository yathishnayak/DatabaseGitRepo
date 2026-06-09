/****** Object:  StoredProcedure [dbo].[GetOrderDetils_For_ReopenLeg]    Script Date: 27-04-2026 18:40:16 ******/
/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000)
SET @JSONString ='{"ContainerNo":"TCNU2407217"}'
 
EXEC [GetOrderDetils_For_ReopenLeg] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
SELECT @Status Status, @Reason Reason 

**********
--API Payload
{
  "userKey": 1,
  "jsonString": "{\"ContainerNo\":\"BMOU5512681\"}",
  "status": true,
  "reason": "",
  "fileName": null,
  "procName": "",
  "outputType": null
}

*/

CREATE PROCEDURE [dbo].[GetOrderDetils_For_ReopenLeg]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END
	--CREATE TABLE #ContainerNo
	--(
	--	Containerno			VARCHAR(20)
	--)
	--INSERT INTO #ContainerNo(Containerno)

	DECLARE @ContainerNo NVARCHAR(100) = ''

	SELECT @ContainerNo=ContainerNo
	FROM OPENJSON(@JsonString, '$')
	WITH (
			ContainerNo			VARCHAR(20)'$.ContainerNo'
		)

	IF(ISNULL(@Containerno, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Containerno not found in parameters'
		RETURN
	END

	SELECT OrderDetailKey
		,OH.OrderKey
		,od.ContainerNo
		,ConfirmationNo
		,Chassis
		,ApptDateFrom
		,ApptDateTo
		,OD.Status
		,LastFreeDay
		,OD.HoldDate
		,ReturnDate
		,ReturnTime
		,PickupTime
		,DropOffTime
		,PickupDate
		,DropOffDate
		,CutOffDate
		,RouteKey
		,ActualPickupTime
		,ActualDropOffTime
		,ActualPickupDate
		,ActualDropOffDate
		,ContainerID
		,IsHazardus
		,OD.IsOverWeight
		,OD.IsTriaxle
		,NeedtobeScaled
		,WeightUnit
		,IsEmpty
		,DriverNotes
		,SchedulerNotes
		,IsTMF
		,CompleteDate
		,VesselETA
		,isStreetTurn
		,StreetTurnSetUser
		,StreetTurnSetDate
		,IsLinked
		,LinkedContainerNo
		,LinkedOrderDetailKey
		,ContainerStatusKey
		,CurrentRouteKey
		,TotalLegs
		,CurrentLegNo
		,OpenLegs
		,TMFCheckOff
		,CTFCheckOff
		,SizeCheckOff
		,OrderNo
		,CustID+' - '+CustName AS CustName
		,[Description] AS ContainerStatus
		,CAST(0 AS INT) AS SelectedStatusKey
		,Routes=(   SELECT R.RouteKey,L.LegID 
					FROM [Routes] R  WITH (NOLOCK)
					INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=R.LegKey
					WHERE R.OrderDetailKey=OD.OrderDetailKey and R.RouteKey = OD.CurrentRouteKey
					FOR JSON PATH)
		,SelectStatus = (Select Status, Description
					from RouteStatus  WITH (NOLOCK)
					where status in (2, 4) for JSON PATH)
	FROM OrderDetail OD  WITH (NOLOCK)
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	INNER JOIN OrderDetailStatus ODS WITH (NOLOCK) ON ODS.Status=OD.Status
	--INNER JOIN #ContainerNo CN on OD.ContainerNo = CN.Containerno
	WHERE 
		OD.ContainerNo = @ContainerNo
		AND OD.Status IN ( 12,14,6)
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
	--DROP TABLE #ContainerNo
END

select * from orderdetailstatus
select * from orderdetail where status in (14)
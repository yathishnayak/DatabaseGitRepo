/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"ContainerNo" : "BMOU6772410"}',
	@Status	BIT = 0, 
	@JSONOutput   NVARCHAR(MAX) = '', 
	@Reason	VARCHAR(100)=''
	EXEC [Scheduler_MasScheduleContainerList] @UserKey,@JSONString, @JSONOutput OUTPUT, @Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Scheduler_MasScheduleContainerList]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='[{"ContainerNo" : "IMPT2511951:IMPT2511888"}]',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET FMTONLY OFF
    SET ARITHABORT ON;

    IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status = 0;
	    SET @Reason = 'Parameter missing';
	END

	DECLARE @ContainerNo   VARCHAR(MAX)

	SELECT @ContainerNo = ContainerNo
	FROM OPENJSON(@JSONString, '$')
	WITH( 
	     ContainerNo   VARCHAR(MAX)  '$.ContainerNo'
        ) 
   
    CREATE TABLE #ContainerNos(
		ContainerNo   VARCHAR(MAX)
	)

	IF(ISNULL(@ContainerNo,'') <> '')
	BEGIN
		INSERT INTO #ContainerNos(ContainerNo)
		SELECT VALUE FROM Fn_SplitParamCol(@ContainerNo)
	END

	SELECT OD.ContainerNo,OD.OrderDetailKey,ODS.OrderDetailStopKey,ODS.StopName,ODS.DropOrLive,ODS.RefNo,ODS.LocationType,
		   ODS.StopTypeKey, ODS.SchedulePickupDate,
		   CONVERT(CHAR(5), ODS.SchedulePickupDateTo, 108) SchedulePickupDateTo,
		   --convert(char(5),ScheduleDeliveryDateTo, 108) ScheduleDeliveryToTime
		   ODS.ScheduleDeliveryDate,
		   --ODS.ScheduleDeliveryDateTo,
		   CONVERT(CHAR(5), ODS.ScheduleDeliveryDateTo, 108) ScheduleDeliveryDateTo,
		   ODS.StopAddrKey,	   
		   OD.TMFCheckOff,OD.CTFCheckOff,OD.SizeCheckOff,OD.IsTMFJCTPaid,OD.IsTMFCustomerPaid ,OD.IsCTFJCTPaid,OD.IsCTFCustomerPaid
	FROM OrderDetail OD WITH (NOLOCK)
	LEFT JOIN OrderDetailStops ODS WITH (NOLOCK) ON OD.OrderDetailKey=ODS.OrderDetailKey
	LEFT JOIN Address A WITH (NOLOCK) ON ODS.StopAddrKey=A.AddrKey
	WHERE (ISNULL(@ContainerNo,'') = '' OR OD.ContainerNo IN (SELECT ContainerNo FROM #ContainerNos)) AND
	       ISNULL(ODS.StopAddrKey,0) <> 0 AND ODS.ActualDeliveryDate IS NULL  AND ODS.ActualPickupDate IS NULL AND
		   ODS.StopTypeKey IN (1,3,5) AND ISNULL(ODS.IsDryRunCustomer, 0) = 0 AND ISNULL(ODS.IsDryRunPort, 0) = 0
	   
    FOR JSON PATH;

	SET  @Status = 1
	SET  @Reason = 'Success'
END		


--SELECT TOP 100 * FROM OrderDetail ORDER BY OrderDetailKey DESC
--select top 10 * from OrderDetailStops where ISNULL(StopAddrKey,0) = 0 

/*
48019
48219
48378
48441
48625
48653
49320
49539
50764
51365
*/
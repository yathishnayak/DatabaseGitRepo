CREATE  PROCEDURE [dbo].[Scheduler_MasScheduleContainerList_ByContainerAndODKey]
(
    @UserKey      INT = 512,
    @JSONString   NVARCHAR(MAX),
    @JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
    @Status       BIT = 0 OUTPUT,
    @Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;
	
    IF ISNULL(@JSONString,'') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameter missing';
        RETURN;
    END

  
    CREATE TABLE #ContainerOD (ContainerNo VARCHAR(50),OrderDetailKey INT);

    INSERT INTO #ContainerOD (ContainerNo, OrderDetailKey)
    SELECT 
        ContainerNo,
        CAST(OrderDetailKey AS INT)
    FROM OPENJSON(@JSONString)
    WITH (
        ContainerNo VARCHAR(50) '$.ContainerNo',
        OrderDetailKey INT '$.OrderDetailKey'
    );

    SELECT  OD.ContainerNo, OD.OrderDetailKey, ODS.OrderDetailStopKey, ODS.StopName, ODS.DropOrLive, ODS.RefNo,
		    ODS.LocationType,ODS.StopTypeKey, ODS.SchedulePickupDate, 
            --ODS.SchedulePickupDateTo, 
            CONVERT(CHAR(5), ODS.SchedulePickupDateTo, 108) SchedulePickupDateTo,
            ODS.ScheduleDeliveryDate,
            --ODS.ScheduleDeliveryDateTo,
            CONVERT(CHAR(5), ODS.ScheduleDeliveryDateTo, 108) ScheduleDeliveryDateTo,
            ODS.StopAddrKey,
		    OD.TMFCheckOff,OD.CTFCheckOff,OD.SizeCheckOff,OD.IsTMFJCTPaid,OD.IsTMFCustomerPaid ,OD.IsCTFJCTPaid,OD.IsCTFCustomerPaid
    FROM OrderDetail OD WITH (NOLOCK)
			INNER JOIN OrderDetailStops ODS WITH (NOLOCK)  ON OD.OrderDetailKey = ODS.OrderDetailKey
			LEFT JOIN Address A WITH (NOLOCK) ON ODS.StopAddrKey = A.AddrKey
			INNER JOIN #ContainerOD temp  ON OD.ContainerNo = temp.ContainerNo  AND OD.OrderDetailKey = temp.OrderDetailKey
    WHERE ISNULL(ODS.StopAddrKey,0) <> 0 AND ODS.ActualDeliveryDate IS NULL AND ODS.ActualPickupDate IS NULL
					AND ODS.StopTypeKey IN (1,3,5) AND ISNULL(ODS.IsDryRunCustomer,0) = 0 AND ISNULL(ODS.IsDryRunPort,0) = 0 FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';
END
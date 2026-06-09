
CREATE PROCEDURE [dbo].[Get_ContainerDetail]
@OrderDateFrom		DATE='01/01/2020',
@OrderDateTo		DATE='01/12/2099',
@CSRKey				INT =0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF @OrderDateFrom IS NULL OR @OrderDateFrom='1900-01-01 00:00:00.000'
	BEGIN
		SET @OrderDateFrom= GETDATE()-30
	END;
	IF @OrderDateTo IS NULL OR @OrderDateTo='1900-01-01 00:00:00.000'
	BEGIN
		SET @OrderDateTo= GETDATE()
	END;
	   
	SELECT
		OH.OrderKey,
		OD.OrderDetailkey,
		RT.RouteKey,
		CR.CsrName,		
		OD.ContainerNo,
		OD.ContainerID,		
		OD.ContainerSizeKey,
		CS.[Description] AS ContainerDescription,
		OD.LastFreeDay,
		RT.PickupDateFrom AS PickupDate ,
		OD.PickupTime,		
		RT.DeliveryDateFrom AS DropOffDate,
		OD.DropOffTime,
		OSD.[Description] AS [Status],
		OT.OrderType,
		OH.BillOfLading,
		OH.BookingNo,
		CS.[Description] AS ContainerSize,
		PT.[Description] AS [Priority],	
		SR.City			 AS PickupLocation,
		DT.City			 AS DeliveryLocation,
		OD.VesselETA	 As VesselETA,
		CASE 
			WHEN OD.status = 1
			THEN 'Proceed to Schedule' 
			WHEN OD.status = 3 
			THEN 'Complete Schedule'           
			WHEN OD.status = 4
			THEN 'Confirm/Complete Schedule' 
			WHEN OD.status = 5
			THEN 'Process Dispatch' 
			WHEN OD.status = 7 
			THEN 'Complete Dispatch'   
			WHEN OD.status = 8 
			THEN 'Confirm/Complete Dispatch'  
			WHEN OD.status = 9 
			THEN 'Approve Invoice/Driver Pay'  
			WHEN OD.status = 10 
			THEN 'Create Invoice'  END AS NextAction
	FROM  dbo.OrderDetail OD
		INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey=OD.OrderKey
		INNER JOIN  dbo.OrderDetailStatus OSD  ON OSD.[Status] = OD.[Status]
		INNER JOIN dbo.ContainerSize CS	ON CS.ContainerSizeKey = OD.ContainerSizeKey		
		LEFT JOIN [Routes] RT			ON RT.RouteKey=OD.RouteKey		
		LEFT JOIN dbo.CSR CR			ON CR.CsrKey=OH.CsrKey
		LEFT JOIN Driver DR				ON DR.DriverKey=RT.DriverKey
		LEFT JOIN  dbo.OrderType OT		ON OT.OrderTypeKey = OH.OrdertypeKey 
		LEFT JOIN [Address] SR			ON	SR.AddrKey=OD.SourceAddrKey
		LEFT JOIN [Address] DT			ON	DT.AddrKey=OD.DestinationAddrKey
		LEFT JOIN  dbo.[Priority] PT	ON PT.PriorityKey=OH.PriorityKey
	WHERE   
			( @OrderDateFrom	IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND ( @OrderDateTo		IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate<=@OrderDateTo)		
		AND ( ISNULL(@CSRKey,0)=0 OR OH.CsrKey= @CSRKey );		
END;

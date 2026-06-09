
CREATE PROCEDURE [dbo].[Get_DeliverOrderReport] --Get_DeliverOrderReport 176369,581706
 (
	@Containerkey int = 0,
	@RouteKey     int = 0
 )
 AS
 BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;



 SELECT	OD.OrderDetailKey, CurrentRouteKey, OH.CreateDate, OH.OrderNo, D.DriverID+'-'+ D.FirstName+' '+D.LastName AS CarrierName,R.DeliveryDateFrom,
       SA.AddrKey AS SourAddrKey, SA.AddrName AS SourAddrName, SA.Address1 AS SourAddress1, SA.City AS SourCity, SA.State AS SourState, SA.ZipCode As SourZipCode, DA.Country AS SourCountry,
       DA.AddrKey AS DestAddrKey, DA.AddrName As DestAddrName, DA.Address1 AS DestAddress1, DA.City AS DestCity, DA.State AS DestState, DA.ZipCode AS DestZipCode, DA.Country AS DestCountry,
	   ISNULL(R.DriverInstructions,OD.DriverNotes) DriverNotes, OD.ContainerNo, CS.[Description] As ContainerSize, OD.SealNo, OD.[Weight], WU.WeightUnit,isnull(OH.ReleaseNo,'NA') as ReleaseNo,R.chassisNo
		
      FROM OrderDetail OD   WITH (NOLOCK) 
		INNER JOIN  OrderHeader OH	  WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey 				 		
		INNER JOIN [Routes] R WITH(NOLOCK) ON  OD.OrderDetailKey=R.OrderDetailKey
		LEFT JOIN  ContainerSize CS  WITH (NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey
		LEFT JOIN [Address] SA WITH(NOLOCK) ON SA.AddrKey = R.SourceAddrKey
		LEFT join [Address] DA with(nolock) on DA.AddrKey = R.DestinationAddrKey		
		LEft JOIN Driver D ON D.DriverKey=R.DriverKey
		LEFT JOIN WeighUnit WU with(nolock) ON WU.WeightUnitKey = OD.WeightUnit
		--LEFT JOIN Chassis CH ON CH.chassisKey = R.ChassisKey
	WHERE OD.OrderDetailKey = @Containerkey AND  R.RouteKey = @RouteKey	
 FOR JSON PATH, without_array_wrapper
 END;

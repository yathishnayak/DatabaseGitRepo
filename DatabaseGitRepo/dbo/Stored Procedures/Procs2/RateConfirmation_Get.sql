
CREATE PROCEDURE [dbo].[RateConfirmation_Get]  -- RateConfirmation_Get 103912,368014
(
  @OrderDetailKey int = 0,
  @RouteKey     int = 0
)
AS
BEGIN
 SET NOCOUNT ON;
 SET FMTONLY OFF;

	SELECT OD.OrderDetailKey,OH.OrderKey,OH.OrderNo,	        
		(
		   SELECT R.RouteKey,OD.ContainerNo, L.LegID,OH.ReleaseNo,R.ChassisNo, 
			    D.DriverID+'-'+ D.FirstName+' '+D.LastName AS CarrierName, OH.BaseRateAmount,OD.Weight,R.DeliveryDateFrom,
			   SA.AddrKey AS SourAddrKey,SA.AddrName AS SourAddrName ,SA.Address1 AS SourAddress1 ,SA.City AS SourCity,SA.State AS SourState,SA.ZipCode AS SourZipCode,sa.Country as SourCountry,
			   DA.AddrKey AS DestAddrKey,DA.AddrName AS DestAddrName ,DA.Address1 AS DestAddress1 ,DA.City AS DestCity ,DA.State AS DestState ,DA.ZipCode AS DestZipCode,da.Country as DestCountry,
			  r.Carrierrate,
			  (
				 SELECT I.ItemID, I.UnitCost 
					from Item I 
					inner join OrderExpense OE with (nolock) on OE.Itemkey = I.ItemKey AND RouteKey=r.RouteKey
					FOR JSON PATH
			   ) AS Expenses

			FROM Routes R 
			LEFT JOIN LEG L WITH(NOLOCK) ON L.LegKey = R.LegKey		   
			LEFT JOIN DRIVER D WITH(NOLOCK) ON D.DriverKey = R.DriverKey	
			LEFT JOIN ADDRESS sa(NOLOCK) ON sa.AddrKey  = R.SourceAddrKey
			LEFT JOIN Address DA WITH(NOLOCK) ON DA.AddrKey = r.DestinationAddrKey
			WHERE R.RouteKey = @RouteKey			
			FOR JSON PATH
		 ) AS Routes

		 FROM OrderHeader OH WITH(NOLOCK)
		 LEFT JOIN OrderDetail OD WITH(NOLOCK) ON OD.OrderKey = OH.OrderKey	
		WHERE OD.OrderDetailKey = @OrderDetailKey 
		FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
 END

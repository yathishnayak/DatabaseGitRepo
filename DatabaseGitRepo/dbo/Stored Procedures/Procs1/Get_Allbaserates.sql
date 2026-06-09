CREATE PROCEDURE [dbo].[Get_Allbaserates]
(	
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SELECT  
		
		baseratekey,BrokerOrClientName,citykey,City as cityname,ClientOrBrokerKey, Country, B.createdate, B.CustID, C.CustKey,
		B.CustName as customername, EffectiveDate, B.UnitPrice
		
	FROM BaseRateView B

	inner join Customer C ON C.CustID = B.CustID

	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END

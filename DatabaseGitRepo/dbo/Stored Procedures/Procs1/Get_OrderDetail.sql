CREATE PROCEDURE [dbo].[Get_OrderDetail]
@OrderDateFrom		DATE='01/01/2020',
@OrderDateTo		DATE='01/12/2099',
@CSRKey				INT =0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF @OrderDateFrom IS NULL OR @OrderDateFrom='1900-01-01 00:00:00.000'
	BEGIN
		SET @OrderDateFrom= GETDATE()-30
	END
	IF @OrderDateTo IS NULL OR @OrderDateTo='1900-01-01 00:00:00.000'
	BEGIN
		SET @OrderDateTo= GETDATE()
	END

	SELECT
		OH.OrderNo,	
		OH.OrderDate,
		OH.CreateDate AS OrderCreateDate,
		OT.OrderType,
		CR.CsrName ,
		CT.CustName AS BillTOAddrName,
		Sour.City AS PickupLocation,
		Dest.City AS DestinationLocation,				
		S.[Description] AS [Status],
		OH.BookingNo,
		OH.BillOfLading,
		CRR.CarrierName,
		OT.Description AS OrderType,
		OH.StatusDate,
		HR.Description AS HoldReason,
		OH.[Status],
		Sour.AddrName AS SourceAddrName,
		Dest.AddrName AS DestinationAddrName,
		OH.OrderKey,
		OH.OrderKey,
		OH.CustKey,
		CUS.AddrKey	 AS BillToAddrKey,
		Sour.AddrKey AS SourceAddrKey,		
		Dest.AddrKey AS DestinationAddrKey,		
		Rtn.AddrKey	 AS ReturnAddrKey,
		OH.OrderTypeKey,
		OH.PriorityKey,
		OH.CreateUserKey,		
		OH.HoldDate,
		BR.BrokerKey,	
		BR.BrokerName,
		CRR.CarrierKey,		
		CR.CsrKey
	FROM  dbo.OrderHeader OH
			INNER JOIN dbo.Customer CT		ON CT.Custkey=OH.Custkey
			INNER JOIN dbo.[User] U			ON U.Userkey=OH.CreateUserkey
			INNER JOIN dbo.OrderStatus S	ON S.[Status]=OH.[Status]
			INNER JOIN dbo.OrderType OT		ON OT.OrderTypeKey=OH.OrderTypekey
			LEFT JOIN  dbo.[Address] CUS	ON CUS.Addrkey=CT.AddrKey
			LEFT JOIN  dbo.[Address] Sour	ON Sour.Addrkey=OH.SourceAddrkey
			LEFT JOIN  dbo.[Address] Dest	ON Dest.Addrkey=OH.DestinationAddrkey
			LEFT JOIN  dbo.[Address] Rtn	ON Rtn.Addrkey=OH.ReturnAddrKey
			LEFT JOIN  dbo.CSR CR			ON CR.CsrKey=OH.CsrKey
			LEFT JOIN  dbo.[Priority] PT	ON PT.PriorityKey=OH.PriorityKey
			LEFT JOIN  dbo.Holdreason HR    ON HR.HoldReasonKey=OH.HoldReasonKey
			LEFT JOIN  dbo.[broker] BR		ON BR.BrokerKey=OH.BrokerKey
			LEFT JOIN dbo.Carrier CRR		ON CRR.CarrierKey=OH.CarrierKey
	WHERE 
			( @OrderDateFrom	IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND ( @OrderDateTo		IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate<=@OrderDateTo)		
		AND ( ISNULL(@CSRKey,0)=0 OR OH.CsrKey= @CSRKey )
	
END

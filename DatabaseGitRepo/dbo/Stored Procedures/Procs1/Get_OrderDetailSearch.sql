CREATE PROCEDURE [dbo].[Get_OrderDetailSearch]
@CustomerKey		INT=0,
@OrderDateFrom		DATE='01/01/2020',
@OrderDateTo		DATE='01/01/2099',
@CSRKey				INT = 0,
@BOLNo				VARCHAR(20)='',
@BookingRefNo		VARCHAR(20)='',
@StatusKey			INT = 0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		OH.OrderNo,	
		OH.OrderDate,
		OH.CreateDate AS OrderCreateDate,
		OT.OrderType,
		CR.CsrName AS CSRName,
		CT.CustName,
		Sour.City AS PickupLocation,
		Dest.City AS DestinationLocation,				
		S.[Description] AS [StatusDescr],
		OH.BookingNo,
		OH.BillOfLading,
		CRR.CarrierName,
		OT.Description AS OrderTypeDescr,
		OH.StatusDate,
		HR.Description AS HoldReason,
		OH.[Status],
		Sour.AddrName AS SourceAddrName,
		Dest.AddrName AS DestinationAddrName,
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
	FROM  dbo.OrderHeader OH  (nolock)
			INNER JOIN dbo.Customer CT	(nolock)	ON CT.Custkey=OH.Custkey
			INNER JOIN dbo.[User] U		(nolock)	ON U.Userkey=OH.CreateUserkey
			INNER JOIN dbo.OrderStatus S(nolock)	ON S.[Status]=OH.[Status]
			INNER JOIN dbo.OrderType OT	(nolock)	ON OT.OrderTypeKey=OH.OrderTypekey
			LEFT JOIN  dbo.[Address] CUS (nolock)	ON CUS.Addrkey=OH.BillToAddrKey
			LEFT JOIN  dbo.[Address] Sour (nolock)	ON Sour.Addrkey=OH.SourceAddrkey
			LEFT JOIN  dbo.[Address] Dest (nolock)	ON Dest.Addrkey=OH.DestinationAddrkey
			LEFT JOIN  dbo.[Address] Rtn (nolock)	ON Rtn.Addrkey=OH.ReturnAddrKey
			LEFT JOIN  dbo.CSR CR		(nolock)	ON CR.CsrKey=OH.CsrKey
			LEFT JOIN  dbo.[Priority] PT (nolock) ON PT.PriorityKey=OH.PriorityKey
			LEFT JOIN  dbo.Holdreason HR (nolock) ON HR.HoldReasonKey=OH.HoldReasonKey
			LEFT JOIN  dbo.[broker] BR	(nolock) ON BR.BrokerKey=OH.BrokerKey
			LEFT JOIN dbo.Carrier CRR (nolock)	ON CRR.CarrierKey=OH.CarrierKey
	WHERE 
			( @OrderDateFrom	IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND ( @OrderDateTo		IS NULL OR OH.OrderDate<=@OrderDateTo)
		AND ( ISNULL(@CustomerKey,0)=0  OR OH.CustKey IS NULL OR OH.CustKey= @CustomerKey)
		AND ( ISNULL(@CSRKey,0)=0 OR OH.CsrKey IS NULL OR OH.CsrKey= @CSRKey )
		AND ( ISNULL(@BOLNo,'')='' OR BillOfLading IS NULL OR BillOfLading LIKE '%'+@BOLNo+'%')
		AND ( ISNULL(@BookingRefNo,'')='' OR BookingNo IS NULL OR BookingNo LIKE '%'+@BOLNo+'%')
		AND ( isnull(@StatusKey,0) = 0 OR OH.[Status] = @StatusKey)
END


CREATE PROCEDURE [dbo].[Get_OrderHeaderSearch]
@CustomerKey		INT=0,
@OrderDateFrom		DATE='01/01/2020',
@OrderDateTo		DATE='01/01/2099',
@CSRKey				INT = 0,
@BOLNo				VARCHAR(20)='',
@BookingRefNo		VARCHAR(20)='',
@StatusKey			INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	SELECT COUNT (1) AS ContainerCount ,OrderKey INTO #ContainerCount
	FROM OrderDetail	
	GROUP BY OrderKey
	
    SELECT 
        oh.OrderNo ,  oh.OrderDate ,  oh.CustKey,  
        cus.AddrKey AS BillToAddressKey,  cus.CustName AS BillToAddrName,
        oh.SourceAddrKey AS SourceAddressKey, SR.AddrName AS SourceAddrName,
        oh.DestinationAddrKey AS DestinationAddressKey,DT.AddrName AS DestinationAddrName,
        oh.ReturnAddrKey AS ReturnAddressKey, 
        oh.OrderTypeKey ,oh.PriorityKey,
        oh.[Status] ,  
		OH.StatusDate AS StatusDate,
        HR.[Description] AS HoldReason ,
        oh.HoldDate ,
        br.BrokerName,
        br.BrokerID ,
		br.BrokerKey,
        oh.BrokerRefNo ,
        oh.PortoForiginKey ,
        oh.CarrierKey,
        oh.VesselName ,
        oh.BillOfLading ,
        oh.BookingNo ,
        NULL AS CutOffDate ,  
        oh.CreateDate ,
        oh.CreateUserKey,
        oh.OrderKey,
        ot.OrderType as OrderTypeDescription,
        os.Description as StatusDescription,    
		'' AS NextAction,
		CS.CsrKey as CSRKey,
		CS.CsrName as CSRName,
		oh.SalesPersonKey,
		SP.SalesPersonName,
		CM.CsrKey as CSRManagerKey,
		CM.CsrName as CSRManagerName,
		CT.ContainerCount,
		SR.City AS PickupLocation,
		DT.City AS DeliveryLocation,
		CUS.CustName
    FROM dbo.OrderHeader oh   			WITH (NOLOCK)
        LEFT JOIN dbo.Customer cus		WITH (NOLOCK)	ON cus.CustKey = oh.CustKey      
        LEFT JOIN dbo.[Broker] br		WITH (NOLOCK)	ON oh.BrokerKey = br.BrokerKey
        LEFT JOIN dbo.OrderType ot		WITH (NOLOCK)	ON oh.OrderTypeKey = ot.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus os	WITH (NOLOCK)	ON os.[Status] = oh.[Status]
		LEFT JOIN Dbo.Holdreason	HR	WITH (NOLOCK)	ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT	WITH (NOLOCK)	ON CT.OrderKey=OH.OrderKey
		LEFT JOIN [Address] SR			WITH (NOLOCK)	ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT			WITH (NOLOCK)	ON	DT.AddrKey=OH.DestinationAddrKey
    WHERE 
			( @OrderDateFrom IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND ( @OrderDateTo	IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate<=@OrderDateTo)
		AND ( ISNULL(@CustomerKey,0)=0 OR OH.CustKey IS NULL OR OH.CustKey= @CustomerKey)
		AND ( ISNULL(@CSRKey,0)=0 OR OH.CsrKey IS NULL OR OH.CsrKey= @CSRKey )
		AND ( ISNULL(@BOLNo,'')='' OR BillOfLading IS NULL OR BillOfLading LIKE '%'+@BOLNo+'%')
		AND ( ISNULL(@BookingRefNo,'')='' OR BookingNo IS NULL OR BookingNo LIKE '%'+@BookingRefNo+'%')
		AND ( ISNULL(@StatusKey,0) = 0 OR OH.Status is null or OH.Status = @StatusKey);
END

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 38513}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_InvoiceHeader_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_InvoiceHeader_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	DECLARE
		@InvoiceKey  INT

	SELECT 
		@InvoiceKey		=	InvoiceKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey		INT		'$.InvoiceKey'
	)

	DECLARE @ExpenseAmt DECIMAL(18,2)

	CREATE TABLE #ExpenseItems
	(
		ItemKey INT,
		ItemDesc VARCHAR(500),
		UnitCost decimal(18,5),
		Qty decimal(18,2),
		OrderDetailKey INT,
		ContainerNo VARCHAR(20)

	);	

	SELECT DISTINCT OrderDetailKey INTO #OrderDetailWrk 
	FROM Invoicedetail 
	WHERE InvoiceKey= @InvoiceKey

	--INSERT INTO #ExpenseItems (ItemKey,ItemDesc,UnitCost,Qty,OrderDetailKey,ContainerNo)
	--EXECUTE Get_ExpenseItem	

	SET @ExpenseAmt= 0 --( SELECT SUM(ISNULL(UnitCost,0)*CASE WHEN Qty=0 THEN 1 WHEN Qty IS NULL THEN 1 ELSE Qty END) FROM #ExpenseItems )

	update IH set InvoiceAmount = totAmt
	from InvoiceHeader IH WITH(NOLOCK)
	inner join (
		select InvoiceKey, sum(extAmt) totAmt 
		from InvoiceDetail IH WITH(NOLOCK)
		where IH.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
		group by Invoicekey 
	) ID on IH.InvoiceKey = ID.InvoiceKey
	where IH.InvoiceKey = @InvoiceKey 


	SELECT 
	  IH.[InvoiceKey]
      ,[InvoiceNo]
      ,[InvoiceDate]
      ,IH.[CustKey]
      ,IH.[BillToAddrKey]
      ,[InvoiceAmount]
      ,[DueDate]
      ,[InvoiceType]
      ,IH.[CompanyKey]
      ,IH.[StatusKey]
      ,IH.[CreateUserKey]
      ,[IsInvoiceApproved]
      ,IH.[CreateDate]
      ,IH.[UpdateUserKey]
      ,IH.[UpdateDate]
      ,[InvoiceApprovedUserKey]
      ,isnull([InvoiceApprovedDate],'1900-01-01') as [InvoiceApprovedDate]
	  ,Container	  
	  ,SR.AddrName AS PickupAddressName,SR.Address1 AS PickupAddress1,SR.City AS PickupCity,SR.[State] AS PickupState,SR.ZipCode AS PickupZipcode,SR.Country AS PickupCountry
	  ,DT.AddrName AS DeliveryAddressName,DT.Address1 AS DeliveryAddress1,DT.City AS DeliveryCity,DT.[State] AS DeliveryState,DT.ZipCode AS DeliveryZipcode,DT.Country AS DeliveryCountry
	  ,BT.AddrName AS CustomerAddressName,BT.Address1 AS CustomerAddress1,BT.City AS CustomerCity,BT.[State] AS CustomerState,BT.ZipCode AS CustomerZipcode,BT.Country AS CustomerCountry
	  ,OH.OrderNo
	  ,IH.CustomerNote
	  ,IH.InternalNote
	  ,@ExpenseAmt AS DriverPay
	  ,(ISNULL(InvoiceAmount,0)-ISNULL(@ExpenseAmt,0) ) AS EstimatedProfit
	  ,CS.CsrName as CSRName
	  ,ih.IsPaymentReceived
	  ,IH.IsPrinted
	  ,ih.IsRevised
	  ,isnull(ih.PrintedDate,'1900-01-01') as PrintedDate
	  ,isnull(ih.PaymentRecdDate, '1900-01-01') as PaymentRecdDate
	  ,isnull(ih.RevisionDate, '1900-01-01') as RevisionDate
	  , U1.UserName AS InvoiceApprovedUserName
	  , u2.UserName as PrintedUserName
	  , U3.UserName as RevisedUserName
	  , U4.UserName as PaymentReceivedUserName
	--  , U6.UserName AS UpdatedUserName
	  , CU.IsFactored 
	  --, isnull(IH.BrokerRefNo, OH.BrokerRefNo) as BrokerRefNo
	  , ISNULL(IH.BrokerRefNo,isnull(INV2.CustRefNo, OH.BrokerRefNo)) as BrokerRefNo
	  , isnull(u3.UserName, U5.UserName) as CreatedUserName
	  ,InvoiceCompanyKey
	  ,ISNULL(ML.MarketLocation,'N/A') MarketLocation, ISNULL(OH.MarketLocationKey,0) MarketLocationKey,
	  SP.SalesPersonName,
	  (
		SELECT 
		    A.Addrkey,
		    A.AddrName,
		    A.Address1,
		    A.Address2,
		    A.City,
		    A.[State],
		    A.ZipCode,
		    A.Country,
		    A.Website,
		    A.Phone,
		    A.Phone2,
		    A.Email,
		    A.Email2,
		    A.Fax
		FROM dbo.[Address] A WITH(NOLOCK)
		WHERE A.Addrkey = IH.BillToAddrKey
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	) AS CustomerAddress,
	(
		SELECT 
		I.ItemID,
		CASE WHEN I.ItemKey=24 THEN 'Empty Stop Off' else ID.[Description] END As [Description]
		, SUM(ID.[ExtAmt]) AS ExtAmt 
		, I.InvoiceItemDesc as InvoiceDescription,PriceBasisKey,TimeDuration, ISNULL(CI.ChargeCode,'') CustomerChargeCode, 
		ISNULL(CI.ChargeDescription,ID.[Description]) ChargeDescription, CAST(0 AS INT) FreeQty, CAST(0 AS INT) TotalQty,
		CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem WITH (NOLOCK)) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc
		FROM [dbo].[Invoicedetail] ID WITH (NOLOCK) 
			JOIN dbo.InvoiceHeader IH WITH (NOLOCK)  ON IH.InvoiceKey =  ID.InvoiceKey
			JOIN dbo.Item I WITH (NOLOCK) ON I.Itemkey=ID.ItemKey
			LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
		WHERE id.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
		GROUP BY I.ItemKey, I.ItemID, ID.[Description], I.InvoiceItemDesc,PriceBasisKey,TimeDuration,ChargeCode,ChargeDescription,I.[Description],IH.CustKey
		FOR JSON PATH
  ) AS InvoiceDetail
  FROM [dbo].[InvoiceHeader] IH  WITH(NOLOCK)
	INNER JOIN
			(				
				SELECT STRING_AGG(ContainerNo + ':' + convert(varchar,OrderDetailsKey) ,', ') AS Container,InvoiceKey
				FROM
				(
					SELECT DISTINCT ContainerNo, OrderDetailsKey ,InvoiceKey FROM InvoiceContainers-- Invoicedetail
				) T GROUP BY InvoiceKey
			)INV ON INV.InvoiceKey=IH.InvoiceKey
    INNER JOIN
			(				
				SELECT STRING_AGG(CustRefNo ,', ') AS CustRefNo,InvoiceKey
				FROM
				(
					SELECT DISTINCT REPLACE(CustRefNo,'N/A',null) CustRefNo ,InvoiceKey FROM InvoiceContainers IV1-- Invoicedetail
					INNER JOIN OrderDetail ODI ON ODI.OrderDetailKey=IV1.OrderDetailsKey
				) T1 GROUP BY InvoiceKey
			)INV2 ON INV2.InvoiceKey=IH.InvoiceKey
	LEFT JOIN dbo.OrderHeader OH WITH(NOLOCK) ON Oh.OrderKey=IH.OrderKey 
	LEFT JOIN [Address] SR WITH(NOLOCK)	ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN [Address] DT WITH(NOLOCK)	ON	DT.AddrKey=OH.DestinationAddrKey
	LEFT JOIN [Address] BT WITH(NOLOCK)	ON	BT.AddrKey=IH.BillToAddrKey
	LEFT JOIN [Customer] CU WITH(NOLOCK) on IH.CustKey = CU.CustKey
	LEFT JOIN dbo.CSR CS WITH(NOLOCK) ON CS.CsrKey=OH.CsrKey
	LEFT JOIN [User] U1 WITH(NOLOCK) ON IH.InvoiceApprovedUserKey = U1.UserKey
	LEFT JOIN [User] U2 WITH(NOLOCK) ON IH.PrintedUserKey = U2.UserKey
	LEFT JOIN [User] U3 WITH(NOLOCK) ON IH.RevisionUserKey = U3.UserKey
	LEFT JOIN [User] U4 WITH(NOLOCK) ON IH.PaymentRecdUserKey = U4.UserKey
	LEFT JOIN [User] U5 WITH(NOLOCK) ON IH.CreateUserKey = U5.UserKey
--	LEFT JOIN [User] U6 ON IH.UpdateUserKey = U6.UserKey
LEFT JOIN MarketLocation ML WITH (NOLOCK) ON (ML.MarketLocationKey=OH.MarketLocationKey)
LEFT JOIN SalesPerson SP WITH (NOLOCK) ON SP.SalesPersonKey=OH.SalesPErsonKey
	WHERE IH.InvoiceKey = @InvoiceKey
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

SET @Status=1
SET @Reason = 'Success'
END
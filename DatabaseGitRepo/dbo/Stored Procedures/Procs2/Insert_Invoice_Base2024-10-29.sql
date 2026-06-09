

/*
Declare @OrderDetailKeyStr	VARCHAR(MAX) ='127750:', @UserKey	INT=29,@CustomerNote	VARCHAR(3000),@InternalNote		VARCHAR(3000),
		@OutPut		BIT , @Reason	VARCHAR(300)='' 
Exec [Insert_Invoice] @OrderDetailKeyStr, @UserKey, @CustomerNote, @InternalNote, @OutPut OUTPUT, @Reason OUTPUT
sELECT @OutPut, @Reason
*/

CREATE PROCEDURE [dbo].[Insert_Invoice_Base2024-10-29] 
@OrderDetailKeyStr	VARCHAR(MAX),
@UserKey			INT,
@CustomerNote		VARCHAR(3000),
@InternalNote		VARCHAR(3000),
@OutPut				BIT OUTPUT,
@Reason				VARCHAR(300)='' OUTPUT
AS
BEGIN
	SET NOCOUNT ON ;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @OrderKey		INT;
	DECLARE @InvoiceKey		INT;
	DECLARE @CustomerKey	INT;
	DECLARE @InvoiceNo		INT;
	DECLARE @OrderDate		DATETIME;
	DECLARE @InvoiceStatus  SMALLINT	
	DECLARE @OrderDetailkey INT
	   	 
	SET @InvoiceStatus= ( SELECT StatusKey FROM dbo.InvoiceStatus WHERE Description='Pending' )

	CREATE TABLE #OrderDetail
	(
		OrderDetailKey INT
	);	

	--UPDATE OrderExpense SET 
	--	BvsNB = CASE WHEN BvsNB = '0' THEN 'NB' 
	--				WHEN BvsNB = 1 THEN 'B' 
	--				WHEN BvsNB IS NULL THEN 'NB' END

	INSERT INTO #OrderDetail (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKeyStr);

	SELECT DISTINCT OD.OrderDetailKey,OD.OrderKey INTO #OrderRoute
	FROM #OrderDetail A 	
		INNER JOIN dbo.OrderDetail OD ON OD.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN dbo.Invoicedetail ID ON ID.OrderDetailKey=A.OrderDetailKey
	WHERE ID.InvoiceKey IS NULL

	DECLARE @RouteStatusCount INT=0
	SELECT @RouteStatusCount =COUNT(1) FROM OrderDetail OD
	INNER JOIN OrderDetailStatus ODS ON ODS.Status=OD.Status 
	WHERE OrderDetailKey in (SELECt OrderDetailKey FROM #OrderDetail) AND OD.Status  not in (6,10, 14)
	

   --***********************Delete Incomplete Containers******************* 
   	Delete A from #OrderRoute A
	LEFT OUTER JOIN Routes  B on (A.OrderDetailKey = B.OrderDetailKey)
	where B.OrderDetailKey  is null

	DELETE 
	FROM #OrderRoute 
	WHERE OrderDetailKey IN 
	(
	SELECT DISTINCT RT.OrderDetailKey 
	FROM dbo.[Routes] RT 
		INNER JOIN #OrderRoute OT ON OT.OrderDetailKey=RT.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS		ON RTS.[Status]=RT.[Status]	
	WHERE RTS.[Description]<>'Leg Completed'
	)

	DECLARE @RecCount INT=0
	SET @RecCount=(SELECT COUNT(1) FROM #OrderRoute)
	IF(@RecCount=0)
	BEGIN
		SET @OutPut=0
		SET @Reason = 'Complete the legs before creating invoice.'
		RETURN;
	END
	IF(@RouteStatusCount>0)
	BEGIN
		SET @OutPut=0
		SET @Reason = 'Dispatch is not confirmed yet.'
		RETURN;
	END

	SELECT DISTINCT OrderKey INTO #Orders  
	FROM #OrderRoute

	--Declare @CustomerBaseRateItem	int = 0, @CustomerBaseRateItemDescr varchar(50) = ''
	--select top 1 @CustomerBaseRateItem = ItemKey, @CustomerBaseRateItemDescr = ItemID from item where ItemID in ( 'BR','DRAY')

	WHILE (SELECT COUNT(1)FROM #Orders)>0
	BEGIN	
		SET @OrderKey=0;
		SET @OrderKey= (SELECT TOP 1 OrderKey  FROM #Orders ORDER BY OrderKey );
		SET @InvoiceNo = ( SELECT CAST(ISNULL(MAX(CAST(InvoiceNo AS INT)),0)+1 AS VARCHAR(20))  FROM  dbo.InvoiceHeader );
		SET @CustomerKey= ( SELECT CustKey	 FROM dbo.OrderHeader WHERE OrderKey= @OrderKey );
		SET @OrderDate = ( SELECT   OrderDate FROM dbo.OrderHeader WHERE OrderKey= @OrderKey)
		--****************************BaseRate*********************************	
		BEGIN TRANSACTION
		BEGIN TRY		
				Declare @InvItemCount	int = 0

				--SELECT @InvItemCount =Count(1)
				--FROM OrderExpense A 
				--INNER JOIN dbo.Item		I  ON I.ItemKey=A.Itemkey			
				--INNER JOIN OrderDetail  OD ON OD.OrderDetailKey=A.OrderDetailKey					
				--INNER JOIN #OrderRoute  OT ON OT.OrderDetailKey=OD.OrderDetailKey AND OT.OrderKey=OD.OrderKey
				--WHERE   OD.OrderKey= @OrderKey		 and I.ItemTypeKey in (1,5)

				--if(@InvItemCount >0)
				--Begin
					INSERT INTO [dbo].InvoiceHeader( [InvoiceNo], [InvoiceDate], [CustKey], [BilltoaddrKey],
								IsInvoiceApproved,IsPaymentReceived,[InvoiceAmount], [DueDate],[InvoiceType], 
								[CompanyKey], [StatusKey],CreateUserKey, [CreateDate],InvoiceApprovedUserKey,
								InvoiceApprovedDate, OrderKey,CustomerNote,InternalNote)
					SELECT DISTINCT @InvoiceNo,GETDATE()AS InvoiceDate,CUS.CustKey,AD.AddrKey AS BillTOAddressKey,0,0,0,
									DATEADD(DD,ISNULL([Days],0),GETDATE()),NULL,1,@InvoiceStatus,@UserKey,GETDATE(),0,NULL,@OrderKey
									,@CustomerNote,@InternalNote
					FROM   dbo.OrderHeader OH WITH (NOLOCK)
								INNER JOIN  dbo.Customer CUS  WITH (NOLOCK)	ON CUS.CustKey=OH.CustKey
								INNER JOIN  dbo.[Address] AD  WITH (NOLOCK)	ON AD.AddrKey=OH.BillToAddrKey
								LEFT JOIN   dbo.PaymentTerms PT  WITH (NOLOCK) ON PT.PaymentTermsKey=CUS.PaymentTermsKey			
					WHERE OH.OrderKey= @OrderKey;				

					SET @InvoiceKey= ( SELECT SCOPE_IDENTITY() ) ;		 
		
					INSERT INTO [dbo].Invoicedetail([InvoiceKey], [ItemKey], [Description], [UnitPrice], [Qty], 
								[ExtAmt],OrderDetailKey, [Container],CreateUserKey,CreateDate, TimeDuration, 
								Charges, SellPrice, BvsNB, FreeTime, Minval, MaxVal)
					SELECT @InvoiceKey,I.ItemKey,I.[Description] AS ItemDescription,
							ISNULL(A.NewUnitCost,A.UnitCost) AS UnitPrice,
							CASE WHEN A.Qty IS NULL THEN 1 WHEN A.Qty=0 THEN 1 ELSE A.Qty END AS Qty
							,NULL AS ExtAmt,RT.OrderDetailKey,OD.ContainerNo,@UserKey,GETDATE(),A.TimeDuration,
							 A.UnitCost,NULL, A.BvsNB, A.FreeTime, A.MinCnt, A.MaxCnt
					FROM OrderExpense A  WITH (NOLOCK)
						INNER JOIN dbo.Item		I  WITH (NOLOCK) ON I.ItemKey=A.Itemkey			
						INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
						INNER JOIN dbo.[Routes] RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey
						INNER JOIN dbo.[Address] D WITH (NOLOCK) ON D.AddrKey=RT.DestinationAddrKey
						INNER JOIN OrderDetail  OD WITH (NOLOCK) ON OD.OrderDetailKey=RT.OrderDetailKey					
						INNER JOIN #OrderRoute  OT WITH (NOLOCK) ON OT.OrderDetailKey=OD.OrderDetailKey AND OT.OrderKey=OD.OrderKey
					WHERE   OD.OrderKey= @OrderKey		 and I.ItemTypeKey in (1,5)
					--and ISNULL(A.BvsNB,1) = 1
						--IT.ItemTypeKey = 1

					/* REMOVED AS PER INSTRUCTIONS FROM KATHRYN ON 8/26/2024
					-- BASE RATE INSERTION
					INSERT INTO [dbo].Invoicedetail([InvoiceKey], [ItemKey], [Description], [UnitPrice], [Qty], 
								[ExtAmt],OrderDetailKey, [Container],CreateUserKey,CreateDate)
					SELECT @InvoiceKey,@CustomerBaseRateItem as ItemKey,@CustomerBaseRateItemDescr  AS ItemDescription,
							dbo.fn_Get_CustomerBaseRatePerContainer(A.OrderDetailKey, @CustomerBaseRateItem) AS UnitPrice,
							1 AS Qty, NULL AS ExtAmt,A.OrderDetailKey,OD.ContainerNo,@UserKey,GETDATE()
					FROM #OrderRoute A 
					inner join OrderDetail OD on A.OrderDetailKey = OD.OrderDetailKey
					WHERE   A.OrderKey= @OrderKey		
					*/

					UPDATE Invoicedetail
					SET ExtAmt= (UnitPrice*Qty)
					WHERE InvoiceKey=@InvoiceKey

					UPDATE dbo.InvoiceHeader
					SET InvoiceAmount= (SELECT ISNULL(SUM(ExtAmt),0) FROM dbo.Invoicedetail WHERE InvoiceKey= @InvoiceKey)
					WHERE InvoiceKey= @InvoiceKey

					Update A  Set BillToAddrKey = B.BillToAddrKey  from  InvoiceHeader A
					inner join  Customer B on (A.CustKey = B.CustKey)
					where  B.BillToAddrKey is not null and A.InvoiceKey = @InvoiceKey

					--********************************************************************************		
					--UPDATE OD
					--SET OD.[Status]= ( SELECT [Status] FROM OrderDetailStatus WHERE [Description]='Approved for Invoice/Driver Pay' )
					--FROM dbo.OrderDetail OD 			
					--	INNER JOIN dbo.Invoicedetail ID ON ID.OrderDetailKey=OD.OrderDetailKey
					--WHERE OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderRoute ) AND OD.OrderKey=@OrderKey

					INSERT INTO dbo.RouteInvoice (OrderDetailKey, InvoiceKey)
					SELECT DISTINCT OrderDetailKey,InvoiceKey
					FROM [dbo].Invoicedetail  WITH (NOLOCK)
					WHERE InvoiceKey=@InvoiceKey

					--added to insert into invoice containers table
					INSERT INTO InvoiceContainers
					(OrderDetailsKey,InvoiceKey,ContainerNo)
					select Distinct ID.OrderDetailKey,ID.InvoiceKey,OD.ContainerNo 
					from Invoicedetail ID  WITH (NOLOCK)
					LEFT JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=ID.OrderDetailKey 
					LEFT JOIN InvoiceContainers IC WITH (NOLOCK) ON (IC.OrderDetailsKey=OD.OrderDetailKey) AND (IC.InvoiceKey=ID.InvoiceKey)
					WHERE ID.InvoiceKey=@InvoiceKey AND IC.OrderDetailsKey IS NULL

					--IF(@CustomerKey in (1966,2423,2567,3170,3402))
					--BEGIN
					--	UPDATE InvoiceHeader SET AprovedReasonCodeKey= 1
					--	WHERE InvoiceKey=@InvoiceKey
					--END

					SET @OutPut=1;
				--End
		END TRY
		BEGIN CATCH	
			print error_line()
			print Error_message()
			SET @OutPut=0;
			IF @@TRANCOUNT > 0 
			--select ERROR_MESSAGE()
			ROLLBACK TRANSACTION
		END CATCH
		IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
		
		DELETE FROM #Orders WHERE OrderKey=@OrderKey;
	END;

	--SET @OutPut=1;
END
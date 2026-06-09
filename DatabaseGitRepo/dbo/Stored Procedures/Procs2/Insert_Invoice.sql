

-- {  "OrderDetailKeyList": "154711:",  "CreateUserKey": 29}
/*
Declare @OrderDetailKeyStr	VARCHAR(MAX) ='133341:144193:143933:146838:146817:', @UserKey	INT=29,@CustomerNote	VARCHAR(3000),@InternalNote		VARCHAR(3000),
		@OutPut		BIT , @Reason	VARCHAR(300)='' , @IsDebug			bit = 1
Exec [Insert_Invoice] @OrderDetailKeyStr, @UserKey, @CustomerNote, @InternalNote, @OutPut OUTPUT, @Reason OUTPUT,@IsDebug
sELECT @OutPut, @Reason
*/

CREATE PROCEDURE [dbo].[Insert_Invoice] 
@OrderDetailKeyStr	VARCHAR(MAX),
@UserKey			INT,
@CustomerNote		VARCHAR(3000),
@InternalNote		VARCHAR(3000),
@OutPut				BIT OUTPUT,
@Reason				VARCHAR(300)='' OUTPUT,
@IsDebug			bit = 0
AS
BEGIN
	SET NOCOUNT ON ;
	SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	sET ARithabort ON;

	SET @OutPut=0;

	DECLARE @OrderKey		INT;
	DECLARE @InvoiceKey		INT;
	DECLARE @CustomerKey	INT;
	DECLARE @InvoiceNo		VARCHAR(50);
	DECLARE @OrderDate		DATETIME;
	DECLARE @InvoiceStatus  SMALLINT	
	DECLARE @OrderDetailkey INT
	   	 
	SET @InvoiceStatus= ( SELECT StatusKey FROM dbo.InvoiceStatus WHERE Description='Pending' )

	CREATE TABLE #OrderDetail
	(
		OrderDetailKey INT
	);	

	INSERT INTO #OrderDetail (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKeyStr);

	if(@IsDebug = 1)
	BEGIN
		SELECT '#OrderDetail',* From #OrderDetail
	END

	select * into #OrderDetailTemp from #OrderDetail

	Declare @Cnt	int = 0
	select @Cnt =   count(1) from #OrderDetailTemp
	while (@cnt > 0)
	Begin
		SElect top 1  @OrderDetailkey = OrderDetailKey from #OrderDetailTemp
		print '------------------------'
		select @OrderDetailKey

		-- CHECK CTF/TMF ITEMS AND CREATE, IF NOT CREATED
		EXEC Auto_ChargeTMFCTF @OrderDetailkey

		-- CHECK YARD STORAGE LOADED / EMPTY
		EXEC Auto_ChargeYardStorage @OrderDetailkey

		-- CHECK THE TRI-AXLE / JCT/PORT Chassis ITem, if not CREATED
		Exec AUTO_ChargeChassisDays @OrderDetailkey, 0

		-- CHECK THE CONTAINER PROPS ITem, if not CREATED
		Exec Auto_ChargeContainerProps @OrderDetailkey, 0

		-- CHECK THE Drayage, FSF, Prepull, Shuttle, Yard Stopoff  ITem, if not CREATED
		Exec AUTO_ChargeDrayageFSFPrepullShuttleYardStopoff @OrderDetailkey, 0

		-- CHECK THE DRY RUN / BOBTAIL ITem, if not CREATED
		Exec AUTO_ChargeDryRunBobtail @OrderDetailkey, 0

		Declare @MissingrouteKeyCount int = 0, @AssignRouteKey	int = 0
		Select @MissingrouteKeyCount = count(1) from OrderExpense WITH (NOLOCK) where Isnull(RouteKey,0) = 0
		if(@MissingrouteKeyCount > 0)
		Begin
			Select top 1 @AssignRouteKey = Routekey from Routes WITH (NOLOCK) where OrderDetailkey = @OrderDetailkey
			update ORderExpense set Routekey = @AssignRouteKey where isnull(Routekey ,0) = 0
		End

		Delete from #OrderDetailTemp where OrderDetailKey = @OrderDetailkey
		select @Cnt =   count(1) from #OrderDetailTemp
	End



	-- TO REMOVE THE INVOICES CREATED WITHOUT ITEMS
	delete from InvoiceHeader where invoicekey in (
		select Ih.InvoiceKey
		from InvoiceHeader IH
		left join Invoicedetail IC on Ih.InvoiceKey = IC.InvoiceKey
		left join RouteInvoice RI ON RI.InvoiceKey = IH.InvoiceKey
		where IC.InvoiceKey is null AND RI.InvoiceKey IS NULL
	)

	SELECT DISTINCT OD.OrderDetailKey,OD.OrderKey INTO #OrderRoute
	FROM #OrderDetail A 	
		INNER JOIN dbo.OrderDetail OD ON OD.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN dbo.Invoicedetail ID ON ID.OrderDetailKey=A.OrderDetailKey
	WHERE ID.InvoiceKey IS NULL

	if(@IsDebug = 1)
	BEGIN
		SELECT '#OrderRoute - Before Delete',* From #OrderRoute
	END

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

	if(@IsDebug = 1)
	BEGIN
		SELECT '#OrderRoute - AFter Delete',* From #OrderRoute
	END

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

	if(@IsDebug = 1)
	BEGIN
		SELECT '#Orders ',* From #Orders
	END

	--Declare @CustomerBaseRateItem	int = 0, @CustomerBaseRateItemDescr varchar(50) = ''
	--select top 1 @CustomerBaseRateItem = ItemKey, @CustomerBaseRateItemDescr = ItemID from item where ItemID in ( 'BR','DRAY')

	WHILE (SELECT COUNT(1)FROM #Orders)>0
	BEGIN	
		SET @OrderKey=0;
		SET @OrderKey= (SELECT TOP 1 OrderKey  FROM #Orders ORDER BY OrderKey );
		
		SET @CustomerKey= ( SELECT CustKey	 FROM dbo.OrderHeader WHERE OrderKey= @OrderKey );
		SET @OrderDate = ( SELECT   OrderDate FROM dbo.OrderHeader WHERE OrderKey= @OrderKey)
		--****************************BaseRate*********************************	

		Declare @xstate int , @TranCount int

		BEGIN TRANSACTION InsertInvoice
		BEGIN TRY		
				Declare @InvItemCount	int = 0

				

				/* END OF  ADDED ON 2024-10-08 */

				SELECT @InvItemCount =Count(1)
				FROM OrderExpense A  WITH (NOLOCK)
					INNER JOIN dbo.Item		I  WITH (NOLOCK) ON I.ItemKey=A.Itemkey			
					INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
					INNER JOIN dbo.[Routes] RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey
					INNER JOIN OrderDetail  OD WITH (NOLOCK) ON OD.OrderDetailKey=RT.OrderDetailKey					
					INNER JOIN #OrderRoute  OT WITH (NOLOCK) ON OT.OrderDetailKey=OD.OrderDetailKey AND OT.OrderKey=OD.OrderKey
				WHERE   OD.OrderKey= @OrderKey		 and I.ItemTypeKey in (1,5)

				if(@IsDebug = 1)
				BEGIN
					SELECT  @OrderKey as OrderKey, @InvoiceNo as InvoiceNo, @CustomerKey as CustomerKey, 
						@OrderDate as OrderDate, @InvItemCount as InvItemCount
				END
				
				if(@InvItemCount >0)
				Begin
					SET @InvoiceNo = '0' -- ( SELECT CAST(ISNULL(MAX(CAST(replace(InvoiceNo,'-1','') AS INT)),0)+1 AS VARCHAR(20))  FROM  dbo.InvoiceHeader );
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
					
					-- To make the InvoiceNo unique, the following code is added. 
					update InvoiceHeader set InvoiceNo = convert(varchar, @InvoiceKey - 38946) where invoicekey = @InvoiceKey
		
					INSERT INTO [dbo].Invoicedetail([InvoiceKey], [ItemKey], [Description], [UnitPrice], [Qty], 
								[ExtAmt],OrderDetailKey, [Container],CreateUserKey,CreateDate, TimeDuration, 
								Charges, SellPrice, BvsNB, FreeTime, Minval, MaxVal, ReportedCost)
					SELECT @InvoiceKey,I.ItemKey,I.[Description] AS ItemDescription,
							ISNULL(A.NewUnitCost,A.UnitCost) AS UnitPrice,
							CASE WHEN A.Qty IS NULL THEN 1 WHEN A.Qty=0 THEN 1 ELSE A.Qty END AS Qty
							,NULL AS ExtAmt,RT.OrderDetailKey,OD.ContainerNo,@UserKey,GETDATE(),A.TimeDuration,
							 A.UnitCost,NULL, A.BvsNB, A.FreeTime, A.MinCnt, A.MaxCnt, A.ReportedCost
					FROM OrderExpense A  WITH (NOLOCK)
						INNER JOIN dbo.Item		I  WITH (NOLOCK) ON I.ItemKey=A.Itemkey			
						INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
						INNER JOIN dbo.[Routes] RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey
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

					IF(@IsDebug = 1)
					BEGIN
						Select @InvoiceKey as InvoiceKey

						SELECT * FROM InvoiceHeader IH WITH (NOLOCK)
						inner join Invoicedetail ID WITH (NOLOCK) on IH.InvoiceKey = ID.InvoiceKey
						where IH.Invoicekey = @InvoiceKey
					END

					SET @OutPut=1;
				End
		END TRY
		BEGIN CATCH	
			declare @error int, @message varchar(4000)
			SElect @xstate = XACT_STATE(), @TranCount = @@TRANCOUNT
			SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE()
			
			SET @OutPut=0;
			--select ERROR_MESSAGE()
			if @xstate = -1
            rollback;
			if @xstate = 1 and @trancount = 0
				rollback;
			if @xstate = 1 and @trancount > 0
				rollback transaction InsertInvoice;
			raiserror ('InsertInvoice: %d: %s', 16, 1, @error, @message) ;
		END CATCH
		IF @@TRANCOUNT > 0 
		BEGIN
			COMMIT TRANSACTION InsertInvoice
		END
		
		DELETE FROM #Orders WHERE OrderKey=@OrderKey;
	END;

	--SET @OutPut=1;
END

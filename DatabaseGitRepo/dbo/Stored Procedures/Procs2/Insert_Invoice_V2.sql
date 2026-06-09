/*
DECLARE 
	@UserKey INT=29,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKeyList":"151763:"}', --'{"OrderDetailKeyList": "118380:"}',
	@Status BIT=0, @Debug bit = 1,
	@Reason VARCHAR(100)=''
EXec Insert_Invoice_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
*/

CREATE PRocedure [dbo].[Insert_Invoice_V2]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@Debug			bit = 0
)
AS 
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End
	Declare
		@OrderDetailKeyStr	VARCHAR(MAX),
		@CustomerNote		VARCHAR(3000),
		@InternalNote		VARCHAR(3000)



	DECLARE @OrderKey		INT;
	DECLARE @InvoiceKey		INT;
	DECLARE @CustomerKey	INT;
	DECLARE @InvoiceNo		varchar(50);
	DECLARE @OrderDate		DATETIME;
	DECLARE @InvoiceStatus  SMALLINT	
	DECLARE @OrderDetailkey INT
	
	SElect @OrderDetailKeyStr =OrderDetailKeyStr
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKeyStr				varchar(max)				'$.OrderDetailKeyList'
	)

	SET @InvoiceStatus= ( SELECT StatusKey FROM dbo.InvoiceStatus WITH(NOLOCK) WHERE Description='Pending' )

	CREATE TABLE #OrderDetail
	(
		OrderDetailKey INT
	);	
	INSERT INTO #OrderDetail (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKeyStr);

	/* ADDED ON 2024-10-08 */
	
	SElect top 1  @OrderDetailkey = OrderDetailKey from #OrderDetail

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

	/* END OF  ADDED ON 2024-10-08 */


	Declare @MissingrouteKeyCount int = 0, @AssignRouteKey	int = 0
	Select @MissingrouteKeyCount = count(1) from OrderExpense WITH (NOLOCK) where Isnull(RouteKey,0) = 0
	if(@MissingrouteKeyCount > 0)
	Begin
		Select top 1 @AssignRouteKey = Routekey from Routes WITH (NOLOCK) where OrderDetailkey = @OrderDetailkey
		update ORderExpense set Routekey = @AssignRouteKey where isnull(Routekey ,0) = 0
	End

	SELECT DISTINCT OD.OrderDetailKey,OD.OrderKey INTO #OrderRoute
	FROM #OrderDetail A 	
		INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN dbo.Invoicedetail ID WITH(NOLOCK) ON ID.OrderDetailKey=A.OrderDetailKey
	WHERE ID.InvoiceKey IS NULL

	DECLARE @RouteStatusCount INT=0
	SELECT @RouteStatusCount =COUNT(1) FROM OrderDetail OD WITH(NOLOCK)
	INNER JOIN OrderDetailStatus ODS WITH(NOLOCK) ON ODS.Status=OD.Status 
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
	FROM dbo.[Routes] RT  WITH(NOLOCK)
		INNER JOIN #OrderRoute OT ON OT.OrderDetailKey=RT.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH(NOLOCK)		ON RTS.[Status]=RT.[Status]	
	WHERE RTS.[Description]<>'Leg Completed'
	)

	DECLARE @RecCount INT=0
	SET @RecCount=(SELECT COUNT(1) FROM #OrderRoute)
	IF(@RecCount=0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Complete the legs before creating invoice.'
		RETURN;
	END
	IF(@RouteStatusCount>0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Dispatch is not confirmed yet.'
		RETURN;
	END

	Declare @ExpCount	int = 0
	update OE SET OrderDetailKey = RT.OrderDetailKey
	from OrderExpense OE WITH(NOLOCK)
	inner join Routes RT WITH (NOLOCK) on OE.RouteKey = RT.RouteKey
	where isnull(OE.OrderDetailKey,0) = 0

	Select OE.OrderDetailKey, count(1) ExpCount
	into #ExpCounts
	from OrderExpense OE WITH (NOLOCK)
	inner join #OrderDetail OD on OE.OrderDetailKey = OD.OrderDetailKey
	Group by OE.OrderDetailKey

	/* AVOID CREATING INVOICE WITHOUT ITEM */
	Delete from #OrderDetail 
	where OrderDetailKey in (
		Select OD.OrderDetailKey from #OrderDetail OD
		LEft join #ExpCounts E on OD.OrderDetailKey = E.OrderDetailKey
		where isnull(E.ExpCount,0) =0
	)

	SELECT DISTINCT OrderKey INTO #Orders  
	FROM #OrderRoute

	--Declare @CustomerBaseRateItem	int = 0, @CustomerBaseRateItemDescr varchar(50) = ''
	--select top 1 @CustomerBaseRateItem = ItemKey, @CustomerBaseRateItemDescr = ItemID from item where ItemID in ( 'BR','DRAY')

	WHILE (SELECT COUNT(1)FROM #Orders)>0
	BEGIN	
		SET @OrderKey=0;
		SET @OrderKey= (SELECT TOP 1 OrderKey  FROM #Orders ORDER BY OrderKey );
		
		SET @CustomerKey= ( SELECT CustKey	 FROM dbo.OrderHeader WHERE OrderKey= @OrderKey );
		SET @OrderDate = ( SELECT   OrderDate FROM dbo.OrderHeader WHERE OrderKey= @OrderKey)
		--****************************BaseRate*********************************	
		BEGIN TRANSACTION
		BEGIN TRY		
				SET @InvoiceNo = '0' --( SELECT CAST(ISNULL(MAX(CAST(replace(InvoiceNo,'-1','') AS INT)),0)+1 AS VARCHAR(20))  FROM  dbo.InvoiceHeader );
				INSERT INTO [dbo].InvoiceHeader( [InvoiceNo], [InvoiceDate], [CustKey], [BilltoaddrKey],
							IsInvoiceApproved,IsPaymentReceived,[InvoiceAmount], [DueDate],[InvoiceType], 
							[CompanyKey], [StatusKey],CreateUserKey, [CreateDate],InvoiceApprovedUserKey,
							InvoiceApprovedDate, OrderKey,CustomerNote,InternalNote)
				SELECT DISTINCT @InvoiceNo,GETDATE()AS InvoiceDate,CUS.CustKey,AD.AddrKey AS BillTOAddressKey,0,0,0,
								DATEADD(DD,ISNULL([Days],0),GETDATE()),NULL,1,@InvoiceStatus,@UserKey,GETDATE(),0,NULL,@OrderKey
								,@CustomerNote,@InternalNote
				FROM   dbo.OrderHeader OH  WITH(NOLOCK)
							INNER JOIN  dbo.Customer CUS WITH(NOLOCK)	ON CUS.CustKey=OH.CustKey
							INNER JOIN  dbo.[Address] AD WITH(NOLOCK)	ON AD.AddrKey=OH.BillToAddrKey
							LEFT JOIN   dbo.PaymentTerms PT WITH(NOLOCK) ON PT.PaymentTermsKey=CUS.PaymentTermsKey			
				WHERE OH.OrderKey= @OrderKey;				

				SET @InvoiceKey= ( SELECT SCOPE_IDENTITY() ) ;		
				
				-- To make the InvoiceNo unique, the following code is added. 
				update InvoiceHeader set InvoiceNo = @InvoiceKey - 38946 where invoicekey = @InvoiceKey
		
				INSERT INTO [dbo].Invoicedetail([InvoiceKey], [ItemKey], [Description], [UnitPrice], [Qty], 
							[ExtAmt],OrderDetailKey, [Container],CreateUserKey,CreateDate, TimeDuration, 
							Charges, SellPrice, BvsNB, FreeTime, Minval, MaxVal, ItemNotes, ReportedCost)
				SELECT @InvoiceKey,I.ItemKey,
				--I.[Description] AS ItemDescription,
				CASE WHEN I.ItemKey=24 THEN 'Empty Stop Off' ELSE I.[Description] END AS ItemDescription,
						ISNULL(A.NewUnitCost,A.UnitCost) AS UnitPrice,
						CASE WHEN A.Qty IS NULL THEN 1 WHEN A.Qty=0 THEN 1 ELSE A.Qty END AS Qty
						,NULL AS ExtAmt,RT.OrderDetailKey,OD.ContainerNo,@UserKey,GETDATE(),A.TimeDuration,
						 A.UnitCost,NULL, A.BvsNB, A.FreeTime, A.MinCnt, A.MaxCnt, ISNULL( A.InternalNotes,''), ReportedCost
				FROM OrderExpense A WITH(NOLOCK) 
					INNER JOIN dbo.Item		I  WITH(NOLOCK) ON I.ItemKey=A.Itemkey			
					INNER JOIN dbo.ItemType IT WITH(NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
					LEFT JOIN dbo.[Routes] RT WITH(NOLOCK) ON RT.RouteKey=A.RouteKey
					LEFT JOIN dbo.[Address] D WITH(NOLOCK) ON D.AddrKey=RT.DestinationAddrKey
					INNER JOIN OrderDetail  OD WITH(NOLOCK) ON OD.OrderDetailKey=RT.OrderDetailKey					
					INNER JOIN #OrderRoute  OT ON OT.OrderDetailKey=OD.OrderDetailKey AND OT.OrderKey=OD.OrderKey
				WHERE   OD.OrderKey= @OrderKey	and I.ItemTypeKey in (1,5)	--and ISNULL(A.BvsNB,1) = 1
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

				--INSERT INTO dbo.RouteInvoice (OrderDetailKey, InvoiceKey)
				--SELECT DISTINCT OrderDetailKey,InvoiceKey
				--FROM [dbo].Invoicedetail 
				--WHERE InvoiceKey=@InvoiceKey

				--added to insert into invoice containers table
				INSERT INTO InvoiceContainers
				(OrderDetailsKey,InvoiceKey,ContainerNo)
				select Distinct ID.OrderDetailKey,ID.InvoiceKey,OD.ContainerNo 
				from Invoicedetail ID WITH(NOLOCK)
				LEFT JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=ID.OrderDetailKey 
				LEFT JOIN InvoiceContainers IC WITH (NOLOCK) ON (IC.OrderDetailsKey=OD.OrderDetailKey) AND (IC.InvoiceKey=ID.InvoiceKey)
				WHERE ID.InvoiceKey=@InvoiceKey AND IC.OrderDetailsKey IS NULL

				INSERT INTO dbo.RouteInvoice (OrderDetailKey, InvoiceKey)
				SELECT DISTINCT OrderDetailKey,InvoiceKey
				FROM [dbo].Invoicedetail WITH(NOLOCK) 
				WHERE InvoiceKey=@InvoiceKey

				declare @InvoiceCreated int = 0
				select @InvoiceCreated = count(1) from (
					select OD.OrderDetailKey, IC.ContainerNo, IC.InvoiceKey, IH.InvoiceNo
					from #OrderDetail OD
					inner join InvoiceContainers IC WITH (NOLOCK) on OD.OrderDetailKey = IC.OrderDetailsKey
					inner join InvoiceHeader IH WITH (NOLOCK) on IC.InvoiceKey = IH.InvoiceKey
				) A

				if(Isnull(@InvoiceCreated,0) > 0)
				Begin
					SET @Status=1;
					SET @Reason = 'SUCCESS'
					select OD.OrderDetailKey, IC.ContainerNo, IC.InvoiceKey, IH.InvoiceNo
					from #OrderDetail OD
					inner join InvoiceContainers IC  WITH(NOLOCK) on OD.OrderDetailKey = IC.OrderDetailsKey
					inner join InvoiceHeader IH  WITH(NOLOCK) on IC.InvoiceKey = IH.InvoiceKey
					For JSON PATH

					DECLARE @UserName NVARCHAR(MAX)=''
					SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
					
					INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
					SELECT GETDATE(),@UserName,'Container',IC.ContainerNo,OD.OrderDetailKey,null,'Text','Invoice ' + IH.InvoiceNo + ' Created by ' +@UserName
					FROM #OrderDetail OD
					INNER JOIN InvoiceContainers IC WITH(NOLOCK) ON OD.OrderDetailKey = IC.OrderDetailsKey
					INNER JOIN InvoiceHeader IH WITH(NOLOCK) ON IC.InvoiceKey = IH.InvoiceKey

				end
				ELSE
				BEGIN
					SET @Status=0;
					SET @Reason = 'NO INVOICE CREATED'
				END
		END TRY
		BEGIN CATCH	
			print error_line()
			print Error_message()
			SET @Status=0;
			SET @Reason = 'Technical Error'
			IF @@TRANCOUNT > 0 
			--select ERROR_MESSAGE()
			ROLLBACK TRANSACTION
			RETURN;
		END CATCH
		IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
		
		
		DELETE FROM #Orders WHERE OrderKey=@OrderKey;
	END;
		
		delete from #OrderDetail
		delete from #OrderRoute
END
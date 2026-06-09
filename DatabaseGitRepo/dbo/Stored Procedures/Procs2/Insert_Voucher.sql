/*
declare @p5 bit
set @p5=0
exec [dbo].[Insert_Voucher] @RouteKeyStr='179919:180652:179388:181187:187380:180733:180983:181188:193224:193010:193225:193089:192130:',
	@UserKey=0,@DriverNote='',@InternalNote='',@OutPut=@p5 output
select @p5
*/

CREATE PROCEDURE [dbo].[Insert_Voucher] -- [Insert_Voucher] '483:489:',0,'','', @Out
@RouteKeyStr	VARCHAR(300),
@UserKey		INT,
@DriverNote		VARCHAR(300)='',
@InternalNote	VARCHAR(300)='',
@OutPut			BIT=0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @VoucherKey INT;
	DECLARE @VoucherNo	INT;
	DECLARE @DriverKey  INT;
	DECLARE @VoucherStatus SMALLINT;

	CREATE TABLE #TempData
	(
		RouteKey INT
	);

	INSERT INTO #TempData (RouteKey)
	SELECT * FROM Fn_SplitParamCol (@RouteKeyStr);

	SELECT DISTINCT A.RouteKey INTO #Route
	FROM #TempData A 
		INNER JOIN dbo.[Routes] RT WITH(NOLOCK) ON RT.RouteKey=A.RouteKey

	--*************Delete Incomplete Routes*****************
	DELETE FROM #Route
	WHERE RouteKey IN 
	(
		SELECT A.RouteKey
		FROM dbo.Routes A  WITH(NOLOCK)
			INNER JOIN dbo.#Route RT  ON RT.RouteKey=A.RouteKey
			INNER JOIN dbo.RouteStatus RTS WITH(NOLOCK) ON RTS.[Status]=A.[Status]
		WHERE RTS.[Description]<>'Leg Completed'
	)
	
	if((Select count(1) from #Route)=0)
	Begin
		print '1'
		Set @OutPut = 0;
		return;
	End


	SELECT DISTINCT RT.DriverKey INTO #Driver
	FROM #Route A
		INNER JOIN dbo.[Routes] RT WITH(NOLOCK) ON RT.RouteKey=A.RouteKey	

	if((Select count(1) from #Driver )=0)
	Begin
		print '2'
		Set @OutPut = 0;
		return;
	End

	--Declare @DriverPayItemKey	int = 0, @DriverPayItemDescr varchar(50) = ''
	--select @DriverPayItemKey = ItemKey, @DriverPayItemDescr = ItemID from item where ItemID = 'Driver Pay'

	SET @VoucherStatus= ( SELECT StatusKey FROM dbo.VoucherStatus WITH(NOLOCK) WHERE [Description]='Pending' )

	--*************************************************************
	WHILE (SELECT COUNT(1)FROM #Driver)>0
	BEGIN	
		print '3'
		SET @DriverKey = 0;
		SET @DriverKey= (SELECT TOP 1 DriverKey FROM #Driver ORDER BY DriverKey );			

		SET @VoucherNo =( SELECT ISNULL(MAX(CAST(VoucherNo AS INT)),0)+1  FROM  dbo.VoucherHeader );			

		BEGIN TRANSACTION
		BEGIN TRY
			---************** CHeck if any Expenses***********************
			update OrderExpense set Qty =  Case when  DATEDIFF(hh, DateFrom, DateTo) between 2 and 100 then DATEDIFF(hh, DateFrom, DateTo)-2 else 0 end, 
				UnitCost = I.UnitCost , NewUnitCost = I.UnitCost
			from OrderExpense OE  WITH(NOLOCK)
			inner join Item I WITH(NOLOCK) on OE.Itemkey = I.ItemKey
			inner join #Route R on OE.RouteKey = R.RouteKey
			where  OE.itemkey in (select itemkey from item where PriceBasisKey = 3)

			SELECT DISTINCT @VoucherKey AS Voucherkey,I.ItemKey,I.[Description] AS ItemDescription,
				COALESCE(A.NewUnitCost,A.UnitCost,I.UnitCost) AS UnitCost,			
				CASE WHEN A.Qty=0 THEN 1 WHEN A.Qty IS NULL THEN 1 ELSE A.Qty END AS Qty,	
				NULL AS [ExtCost],
				RT.RouteKey,GETDATE() AS CreateDate ,@UserKey AS CreateUserKey,A.OrderExpenseKey 
			INTO #VoucherLine
			FROM OrderExpense A WITH(NOLOCK)
				INNER JOIN dbo.Item		I WITH(NOLOCK) ON I.ItemKey=A.Itemkey
				INNER JOIN dbo.ItemType IT WITH(NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
				INNER JOIN dbo.[Routes] RT WITH(NOLOCK) ON RT.RouteKey=A.RouteKey
				INNER JOIN  dbo.OrderHeader OH WITH(NOLOCK)	ON OH.OrderKey=RT.OrderKey
				INNER JOIN #Route R		   ON R.RouteKey=RT.RouteKey
				--INNER JOIN dbo.[Address] D ON D.AddrKey=RT.DestinationAddrKey	
				LEFT  join dbo.ItemCategory C on I.categoryKey = C.CategoryKey
			--WHERE  RT.DriverKey = @DriverKey
			WHERE  RT.DriverKey = @DriverKey and IT.ItemType in ('Expense','Expense + Service') 
				--and  isnull(C.name, '') <> 'Warehouse'

			IF ( SELECT COUNT(1) FROM #VoucherLine )=0
			BEGIN  		
				GOTO LastLine;
			END	
			
			--*************************************************************
			INSERT INTO [dbo].VoucherHeader( [VoucherNo],[VoucherDate], [BillToAddrKey], [VoucherAmount], [DueDate], [IsPaymentApproved]
						, [CompanyKey], [StatusKey],CreateDate,CreateUserKey,PmtApprovedUser,DriverNote,InternalNote )
			SELECT DISTINCT @VoucherNo,GETDATE()AS VoucherDate,AD.AddrKey AS BillTOAddressKey,0,NULL,0,1,@VoucherStatus,
					GETDATE(),@UserKey,NULL,@DriverNote,@InternalNote
			FROM [Routes] RT  WITH(NOLOCK)
				INNER JOIN  dbo.OrderHeader OH WITH(NOLOCK)	ON OH.OrderKey=RT.OrderKey
				INNER JOIN  dbo.Driver DR WITH(NOLOCK)		ON DR.DriverKey=RT.DriverKey
				INNER JOIN #Route R				ON R.RouteKey=RT.RouteKey
				INNER JOIN  dbo.[Address] AD WITH(NOLOCK)	ON AD.AddrKey=DR.AddrKey			
			WHERE RT.DriverKey = @DriverKey;	
			
			SET @VoucherKey= ( SELECT SCOPE_IDENTITY() ) ;	

			print '4'

			UPDATE #VoucherLine
			SET Voucherkey=@VoucherKey
		
			INSERT INTO [dbo].[VoucherDetail](Voucherkey,[ItemKey],[Description],A.[UnitCost],[Qty],
			[ExtCost],RouteKey,CreateDate,CreateUserKey)
			SELECT Voucherkey,ItemKey,ItemDescription,UnitCost,Qty,[ExtCost],
				RouteKey,CreateDate,CreateUserKey
			FROM #VoucherLine WHERE UnitCost<>-1 		

			print '5'

			UPDATE [VoucherDetail]
			SET ExtCost= (UnitCost*Qty)
			WHERE Voucherkey=@VoucherKey;			

			print '6'

			UPDATE dbo.VoucherHeader
			SET VoucherAmount=  ISNULL(( SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WITH(NOLOCK) WHERE VoucherKey= @VoucherKey ),0)
			WHERE VoucherKey= @VoucherKey;
			
			print '7'

			INSERT INTO dbo.RouteVouchers ( RouteKey,VoucherKey)
			SELECT DISTINCT RouteKey,Voucherkey
			FROM [dbo].[VoucherDetail]  WITH(NOLOCK)
			WHERE Voucherkey= @VoucherKey;

			set @OutPut = 1
			print '8'
			
			LastLine:
			print 'ERROR'
		END TRY
		BEGIN CATCH			
					SET @OutPut=0;
					print ERROR_MESSAGE()
					IF @@TRANCOUNT > 0 
					begin
						--print ERROR_MESSAGE()
						ROLLBACK TRANSACTION
					end
		END CATCH
		IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
		
		DELETE FROM #Driver WHERE DriverKey=@DriverKey;

		IF OBJECT_ID('tempdb..#VoucherLine') IS NOT NULL DROP TABLE #VoucherLine
	END;
	
	--SET @OutPut=1;
END
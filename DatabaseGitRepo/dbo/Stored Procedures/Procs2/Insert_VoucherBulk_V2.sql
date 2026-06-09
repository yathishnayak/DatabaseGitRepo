/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"RouteKeyStr":"179919:180652:179388:181187:187380:180733:180983:181188:193224:193010:193225:193089:192130:","DriverNote":"","InternalNote":""}'
	exec Insert_VoucherBulk_V2 @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Insert_VoucherBulk_V2] 
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

	Declare	@RouteKeyStr	VARCHAR(max),
			@DriverNote		VARCHAR(300)='',
			@InternalNote	VARCHAR(300)='',
			@OutPut			BIT=0 

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @RouteKeyStr = RouteKeyStr
	from OpenJSON(@JsonString, '$')
	WITH (
		RouteKeyStr			varchar(max)			'$.RouteKeyStr',
		DriverNote			varchar(300)			'$.DriverNote',
		InternalNote		varchar(300)			'$.InternalNote'
	)
	if(isnull(ltrim(rtrim(@RouteKeyStr)),'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Nothing selected to Create Vouchers No not found'
		return
	End
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
		INNER JOIN dbo.[Routes] RT ON RT.RouteKey=A.RouteKey

	--*************Delete Incomplete Routes*****************
	DELETE FROM #Route
	WHERE RouteKey IN 
	(
		SELECT A.RouteKey
		FROM dbo.Routes A 
			INNER JOIN dbo.#Route RT ON RT.RouteKey=A.RouteKey
			INNER JOIN dbo.RouteStatus RTS ON RTS.[Status]=A.[Status]
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
		INNER JOIN dbo.[Routes] RT ON RT.RouteKey=A.RouteKey	

	if((Select count(1) from #Driver )=0)
	Begin
		print '2'
		Set @OutPut = 0;
		return;
	End

	SELECT @VoucherStatus =StatusKey FROM dbo.VoucherStatus WHERE [Description]='Pending'

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
			from OrderExpense OE 
			inner join Item I on OE.Itemkey = I.ItemKey
			inner join #Route R on OE.RouteKey = R.RouteKey
			where  OE.itemkey in (select itemkey from item where PriceBasisKey = 3)

			SELECT DISTINCT @VoucherKey AS Voucherkey,I.ItemKey,I.[Description] AS ItemDescription,
				COALESCE(A.NewUnitCost,A.UnitCost,I.UnitCost) AS UnitCost,			
				CASE WHEN A.Qty=0 THEN 1 WHEN A.Qty IS NULL THEN 1 ELSE A.Qty END AS Qty,	
				NULL AS [ExtCost],
				RT.RouteKey,GETDATE() AS CreateDate ,@UserKey AS CreateUserKey,A.OrderExpenseKey 
			INTO #VoucherLine
			FROM OrderExpense A 
				INNER JOIN dbo.Item		I  ON I.ItemKey=A.Itemkey
				INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey
				INNER JOIN dbo.[Routes] RT ON RT.RouteKey=A.RouteKey
				INNER JOIN  dbo.OrderHeader OH	ON OH.OrderKey=RT.OrderKey
				INNER JOIN #Route R		   ON R.RouteKey=RT.RouteKey
				LEFT  join dbo.ItemCategory C on I.categoryKey = C.CategoryKey
			WHERE  RT.DriverKey = @DriverKey and IT.ItemType in ('Expense','Expense + Service') 

			IF ( SELECT COUNT(1) FROM #VoucherLine )=0
			BEGIN  		
				GOTO LastLine;
			END	
			
			--*************************************************************
			INSERT INTO [dbo].VoucherHeader( [VoucherNo],[VoucherDate], [BillToAddrKey], [VoucherAmount], [DueDate], [IsPaymentApproved]
						, [CompanyKey], [StatusKey],CreateDate,CreateUserKey,PmtApprovedUser,DriverNote,InternalNote )
			SELECT DISTINCT @VoucherNo,GETDATE()AS VoucherDate,AD.AddrKey AS BillTOAddressKey,0,NULL,0,1,@VoucherStatus,
					GETDATE(),@UserKey,NULL,@DriverNote,@InternalNote
			FROM [Routes] RT 
				INNER JOIN  dbo.OrderHeader OH	ON OH.OrderKey=RT.OrderKey
				INNER JOIN  dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
				INNER JOIN #Route R				ON R.RouteKey=RT.RouteKey
				INNER JOIN  dbo.[Address] AD	ON AD.AddrKey=DR.AddrKey			
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
			SET VoucherAmount=  ISNULL(( SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WHERE VoucherKey= @VoucherKey ),0)
			WHERE VoucherKey= @VoucherKey;
			
			print '7'

			INSERT INTO dbo.RouteVouchers ( RouteKey,VoucherKey)
			SELECT DISTINCT RouteKey,Voucherkey
			FROM [dbo].[VoucherDetail] 
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
						ROLLBACK TRANSACTION
					end
					SEt @Status = 0
					Set @Reason = 'Technical Error'
		END CATCH
		IF @@TRANCOUNT > 0  
				COMMIT TRANSACTION;
		
		DELETE FROM #Driver WHERE DriverKey=@DriverKey;

		IF OBJECT_ID('tempdb..#VoucherLine') IS NOT NULL DROP TABLE #VoucherLine
		SEt @Status = 1
		Set @Reason = 'SUCCESS'
	END;
	
	--SET @OutPut=1;
END

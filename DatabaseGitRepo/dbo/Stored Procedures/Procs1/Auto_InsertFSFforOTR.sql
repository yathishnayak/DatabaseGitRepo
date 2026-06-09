--Exec Auto_InsertFSFforOTR   262327, 1
CREATE   Proc [dbo].[Auto_InsertFSFforOTR]
(
	@InvoiceKey	int ,
	@IsDebug	bit = 0
)
as 
Begin

	if(ISNULL(@InvoiceKey,0) = 0)
	BEGIN
		RETURN;
	END

	--declare @InvoiceKey	int = 264054 --262954 -- 261711 -- 

	declare @FSCitemKey	int = 0,
			@InvoiceNo	varchar(50) = '',
			@DrayBaseItemKey	int= 0,
			@FSCCountinInvoice	INT = 0,
			@FSCExistsinInvoice	BIT = 0,
			@InvoiceStatusKey	int = 0,
			@InvoiceDate DATETIME='',
			@MarketLocationKey	INT=0,
			@OrderDetailKey INt=0

	SElect @InvoiceStatusKey = StatusKey ,@InvoiceDate=InvoiceDate
		from InvoiceHeader WITH (NOLOCK) where Invoicekey = @InvoiceKey

	SELECT TOP 1 @OrderDetailKey= OrderDetailKey FROM InvoiceDetail ID WITH (NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @MarketLocationKey=MarketLocationKey 
					FROM (SELECT OrderKey FROM OrderDetail ODI  WITH (NOLOCK) WHERE Orderdetailkey=@OrderDetailKey) OD
					INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey

	if(@InvoiceStatusKey <> 1)
	Begin
		Return;
	End
	ELSE
	BEGIN
		select @InvoiceNo = InvoiceNo from InvoiceHeader IH where Invoicekey = @InvoiceKey
		select  @FSCitemKey = Itemkey from item where Description like '%Fuel sur%' and StatusKey = 1 
			and ItemTypeKey  = 1 AND ItemKey = MasterItemKey

		select  @DrayBaseItemKey = Itemkey from item where Description like '%Dray%' and StatusKey = 1 
			and ItemTypeKey  = 1 AND ItemKey = MasterItemKey

	

		select OrderDetailsKey, 
				ID1.ItemKey as FSCItemKey, 
				ID1.ExtAmt as FSCExtAmt,
				ID2.ItemKey as DBItemKey ,
				ID2.SellPrice as DBExtAmt,
				IC.ContainerNo
		into #Containers 
		from InvoiceContainers  IC
		LEft join InvoiceDetail ID1 on IC.InvoiceKey = ID1.InvoiceKey 
			and IC.ContainerNo = Id1.Container and ID1.ItemKey = @FSCitemKey
		LEft join InvoiceDetail ID2 on IC.InvoiceKey = ID2.InvoiceKey 
			and IC.ContainerNo = Id2.Container and ID2.ItemKey = @DrayBaseItemKey
		where IC.invoicekey = @InvoiceKey

		alter table #containers add IsOTRExists Bit default 0, OTRPercent decimal(18,4)


		update C set IsOTRExists =  convert(BIT,1)
		from #Containers C
		inner join vContainerType VT on C.OrderDetailsKey = Vt.OrderDetailKey
		where TypeID = 'OTR'

		--Update #Containers set OTRPercent = case when IsOTRExists = 1 then 0.10 else 0.05 end
		--	where FSCItemkey is null
		/* **********************
		Commented above lines and added below if else block on 2026-03-24 as per kathryn's request

		********************** */
		IF(@InvoiceDate<CAST('2026-03-24' AS DATE))
		BEGIN
			Update #Containers set OTRPercent = case when IsOTRExists = 1 then 0.10 else 0.05 end
				where FSCItemkey is null
		END
		ELSE
		BEGIN
			IF(@MarketLocationKey=3)
			BEGIN
				IF(@InvoiceDate<CAST('2026-03-31' AS DATE))
				BEGIN
					Update #Containers set OTRPercent = 0.125
						where FSCItemkey is null
				END
				ELSE
				BEGIN
					Update #Containers set OTRPercent = 0.15
						where FSCItemkey is null
				END
			END
			ELSE IF(@MarketLocationKey=2)
			BEGIN
				IF(@InvoiceDate<CAST('2026-04-06' AS DATE))
				BEGIN
					Update #Containers set OTRPercent = case when IsOTRExists = 1 then 0.20 else 0.125 end
						where FSCItemkey is null
				END
				ELSE
				BEGIN
					Update #Containers set OTRPercent = 0.15
						where FSCItemkey is null
				END
			END
		END

		DECLARE @OrderDetailsKey	Int, 
				@FSCExtAmt			Decimal(18,6)=0, 
				@DBExtAmt			Decimal(18,6)=0,
				@ContainerNo		varchar(20)

		DECLARE cursor_results CURSOR FOR 
				SELECT OrderDetailsKey, FSCExtAmt, DBExtAmt, ContainerNo from #Containers;
		OPEN cursor_results;
		FETCH NEXT FROM cursor_results INTO @OrderDetailsKey, @FscExtAmt, @DBExtAmt, @ContainerNo
		WHILE @@FETCH_STATUS = 0
		BEGIN
			select @FSCCountinInvoice = count(1)  from invoicedetail 
				where invoicekey = @Invoicekey and itemkey = @FSCitemKey AND cONTAINER = @ContainerNo

			if (@FSCExistsinInvoice = 0)
			Begin
				select @FSCExistsinInvoice = case when Isnull(@FSCCountinInvoice,0) = 0 then convert(bit,0) else convert(bit,1) end
				Declare @JsonOutput	nvarchar(max) = ''
				Exec SELL_GetInvoiceItemSellPrice @DrayBaseItemKey, @InvoiceKey, @ContainerNo, @JsonOutput Output, @IsDebug

				IF(@IsDebug = 1)
				Begin
					select @JsonOutput as JsonOutput
				End
				Declare @StrDB varchar(100)
				IF(@JsonOutput = '')
				Begin
					PRINT 'NO SELL PRICE DATA'
					update C set 
						DBExtAmt = ID.SellPrice, FSCExtAmt = ID.SellPrice * OTRPercent 
					from #Containers C
					inner join invoiceDetail  ID on Id.InvoiceKey = @InvoiceKey and ID.ItemKey = c.DBItemKey
					and ID.Container = @ContainerNo

				End
				Else if(@JsonOutput  <> '')
				Begin
					PRINT 'SELL PRICE DATA EXISTS'
					set @StrDB = JSON_VALUE(@JsonOutput,'$.Rate')
					print @StrDb
					set @DBExtAmt = convert(float, Isnull( @StrDB,'0'))
					print 'DBExtAmt'
					print @DbExtAmt

					update #Containers set DBExtAmt = @DBExtAmt, FSCExtAmt = @DBExtAmt * OTRPercent 
					where OrderDetailsKey = @OrderDetailsKey
				End
				if(@IsDebug = 1)
				Begin
					select * from #Containers where OrderDetailsKey = @OrderDetailsKey
				End
			END
			FETCH NEXT FROM cursor_results INTO @OrderDetailsKey, @FscExtAmt, @DBExtAmt, @ContainerNo
		END
		CLOSE cursor_results;
		DEALLOCATE cursor_results;

		
		/* **********************
		COLUMNS ADDED FOR PERCENTAGE CALCS
			Table InvoiceDetail
			-------------------
			IsPercentage
			Percentage
			BaseSellPrice
			DatePercentCalc
		********************** */
		/* *******************
			IF OTR IS SELECTED AS CONTAINER PROPERTY, FSC = 10%
			IF OTR IS NOT SELECTED AS THE PROPERTY, FSC = 5%
			IF FSC ALREADY EXISTS, USE SAME %
		* ************** */
		if(@IsDebug = 1)
		Begin
			Select @InvoiceNo as Invoiceno, * from #Containers
		end

		IF(@MarketLocationKey in (2,3))
		BEGIN
			insert into Invoicedetail (InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, 
				OrderDetailKey, CreateUserKey, CreateDate, UpdateUserKey, UpdateDate, Charges, SellPrice, 
				BvsNB, FreeTime, Minval, MaxVal, TimeDuration, ItemNotes, ReportedCost, 
				IsPercentage, Percentage, BaseSellPrice, DatePercentCalc) 
			select @InvoiceKey, @FSCitemKey, I.InvoiceItemDesc, 
				FSCExtAmt as UnitPrice, 1 as Qty, FSCExtAmt, ContainerNo, OrderDetailsKey, 
				1 asCreateUserKey, CreateDate, null UpdateUserKey, null UpdateDate, 
				FSCExtAmt Charges, DBExtAmt SellPrice,1 BvsNB, 
				0 FreeTime, 0 Minval, 0 MaxVal,  null TimeDuration, 
				'FSC Added Auto - ' + replace(convert(varchar(50), OTRPErcent * 100 ),'.00','%') 
					+ ' On Draybase  Sell Price  '+ convert(varchar(50),dbExtAmt) as ItemNotes, 
				null ReportedCost,
				convert(Bit, 1) as IsPercentage, OTRPercent as [PErcent], 
				DBExtAmt as BaseSellPrice, GetDate() as DatePercentCalc
			From #Containers A
			inner join Item I on @FSCitemKey = I.ItemKey
			where A.FSCItemKey is null --and isnull(DBExtAmt,0) > 0
		END

		drop table #Containers
		
	End -- INVOICE STATUS KEY CHECK END
End

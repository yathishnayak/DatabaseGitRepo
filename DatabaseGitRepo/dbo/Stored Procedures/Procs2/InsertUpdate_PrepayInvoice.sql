
CREATE proc [dbo].[InsertUpdate_PrepayInvoice]
(
	@JSONString		nvarchar(max),
	@Status			bit = 0 OUTPUT,
	@Key			bigint	= 0 OUTPUT,
	@CreatedUserKey	int = 0
)
as
BEGIN
	if(@JSONString = '')
	Begin
		set @Status = 0;
		SEt @Key = 0;
		return;
	End

	if(@JSONString <> '')
	BEGIN
		SELECT * INTO #TempHeader FROM PrepayInvoiceHeader  where 1 = 0
		SELECT * INTO #TempDetail from PrepayInvoiceDetail  where 1 = 0


		set identity_insert #TempHeader ON
		INSERT INTO #TempHeader (PPInvoiceKey, PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,
			OrderKey, InternalNotes, CustomerNotes, OrderNo, CustomerKey, BillToAddressKey, 
			PPInvoiceSentDate, PPInvoiceConfirmDate, StatusKey)
		SELECT PPInvoiceKey, PPInvoiceNo, convert(datetime,PPInvoiceDate), PPInvoiceAmount,
			OrderKey, InternalNotes, CustomerNotes, OrderNo, CustomerKey, BillToAddressKey, 
			PPInvoiceSentDate, PPInvoiceConfirmDate, StatusKey FROM  OPENJSON(@JSONString)
		WITH
		(
			PPInvoiceKey			bigint			 '$.PPInvoiceKey',
			PPInvoiceNo				varchar(20)		 '$.PPInvoiceNo',
			PPInvoiceDate			varchar(50)		 '$.PPInvoiceDate',
			PPInvoiceAmount			decimal(18,4)	 '$.PPInvoiceAmount',
			OrderKey				int				 '$.OrderKey',
			OrderNo					varchar(50)		 '$.OrderNo',
			CustomerKey				int				 '$.CustomerKey',
			BillToAddressKey		int				 '$.BillToAddressKey',
			PPInvoiceSentDate		DateTime		 '$.PPInvoiceSentDate',
			PPInvoiceConfirmDate	Datetime		 '$.PPInvoiceConfirmDate',
			StatusKey				int				 '$.StatusKey',
			InternalNotes			varchar(2000)	 '$.InternalNotes',
			CustomerNotes			varchar(2000)	 '$.CustomerNotes'
		)
		set identity_insert #TempHeader OFF

		set identity_insert #TempDetail ON
		INSERT INTO #TempDetail (PPInvoiceKey, PPInvoiceLineKey,ContainerNo, ItemKey, UnitPrice,Quantity, ExtCost)
		SELECT * FROM  OPENJSON(@JSONString,'$.PrepayInvoiceDetail')
		WITH
		(
			[PPInvoiceKey] [bigint]				'$.PPInvoiceKey',
			[PPInvoiceLineKey] [bigint]			'$.PPInvoiceLineKey',
			[ContainerNo]	varchar(20)			'$.ContainerNo',
			[ItemKey] [int]						'$.ItemKey',
			[UnitPrice] [decimal](18, 5)		'$.UnitPrice',
			Quantity [decimal](18, 5)			'$.Quantity',
			[ExtCost] [decimal](18, 5)			'$.ExtCost'
		)
		set identity_insert #TempDetail OFF

		update H Set OrderKey = OH.OrderKey
		--select *
		from #TempHeader H
		inner join OrderHeader OH on H.OrderNo = OH.OrderNo and H.CustomerKey = OH.CustKey

		DECLARE @HCount	int = 0, @DCount int = 0, @PrepayInvoiceKey bigint = 0, @Total decimal(18,2)
		SELECT @HCount = COUNT(1) FROM #TempHeader
		SELECT @DCount = COUNT(1) FROM #TempDetail
		select top 1 @PrepayInvoiceKey = PPInvoiceKey from #TempHeader

		if(isnull(@PrepayInvoiceKey,0) = 0)
		BEGIN
			INSERT INTO PrepayInvoiceHeader 
				(PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,OrderKey,OrderNo, CustomerKey, 
					InternalNotes, CustomerNotes,
					BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, CreatedDate, CreatedUserKey)
			select PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,OrderKey,OrderNo, CustomerKey, 
					InternalNotes, CustomerNotes,
					BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, GETDATE(), @CreatedUserKey
			from #TempHeader

			 SET @PrepayInvoiceKey=(SELECT SCOPE_IDENTITY());

			 update H
				SET PPInvoiceNo = 'PI-' + convert(varchar,PPInvoiceKey),
				StatusKey = 1
			 from PrepayInvoiceHeader H
			 where PPInvoiceKey = @PrepayInvoiceKey

			 insert into PrepayInvoiceDetail
			 (PPInvoiceKey,ContainerNo, ItemKey, UnitPrice,Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @PrepayInvoiceKey,ContainerNo, ItemKey,Quantity, UnitPrice, ExtCost, GETDATE(), @CreatedUserKey
			 from #TempDetail

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from PrepayInvoiceDetail  WITH (NOLOCK) 
			 where PPInvoiceKey = @PrepayInvoiceKey

			 update PrepayInvoiceHeader set PPInvoiceAmount = @Total
			 where PPInvoiceKey = @PrepayInvoiceKey

			 SET @Status  = 1
			 SEt @Key = @PrepayInvoiceKey
		END
		ELSE
		BEGIN
			update H set
				PPInvoiceNo = T.PPInvoiceNo,
				PPInvoiceDate = T.PPInvoiceDate,
				PPInvoiceAmount = T.PPInvoiceAmount,
				OrderKey = T.OrderKey,
				OrderNo = T.OrderNo,
				CustomerKey = T.CustomerKey,
				BillToAddressKey = T.BillToAddressKey, 
				PPInvoiceSentDate = T.PPInvoiceSentDate,
				PPInvoiceConfirmDate = T.PPInvoiceConfirmDate,
				InternalNotes = T.InternalNotes,
				CustomerNotes = t.CustomerNotes,
				UpdateDate = GETDATE(),
				UpdatedUserKey = @CreatedUserKey
			from PrepayInvoiceHeader H  WITH (NOLOCK) 
			inner join #TempHeader T  WITH (NOLOCK)  on H.PPInvoiceKey = T.PPInvoiceKey

			update D set
				ContainerNo = T.ContainerNo,
				ItemKey = T.ItemKey,
				UnitPrice = T.UnitPrice,
				Quantity = T.Quantity,
				ExtCost = T.ExtCost,
				UpdateDate = GETDATE(),
				UpdatedUserKey = @CreatedUserKey
			from PrepayInvoiceDetail D  WITH (NOLOCK) 
			inner join #TempDetail T  WITH (NOLOCK)  on D.PPInvoiceKey = T.PPInvoiceKey and D.PPInvoiceLineKey = T.PPInvoiceLineKey

			insert into PrepayInvoiceDetail
			 (PPInvoiceKey,ContainerNo, ItemKey, UnitPrice, Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @PrepayInvoiceKey,T.ContainerNo, T.ItemKey, T.UnitPrice,T.Quantity, T.ExtCost, GETDATE(), @CreatedUserKey
			 from #TempDetail T  WITH (NOLOCK) 
			 LEft JOIN PrepayInvoiceDetail D  WITH (NOLOCK)  on T.PPInvoiceKey = D.PPInvoiceKey and T.PPInvoiceLineKey = D.PPInvoiceLineKey
			 where D.PPInvoiceKey is null

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from PrepayInvoiceDetail WITH (NOLOCK) 
			 where PPInvoiceKey = @PrepayInvoiceKey

			 update PrepayInvoiceHeader set PPInvoiceAmount = @Total
			 where PPInvoiceKey = @PrepayInvoiceKey

			 SET @Status  = 1
			 Select @Key = PPInvoiceKey from #TempHeader
		END

		drop table #TempHeader
		drop table #TempDetail
	END
END

/*
declare @json nvarchar(max), @status bit = 0, @key bigint = 0, @userKey int = 29
set @json = '{"MInvoiceKey":0,"MInvoiceNo":null,"MInvoiceDate":"2022-11-19T00:00:00Z","MInvoiceAmount":100.0,"OrderKey":0,"OrderNo":"1234","CustomerKey":15,"BillToAddressKey":185,"MInvoiceSentDate":"2022-01-01T00:00:00","MInvoiceConfirmDate":"2022-01-01T00:00:00","CreatedDate":"0001-01-01T00:00:00","CreatedUserKey":29,"UpdateDate":"0001-01-01T00:00:00","UpdatedUserKey":29,"StatusKey":0,"InternalNotes":"Int notes","CustomerNotes":"Cust Notes","IsFactored":false,"BrokerRef":"ab33232","ManualInvoiceDetail":[{"MInvoiceKey":0,"MInvoiceLineKey":0,"ContainerNo":"ABCDE12345Z","ItemKey":41,"InvoiceItemDesc":"AFTER HOURS P/U","UnitPrice":100.0,"Quantity":1.0,"ExtCost":100.0,"CreatedDate":"0001-01-01T00:00:00","CreatedUserKey":0,"UpdateDate":"0001-01-01T00:00:00","UpdatedUserKey":0}],"orderHeader":null,"SteamShipLineKey":13,"SteamShipLineName":null,"SteamShipLineRef":"112233"}'
exec [InsertUpdate_ManualInvoice] @json, @status output, @key output, @userKey
select @Key, @status
*/
CREATE Procedure [dbo].[InsertUpdate_ManualInvoice]
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
		SELECT * INTO #TempHeader FROM ManualInvoiceHeader  where 1 = 0
		SELECT * INTO #TempDetail from ManualInvoiceDetail  where 1 = 0
		

		set identity_insert #TempHeader ON
		INSERT INTO #TempHeader (MInvoiceKey, MInvoiceNo, MInvoiceDate, MInvoiceAmount,OrderKey,OrderNo, 
			InternalNotes, CustomerNotes, SteamShipLineKey, SteamShipLineRef,
		CustomerKey, BillToAddressKey, MInvoiceSentDate, MInvoiceConfirmDate, StatusKey, BrokerRef, OriginalInvoiceNo,InvoiceCompanyKey)
		SELECT MInvoiceKey, MInvoiceNo, MInvoiceDate, MInvoiceAmount,OrderKey,OrderNo, 
			InternalNotes, CustomerNotes, SteamShipLineKey, SteamShipLineRef,
		CustomerKey, BillToAddressKey, MInvoiceSentDate, MInvoiceConfirmDate, StatusKey, BrokerRef, OriginalInvoiceNo,InvoiceCompanyKey
		FROM  OPENJSON(@JSONString)
		WITH
		(
			MInvoiceKey				bigint			 '$.MInvoiceKey',
			MInvoiceNo				varchar(20)		 '$.MInvoiceNo',
			MInvoiceDate			Datetime		 '$.MInvoiceDate',
			MInvoiceAmount			decimal(18,4)	 '$.MInvoiceAmount',
			OrderKey				int				 '$.OrderKey',
			OrderNo					varchar(50)		 '$.OrderNo',
			CustomerKey				int				 '$.CustomerKey',
			BillToAddressKey		int				 '$.BillToAddressKey',
			MInvoiceSentDate		DateTime		 '$.MInvoiceSentDate',
			MInvoiceConfirmDate	Datetime			 '$.MInvoiceConfirmDate',
			StatusKey				int				 '$.StatusKey',
			InternalNotes			varchar(2000)	 '$.InternalNotes',
			CustomerNotes			varchar(2000)	 '$.CustomerNotes',
			BrokerRef				varchar(50)		 '$.BrokerRef',
			SteamShipLineKey		int				 '$.SteamShipLineKey',
			SteamShipLineRef		varchar(100)	 '$.SteamShipLineRef',
			OriginalInvoiceNo		varchar(50)		 '$.OriginalInvoiceNo',
			InvoiceCompanyKey		int				 '$.InvoiceCompanyKey' 
		)
		set identity_insert #TempHeader OFF

		set identity_insert #TempDetail ON
		INSERT INTO #TempDetail (MInvoiceKey, MInvoiceLineKey,ContainerNo, ItemKey, UnitPrice,Quantity, ExtCost)
		SELECT * FROM  OPENJSON(@JSONString,'$.ManualInvoiceDetail')
		WITH
		(
			[MInvoiceKey] [bigint]				'$.MInvoiceKey',
			[MInvoiceLineKey] [bigint]			'$.MInvoiceLineKey',
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

		DECLARE @HCount	int = 0, @DCount int = 0, @ManualInvoiceKey bigint = 0, @Total decimal(18,2)
		SELECT @HCount = COUNT(1) FROM #TempHeader
		SELECT @DCount = COUNT(1) FROM #TempDetail
		select top 1 @ManualInvoiceKey = MInvoiceKey from #TempHeader
		select  MInvoiceNo from #TempHeader
		if(isnull(@ManualInvoiceKey,0) = 0)
		BEGIN
			declare @ManualInvNo varchar(20)
			select @ManualInvNo = MInvoiceNo from #TempHeader
			if(isnull(@ManualInvNo,'')='')
			begin
				declare @tempMInvNo varchar(20)
				select  @tempMInvNo = 'M-' + convert(varchar(20), max(MInvoiceKey) +1) from ManualInvoiceHeader
				print @tempMInvNo
				if((select count(1) from ManualInvoiceHeader where MInvoiceNo = @tempMInvNo)>0)
				begin
					set @ManualInvNo = @tempMInvNo + 'B'

				end
				else
				begin
					set @ManualInvNo = @tempMInvNo
				end
				update #TempHeader set MInvoiceNo = @tempMInvNo
			end
			else if(left(@ManualInvNo,2) <> 'M-')
			begin
				set @ManualInvNo = 'M-' + @ManualInvNo
				update #TempHeader set MInvoiceNo = @ManualInvNo
			end
			INSERT INTO ManualInvoiceHeader 
				(MInvoiceNo, MInvoiceDate, MInvoiceAmount,OrderKey,OrderNo, CustomerKey, BillToAddressKey, 
				 InternalNotes, CustomerNotes, MInvoiceSentDate, MInvoiceConfirmDate, 
				 CreatedDate, CreatedUserKey, BrokerRef, SteamShipLineKey, SteamShipLineRef, OriginalInvoiceNo,InvoiceCompanyKey)
			select MInvoiceNo, MInvoiceDate, MInvoiceAmount,OrderKey,OrderNo, CustomerKey, BillToAddressKey, 
						InternalNotes, CustomerNotes,MInvoiceSentDate, MInvoiceConfirmDate, 
						GETDATE(), @CreatedUserKey, BrokerRef, SteamShipLineKey, SteamShipLineRef, OriginalInvoiceNo,InvoiceCompanyKey
			from #TempHeader

			 SET @ManualInvoiceKey=(SELECT SCOPE_IDENTITY());

			 update H SET
				-- MInvoiceNo = 'MI-' + convert(varchar,MInvoiceKey),
				StatusKey = 1
			 from ManualInvoiceHeader H
			 where MInvoiceKey = @ManualInvoiceKey

			 insert into ManualInvoiceDetail
			 (MInvoiceKey,ContainerNo, ItemKey, UnitPrice,Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @ManualInvoiceKey,ContainerNo, ItemKey,UnitPrice, Quantity,  ExtCost, GETDATE(), @CreatedUserKey
			 from #TempDetail

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from ManualInvoiceDetail  WITH (NOLOCK) 
			 where MInvoiceKey = @ManualInvoiceKey

			 update ManualInvoiceHeader set MInvoiceAmount = @Total
			 where MInvoiceKey = @ManualInvoiceKey

			 SET @Status  = 1
			 SEt @Key = @ManualInvoiceKey
		END
		ELSE
		BEGIN
			update H set
				MInvoiceNo = T.MInvoiceNo,
				MInvoiceDate = T.MInvoiceDate,
				MInvoiceAmount = T.MInvoiceAmount,
				OrderKey = T.OrderKey,
				OrderNo = T.OrderNo,
				CustomerKey = T.CustomerKey,
				BillToAddressKey = T.BillToAddressKey, 
				MInvoiceSentDate = T.MInvoiceSentDate,
				MInvoiceConfirmDate = T.MInvoiceConfirmDate,
				InternalNotes = T.InternalNotes,
				CustomerNotes = T.CustomerNotes,
				BrokerRef = T.BrokerRef ,
				SteamShipLineKey = T.SteamShipLineKey, 
				SteamShipLineRef = T.SteamShipLineRef,
				OriginalInvoiceNo = T.OriginalInvoiceNo,
				InvoiceCompanyKey = T.InvoiceCompanyKey,
				UpdateDate = GETDATE(),
				UpdatedUserKey = @CreatedUserKey
			from ManualInvoiceHeader H  WITH (NOLOCK) 
			inner join #TempHeader T  WITH (NOLOCK)  on H.MInvoiceKey = T.MInvoiceKey

			update D set
				ContainerNo = T.ContainerNo,
				ItemKey = T.ItemKey,
				UnitPrice = T.UnitPrice,
				Quantity = T.Quantity,
				ExtCost = T.ExtCost,
				UpdateDate = GETDATE(),
				UpdatedUserKey = @CreatedUserKey
			from ManualInvoiceDetail D  WITH (NOLOCK) 
			inner join #TempDetail T  WITH (NOLOCK)  on D.MInvoiceKey = T.MInvoiceKey and D.MInvoiceLineKey = T.MInvoiceLineKey

			insert into ManualInvoiceDetail
			 (MInvoiceKey,ContainerNo, ItemKey, UnitPrice, Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @ManualInvoiceKey,T.ContainerNo, T.ItemKey, T.UnitPrice,T.Quantity, T.ExtCost, GETDATE(), @CreatedUserKey
			 from #TempDetail T  WITH (NOLOCK) 
			 LEft JOIN ManualInvoiceDetail D  WITH (NOLOCK)  on T.MInvoiceKey = D.MInvoiceKey and T.MInvoiceLineKey = D.MInvoiceLineKey
			 where D.MInvoiceKey is null

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from ManualInvoiceDetail WITH (NOLOCK) 
			 where MInvoiceKey = @ManualInvoiceKey

			 update ManualInvoiceHeader set MInvoiceAmount = @Total
			 where MInvoiceKey = @ManualInvoiceKey

			 SET @Status  = 1
			 Select @Key = MInvoiceKey from #TempHeader
		END

		drop table #TempHeader
		drop table #TempDetail
	END
END

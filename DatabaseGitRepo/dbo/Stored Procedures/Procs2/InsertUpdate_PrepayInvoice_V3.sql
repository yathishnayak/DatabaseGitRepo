/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{
	"PrepayInvoiceDetail": [
			{
				"PPInvoiceLineKey": 0,
				"IsEditMode": false,
				"ContainerNo": "6363",
				"ItemKey": "373",
				"InvoiceItemDesc": "Bonded Fee",
				"Quantity": "20",
				"ExtCost": 20000,
				"UnitPrice": 1000,
				"PPInvoiceKey": 0
			},
			{
				"PPInvoiceLineKey": 0,
				"IsEditMode": false,
				"ContainerNo": "5252",
				"ItemKey": "283",
				"InvoiceItemDesc": "Customer Stop Off",
				"Quantity": "10",
				"ExtCost": 5200,
				"UnitPrice": 520,
				"PPInvoiceKey": 0
			}
		],
		"CustKey": 1633,
		"PPInvoiceKey": 0,
		"BillToAddressKey": 37,
		"OrderNo": "ACL02240701",
		"IsOrderNoValid": true,
		"InternalNotes": "1",
		"CustomerNotes": "2",
		"PPInvoiceAmount": 25200,
		"StrInvoiceDate": "2026-04-02",
		"PPInvoiceDate": "2026-04-02T00:00:00.000Z"
	}',
	@Status	BIT = 0, 
	@JSONOutput	NVARCHAR(MAX) = '',
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InsertUpdate_PrepayInvoice_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @JSONOutput OUTPUT, @IsDebug
	SELECT @JSONOutput AS JSONOutput, @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_PrepayInvoice_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@JSONOutput		NVARCHAR(MAX)	= '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	if(@JSONString = '')
	Begin
		set @Status = 0;
		SEt @JSONOutput = 0;
		return;
	End

	DECLARE @UserName NVARCHAR(MAX)=''
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey

	if(@JSONString <> '')
	BEGIN
		SELECT * INTO #TempHeader FROM PrepayInvoiceHeader WITH (NOLOCK)  where 1 = 0
		SELECT * INTO #TempDetail from PrepayInvoiceDetail WITH (NOLOCK)  where 1 = 0


		set identity_insert #TempHeader ON
		INSERT INTO #TempHeader (PPInvoiceKey, PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,
			OrderKey, InternalNotes, CustomerNotes, OrderNo, CustomerKey, BillToAddressKey, 
			PPInvoiceSentDate, PPInvoiceConfirmDate, StatusKey)
		SELECT PPInvoiceKey, PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,
			OrderKey, InternalNotes, CustomerNotes, OrderNo, CustomerKey, BillToAddressKey, 
			PPInvoiceSentDate, PPInvoiceConfirmDate, StatusKey FROM  OPENJSON(@JSONString)
		WITH
		(
			PPInvoiceKey			bigint			 '$.PPInvoiceKey',
			PPInvoiceNo				varchar(20)		 '$.PPInvoiceNo',
			PPInvoiceDate			DateTime		 '$.PPInvoiceDate',
			PPInvoiceAmount			decimal(18,4)	 '$.PPInvoiceAmount',
			OrderKey				int				 '$.OrderKey',
			OrderNo					varchar(50)		 '$.OrderNo',
			CustomerKey				int				 '$.CustKey',
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
		inner join OrderHeader OH WITH (NOLOCK) on H.OrderNo = OH.OrderNo and H.CustomerKey = OH.CustKey

		DECLARE @HCount	int = 0, @DCount int = 0, @PrepayInvoiceKey bigint = 0, @Total decimal(18,2)
		SELECT @HCount = COUNT(1) FROM #TempHeader
		SELECT @DCount = COUNT(1) FROM #TempDetail
		select top 1 @PrepayInvoiceKey = PPInvoiceKey from #TempHeader

-- Added by Ruthu
		IF EXISTS (
		SELECT 1
		FROM #TempHeader H
		WHERE NOT EXISTS (
			SELECT 1 
			FROM OrderHeader OH
			WHERE OH.OrderNo = H.OrderNo
			  AND OH.CustKey = H.CustomerKey
		)
	)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid OrderNo and CustomerKey combination'
		SET @JSONOutput = 0
		RETURN
	END
-- Till here

		if(isnull(@PrepayInvoiceKey,0) = 0)
		BEGIN
			INSERT INTO PrepayInvoiceHeader 
				(PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,OrderKey,OrderNo, CustomerKey, 
					InternalNotes, CustomerNotes,
					BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, CreatedDate, CreatedUserKey)
			select PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,OrderKey,OrderNo, CustomerKey, 
					InternalNotes, CustomerNotes,
					BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, GETDATE(), @UserKey
			from #TempHeader

			 SET @PrepayInvoiceKey=(SELECT SCOPE_IDENTITY());

			 update H
				SET PPInvoiceNo = 'PI-' + convert(varchar,PPInvoiceKey),
				StatusKey = 1
			 from PrepayInvoiceHeader H
			 where PPInvoiceKey = @PrepayInvoiceKey

			 insert into PrepayInvoiceDetail
			 (PPInvoiceKey,ContainerNo, ItemKey, UnitPrice,Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @PrepayInvoiceKey,ContainerNo, ItemKey,Quantity, UnitPrice, ExtCost, GETDATE(), @UserKey
			 from #TempDetail

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from PrepayInvoiceDetail  WITH (NOLOCK) 
			 where PPInvoiceKey = @PrepayInvoiceKey

			 update PrepayInvoiceHeader set PPInvoiceAmount = @Total
			 where PPInvoiceKey = @PrepayInvoiceKey

			 SET @Status  = 1
			 SET @Reason = 'Success'
			 SEt @JSONOutput = @PrepayInvoiceKey

			 INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			 SELECT GETDATE(),@UserName,'Order',IH.OrderNo,IH.OrderKey,null,'Text','PrePay Invoice ' + IH.PPInvoiceNo + ' created by ' + @UserName
			 FROM PrepayInvoiceHeader IH WHERE IH.PPInvoiceKey = @PrepayInvoiceKey
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
				UpdatedUserKey = @UserKey
			from PrepayInvoiceHeader H  WITH (NOLOCK) 
			inner join #TempHeader T  WITH (NOLOCK)  on H.PPInvoiceKey = T.PPInvoiceKey

			update D set
				ContainerNo = T.ContainerNo,
				ItemKey = T.ItemKey,
				UnitPrice = T.UnitPrice,
				Quantity = T.Quantity,
				ExtCost = T.ExtCost,
				UpdateDate = GETDATE(),
				UpdatedUserKey = @UserKey
			from PrepayInvoiceDetail D  WITH (NOLOCK) 
			inner join #TempDetail T  WITH (NOLOCK)  on D.PPInvoiceKey = T.PPInvoiceKey and D.PPInvoiceLineKey = T.PPInvoiceLineKey

			insert into PrepayInvoiceDetail
			 (PPInvoiceKey,ContainerNo, ItemKey, UnitPrice, Quantity, ExtCost,CreatedDate, CreatedUserKey)
			 select @PrepayInvoiceKey,T.ContainerNo, T.ItemKey, T.UnitPrice,T.Quantity, T.ExtCost, GETDATE(), @UserKey
			 from #TempDetail T  WITH (NOLOCK) 
			 LEft JOIN PrepayInvoiceDetail D  WITH (NOLOCK)  on T.PPInvoiceKey = D.PPInvoiceKey and T.PPInvoiceLineKey = D.PPInvoiceLineKey
			 where D.PPInvoiceKey is null

			 select @Total = convert(decimal(18,2), sum(ExtCost ))
			 from PrepayInvoiceDetail WITH (NOLOCK) 
			 where PPInvoiceKey = @PrepayInvoiceKey

			 update PrepayInvoiceHeader set PPInvoiceAmount = @Total
			 where PPInvoiceKey = @PrepayInvoiceKey

			 SET @Status  = 1
			 SET @Reason = 'Success'
			 Select @JSONOutput = PPInvoiceKey from #TempHeader

			 INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			 SELECT GETDATE(),@UserName,'Order',IH.OrderNo,IH.OrderKey,null,'Text','PrePay Invoice ' + IH.PPInvoiceNo + ' updated by ' + @UserName
			 FROM PrepayInvoiceHeader IH WHERE IH.PPInvoiceKey = @PrepayInvoiceKey
		END

		drop table #TempHeader
		drop table #TempDetail
	END
END
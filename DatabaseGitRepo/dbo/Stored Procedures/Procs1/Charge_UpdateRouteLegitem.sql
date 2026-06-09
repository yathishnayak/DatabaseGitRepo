/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"IsConfirmed":false,"RouteLegItemParams":[{"IsWaitTimeDateTmp":true,"RouteKey":918721,"ItemKey":40,"Qty":1,"Rate":25,"Action":"Add","WaitDateFrom":null,"WaitDateTo":null,"TimeDuration":null,"IsDelete":true,"InternalNotes":null,"PvsNP":"false"}]}'
exec Charge_UpdateRouteLegitem @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/


CREATE PROCEDURE [dbo].[Charge_UpdateRouteLegitem]
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

	Declare @IsDebug		bit = 0
	Declare @IsConfirmed	bit = 0

	Create Table #InData
	(
		RouteKey		INT ,
		ItemKey			INT,
		Qty				DECIMAL(18,5),
		Rate			DECIMAL(18,5),
		Action			VARCHAR(20),
		UserKey			INT,
		DateFrom		DATETIME,
		DateTo			DATETIME,
		OrderDetailKey	INT ,
		IsDelete		BIT,
		TimeDuration	VARCHAR(10),
		IsConfirmed		Bit,
		ProcStatus		bit,
		InternalNotes	nvarchar(max),
		PvsNP			varchar(5)	,
		ContainerNo		varchar(20),
	)

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	insert into #InData( Routekey, ItemKey, Qty, Rate, Action, DateFrom, dateTo, OrderDetailKey, 
		 TimeDuration, IsDelete, InternalNotes, PvsNP)
	Select Routekey, ItemKey, Qty, Rate, Action, DateFrom, dateTo, OrderDetailKey, 
		 TimeDuration, IsDelete, InternalNotes, PvsNP
	from OpenJSON(@JsonString, '$.RouteLegItemParams')
	WITH (
		RouteKey		int				'$.RouteKey'	,
		ItemKey			int				'$.ItemKey',
		Qty				DECIMAL(18,5)	'$.Qty',
		Rate			DECIMAL(18,5)	'$.Rate',
		Action			VARCHAR(20)		'$.Action',
		DateFrom		DATETIME		'$.WaitDateFrom',
		DateTo			DATETIME		'$.WaitDateTo',
		OrderDetailKey	INT				'$.OrderDetailKey',
		TimeDuration	VARCHAR(10)		'$.TimeDuration',
		IsDelete		bit				'$.IsDelete',
		InternalNotes	nvarchar(max)	'$.InternalNotes',
		PvsNP			varchar(5)		'$.PvsNP'
	)

	update A	 SET
		ContainerNo = OD.ContainerNo
	from #InData A
	inner join Orderdetail OD on A.OrderDetailKey = OD.OrderDetailKey

	if(isnull(@IsDebug,0) = 1)
	begin
		Select * from #InData
	end

	select @IsConfirmed = IsConfirmed
	from OpenJSON(@JsonString, '$')
	WITH (
		IsConfirmed		bit '$.IsConfirmed'
	)

	if(isnull(@IsDebug,0) = 1)
	begin
		Select @IsConfirmed as IsConfirmed
	end

	SET @Status=0
	SEt @Reason = ''
	Declare 
		@RouteKey			int,
		@ItemKey			int	,
		@Qty				DECIMAL(18,5),
		@Rate				DECIMAL(18,5),
		@Action				VARCHAR(20),
		@DateFrom			DATETIME,
		@DateTo				DATETIME,
		@OrderDetailKey		INT,
		@TimeDuration		VARCHAR(10),
		@IsDelete			bit,
		@InternalNotes		nvarchar(max),
		@PvsNP				varchar(5),
		@ContainerNo		varchar(20)

	BEGIN TRY
		BEGIN TRANSACTION
		Declare _Cursor CURSOR LOCAL FOR
		Select Routekey, ItemKey, Qty, Rate, Action, DateFrom, dateTo, OrderDetailKey, 
			TimeDuration, ISNULL(IsDelete, 0), InternalNotes, PvsNP, ContainerNo from #InData
		Open _cursor
		Fetch Next From _Cursor into @Routekey, @ItemKey, @Qty, @Rate, @Action, @DateFrom, @dateTo, @OrderDetailKey, 
			@TimeDuration, @IsDelete, @InternalNotes, @PvsNP, @ContainerNo

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--print '---------------------------'
			--print @Routekey
			--print @ItemKey
			--Print @OrderDetailKey

			DECLARE @UserName varchar(100),
					@CommentKey int,
					@Comment varchar(500),
					@ItemDescription varchar(500),
					@LegDescription varchar(500)

		   SELECT @UserName = ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey = @UserKey
		   SELECT @ItemDescription = ISNULL(Description,'')  FROM ITEM WHERE ItemKey = @ItemKey
		   SELECT @LegDescription = isnull(Description,'')  FROM leg WHERE LegKey =(SELECT LegKey FROM routes WHERE RouteKey  = @RouteKey)
		 --  print '---------IsDelete-'
			--print @IsDelete
		   IF(@IsDelete=1)
		   BEGIN
			DELETE FROM OrderExpense WHERE RouteKey=@RouteKey AND ItemKey = @ItemKey
		   END

			IF( SELECT COUNT(1) FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey )>0
			BEGIN
				print '*** Update 1'
				UPDATE dbo.OrderExpense
				SET Qty=@Qty,
					NewUnitCost=@Rate,
					DateFrom=@DateFrom,
					DateTo=@DateTo, 
					UnitCost = @Rate,
					TimeDuration=@TimeDuration,
					InternalNotes = @InternalNotes,
					PvsNP = @PvsNP,
					OrderDetailKey = @OrderDetailKey
				WHERE RouteKey=@RouteKey AND Itemkey=@ItemKey;

				UPDATE dbo.[Routes] 
				SET IsChargesApproved= 0, 
				ChargesApprovedDate = null,
				ChargesApprovedBy= null
				WHERE OrderDetailKey=@OrderDetailKey

				SET @Comment = 'ChargeType: ' + @ItemDescription + ' Updated to ' + @LegDescription
	    
				INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
				VALUES(GETDATE(),@USerName,'Container',@ContainerNo,
					null,'Text',@Comment,@OrderDetailKey)

				IF @@ROWCOUNT>0
				BEGIN
					update #InData set ProcStatus = 1 where RouteKey = @RouteKey and ItemKey = @ItemKey
				END

				--update OED set OrderExpenseKey = OE.OrderExpenseKey
				----Select *
				--from OrderExpense OE
				--inner join OrderExpenseDocuments OED on OE.RouteKey = OED.RouteKey and OE.Itemkey = OEd.ItemKey
				--where OED.OrderExpenseKey is null
			END
			ELSE 
			BEGIN
				print '*** Insert 1'
				IF(@IsDelete = 0)
				BEGIN
					INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],[Qty],[NewUnitCost],
						[CreateDate],[CreateUserKey],[LastUpdateDate],[UpdateUserKey],DateFrom,DateTo,
						TimeDuration, InternalNotes, PvsNP, OrderDetailKey)
					SELECT @ItemKey,@RouteKey,@Rate,@Qty,@Rate,
						GETDATE(),@UserKey,GETDATE(),@UserKey,@DateFrom,@DateTo,
						@TimeDuration, @InternalNotes, @PvsNP, @OrderDetailKey
				END

				UPDATE dbo.[Routes] 
				SET IsChargesApproved= 0, 
				ChargesApprovedDate = null,
				ChargesApprovedBy= null
				WHERE OrderDetailKey=@OrderDetailKey

				SET @Comment = 'ChargeType: ' + @ItemDescription + ' Added to ' + @LegDescription
	  
				INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
				VALUES(GETDATE(),@USerName,'Container',@ContainerNo,
					null,'Text',@Comment,@OrderDetailKey)

				IF @@ROWCOUNT>0
				BEGIN
					update #InData set ProcStatus = 1 where RouteKey = @RouteKey and ItemKey = @ItemKey
				END
				--update OED set OrderExpenseKey = OE.OrderExpenseKey
				----Select *
				--from OrderExpense OE
				--inner join OrderExpenseDocuments OED on OE.RouteKey = OED.RouteKey and OE.Itemkey = OEd.ItemKey
				--where OED.OrderExpenseKey is null
			END
			IF( SELECT COUNT(1) FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey )>0 AND @Action='DELETE'
			BEGIN
				print '*** Delete 1'
				DELETE FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey

				IF @@ROWCOUNT>0
				BEGIN
					update #InData set ProcStatus = 1 where RouteKey = @RouteKey and ItemKey = @ItemKey
				END
			END	
			Fetch Next From _Cursor into @Routekey, @ItemKey, @Qty, @Rate, @Action, @DateFrom, @dateTo, @OrderDetailKey, 
				@TimeDuration, @IsDelete, @InternalNotes, @PvsNP, @ContainerNo
		END
		close _cursor
		deallocate _cursor

		if(isnull(@IsDebug,0) = 1)
		begin
			Select * from #InData
		end

		if(isnull(@IsConfirmed,0) = 1)
		Begin
			print '###### ConfirmCharge Verified'
			Declare @RouteKey_Conf	int
			declare _RouteCursor Cursor LOCAL FOR 
			Select distinct Routekey  from #InData
			Open _RouteCursor
			Fetch next from _RouteCursor into @RouteKey_Conf
			while @@FETCH_STATUS = 0
			Begin
				print @RouteKey_Conf
				Declare @ConfirmStatus	bit  = 0
				Exec dbo.Update_ConfirmRouteRate @Routekey = @Routekey, @UserKey = @UserKey, @Output = @ConfirmStatus output
				Fetch next from _RouteCursor into @RouteKey_Conf
			End
			close _RouteCursor
			deallocate _RouteCursor
			print '###### ConfirmCharge Verified - END'
		End
		COMMIT TRANSACTION
		set @Status = 1
		set @Reason = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SEt @Status = 0
		set @Reason = 'Error in Charge_UpdateRouteLegitem'
		print Error_number()
		print Error_Message()
		ROLLBACK TRANSACTION
	END CATCH
END
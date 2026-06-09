/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '[{"OrderExpenseKey":58980,"Itemkey":151}]'
exec Charge_DeleteCSItems @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE proc [dbo].[Charge_DeleteCSItems]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Declare @OrderDetailKey		int,
			@ItemKey				int,
			@Comments           VARCHAR(500)='',
			@UserName			VARCHAR(100)='',
			@ContainerNo		VARCHAR(20)='',
			@RouteExpCount		INT,
			@NoRouteExpCount		INT 

	Create Table #Items
	(
		OrderExpenseKey		int				,
		Itemkey				int				
	)

	insert into #Items (OrderExpenseKey,Itemkey)
	Select OrderExpenseKey,Itemkey
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderExpenseKey		int				'$.OrderExpenseKey',	
		Itemkey				int				'$.ItemKey'
	)

	--Select * from #items
	print '------------------------'
	print @OrderDetailKey
	print @ItemKey
	print 'E---------------------------'

	SELECT TOP 1 @OrderDetailKey =  OrderdetailKey FROM OrderExpense WHERE OrderExpenseKey in (select OrderExpenseKey FROM #Items)
	SELECT @UserName=UserName FROM[User] WHERE UserKey=@UserKey;
	SET @Comments='by '+@UserName +' on '+ CAST(GETDATE() AS VARCHAR);
	SET @ContainerNo =(SELECT  ContainerNo FROM OrderDetail where OrderDetailKey=@OrderDetailKey)

	BEGIN TRY 
		
		if((Select count(1) from #Items) > 0)
		Begin
			SET @RouteExpCount=(select count(1) 
					from OrderExpense OE
					inner join #Items I on OE.OrderExpenseKey = I.OrderExpenseKey and OE.Itemkey = I.Itemkey)

			SET @NoRouteExpCount=(select count(1) 
					from OrderExpense_NoRoutes OE
					inner join #Items I on OE.OrderExpenseKey = I.OrderExpenseKey and OE.Itemkey = I.Itemkey)

			If (@RouteExpCount > 0 OR @NoRouteExpCount>0)
			BEGIN
				BEGIN TRANSACTION
				Delete from OrderExpense 
					where OrderExpenseKey in (
						select OE.OrderExpenseKey
						from OrderExpense OE
						inner join #Items I on OE.OrderExpenseKey = I.OrderExpenseKey and OE.Itemkey = I.Itemkey
					)

						Delete from OrderExpense_NoRoutes 
					where OrderExpenseKey in (
						select OE.OrderExpenseKey
						from OrderExpense_NoRoutes OE
						inner join #Items I on OE.OrderExpenseKey = I.OrderExpenseKey and OE.Itemkey = I.Itemkey
					)

				INSERT INTO AuditLogDetail
				(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
				SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Charges Deleted ' + @Comments

				COMMIT TRANSACTION
				SEt @Status = 1
				Set @Reason = 'SUCCESS'
				return
			END
			ELSE
			BEGIN
				SEt @Status = 0
				Set @Reason = 'No Matching Records'
			END
		End
	END TRY
	BEGIN CATCH
		print @@Error
		print Error_message()
		print Error_line()
		ROLLBACK TRANSACTION
		SEt @Status = 0
		Set @Reason = 'TECHNICAL ERROR'
		return
	END CATCH
	
End

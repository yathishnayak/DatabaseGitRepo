
CREATE proc [dbo].[Delete_OrderExpense]
(
	@RouteKey			int = 0,
	@ItemKey			int = 0,
	@OrderExpenseKey	int = 0,
	@UserKey			int = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE  @CONTAINER VARCHAR(50), @ORDERDETAILKEY	INT = 0, @USER VARCHAR(50),
		@ItemID varchar(50) , @ItemDescr varchar(100) , @qty decimal(18,5), @ExtAmt decimal(18,5)

	IF(@RouteKey = 0 OR @ItemKey = 0 OR @OrderExpenseKey = 0 OR @UserKey = 0)
	BEGIN
		SELECT 'ERROR' AS STATUS, 'REQUIRED VALUES MISSING' AS ErrorDescr
		RETURN
	END

	BEGIN TRY
		SELECT @USER = UserName FROM [User] WHERE UserKey = @UserKey
		SELECT @ORDERDETAILKEY = OD.OrderDetailKey, @CONTAINER = OD.ContainerNo
		FROM OrderDetail OD
		INNER JOIN Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
		WHERE RT.RouteKey = @RouteKey

		SELECT @ItemID =  I.ItemID, @ItemDescr = I.Description, @qty = OE.Qty, @ExtAmt = ISNULL(OE.UnitCost,0) * ISNULL(OE.qty,1)
		FROM OrderExpense OE
		INNER JOIN Item I ON OE.Itemkey = I.ItemKey
		WHERE OrderExpenseKey = @OrderExpenseKey OR (RouteKey = @RouteKey AND OE.Itemkey = @ItemKey)

		INSERT INTO AuditLogDetail  (DateCreated, CreateUser, RefType, RefId, Stage, CommentType, Comments, RefKey)
		SELECT GETDATE(), @USER, 'Container', @CONTAINER, NULL, 'Text', 
			'Item ' + @ItemID + ' ' + @ItemDescr + ' of Qty. ' + CONVERT(Varchar(50),@qty) + ' Total ' + CONVERT(varchar(50), @ExtAmt) , @ORDERDETAILKEY

		DELETE FROM OrderExpense WHERE  OrderExpenseKey = @OrderExpenseKey OR (RouteKey = @RouteKey AND Itemkey = @ItemKey)
		SELECT 'SUCCESS' AS STATUS, 'Order Expense Deleted' AS ErrorDescr
		RETURN
	END TRY
	BEGIN CATCH
		SELECT 'ERROR' AS STATUS, 'Technical Error' AS ErrorDescr
		RETURN
   END CATCH
	
END

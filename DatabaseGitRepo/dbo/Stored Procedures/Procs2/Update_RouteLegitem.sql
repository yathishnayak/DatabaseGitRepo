CREATE PROCEDURE [dbo].[Update_RouteLegitem]
@RouteKey		INT=355,
@ItemKey		INT=84,
@Qty			DECIMAL(18,5)=2,
@Rate			DECIMAL(18,5)=23,
@Action			VARCHAR(20)='ADD',
@UserKey		INT=1,
@DateFrom		DATETIME,
@DateTo			DATETIME,
@OrderDetailKey INT = 0,
@IsChargeAdded	BIT=1,
@IsDelete		BIT=0,
@TimeDuration	VARCHAR(10),
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0
	DECLARE @UserName varchar(100),
	        @CommentKey int,
			@Comment varchar(500),
			@ItemDescription varchar(500),
			@LegDescription varchar(500)

	Select @OrderDetailKey = OrderDetailKey From Routes RT WITH (NOLOCK) where RouteKey = @RouteKey
   SELECT @UserName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
   SELECT @ItemDescription = ISNULL(Description,'')  FROM ITEM WHERE ItemKey = @ItemKey
   SELECT @LegDescription = isnull(Description,'')  FROM leg WHERE LegKey =(SELECT LegKey FROM routes WHERE RouteKey  = @RouteKey)
   IF(@IsDelete=1)
   BEGIN
	DELETE FROM OrderExpense WHERE RouteKey=@RouteKey
   END

	IF( SELECT COUNT(1) FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey )>0
	BEGIN
		UPDATE dbo.OrderExpense
		SET Qty=@Qty,NewUnitCost=@Rate,DateFrom=@DateFrom,DateTo=@DateTo, UnitCost = @Rate,TimeDuration=@TimeDuration,
			OrderDetailKey = @OrderDetailKey
		WHERE RouteKey=@RouteKey AND Itemkey=@ItemKey;
		IF(@IsChargeAdded=1)
		BEGIN
		UPDATE dbo.[Routes] 
		SET IsChargesApproved= 0, 
			ChargesApprovedDate = null,
			ChargesApprovedBy= null
		WHERE OrderDetailKey=@OrderDetailKey
		END
		SET @Comment = 'ChargeType: ' + @ItemDescription + ' Updated to ' + @LegDescription
	    
		INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
		VALUES(GETDATE(),@USerName,'Container',(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

		IF @@ROWCOUNT>0
		BEGIN
				SET @OutPut=1
		END
	END
	ELSE 
	BEGIN
		INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],[Qty],[NewUnitCost],
			[CreateDate],[CreateUserKey],[LastUpdateDate],[UpdateUserKey],DateFrom,DateTo,TimeDuration, OrderDetailKey)
		SELECT @ItemKey,@RouteKey,@Rate,@Qty,@Rate,GETDATE(),@UserKey,GETDATE(),@UserKey,@DateFrom,@DateTo,@TimeDuration, @OrderDetailKey

		UPDATE dbo.[Routes] 
		SET IsChargesApproved= 0, 
			ChargesApprovedDate = null,
			ChargesApprovedBy= null
		WHERE OrderDetailKey=@OrderDetailKey

		SET @Comment = 'ChargeType: ' + @ItemDescription + ' Added to ' + @LegDescription
	  
		INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
		VALUES(GETDATE(),@USerName,'Container',(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

		IF @@ROWCOUNT>0
		BEGIN
				SET @OutPut=1
		END
	END
	IF( SELECT COUNT(1) FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey )>0 AND @Action='DELETE'
	BEGIN
		DELETE FROM dbo.OrderExpense WHERE Itemkey= @ItemKey AND RouteKey=@RouteKey

		IF @@ROWCOUNT>0
		BEGIN
				SET @OutPut=1
		END
	END		
END

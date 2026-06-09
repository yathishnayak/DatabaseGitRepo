
CREATE PROCEDURE [dbo].[Delete_ContainerLeg]
@OrderDetailKey INT,
@RouteKey		INT,
@UserKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN
		SET NOCOUNT ON;
		SET FMTONLY OFF;

		SET @OutPut=0;	

		IF ( SELECT COUNT(1) FROM dbo.[Routes] WHERE OrderDetailKey=@OrderDetailKey AND RouteKey=@RouteKey )= 0
		BEGIN
			SET @OutPut=1;
			RETURN;
		END;
		ELSE
		BEGIN
			IF ( SELECT COUNT(1) 
				 FROM dbo.[Routes] RT
					LEFT JOIN ( SELECT DISTINCT Orderdetailkey FROM Invoicedetail ) IV ON IV.OrderDetailKey=RT.OrderDetailKey
					LEFT JOIN ( SELECT DISTINCT RouteKey FROM VoucherDetail) V ON V.RouteKey=RT.RouteKey
				 WHERE RT.OrderDetailKey=@OrderDetailKey AND RT.RouteKey= @RouteKey
				    AND (IV.Orderdetailkey IS NOT NULL OR V.RouteKey IS NOT NULL ) )>0
			BEGIN
				SET @OutPut=0;
				RETURN;
			END		

			DELETE FROM dbo.OrderExpense WHERE RouteKey = @RouteKey;

			DELETE FROM dbo.[Routes] WHERE OrderDetailKey= @OrderDetailKey AND RouteKey=@RouteKey ;	
			
			IF ( SELECT COUNT(1) FROM dbo.Routes WHERE OrderDetailKey= @OrderDetailKey )= 0
			BEGIN
				UPDATE dbo.OrderDetail
				SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Open' ),LegTypeKey=NULL
				WHERE OrderDetailKey= @OrderDetailKey
				
				
			END;
			exec UpdateContainerStatus @OrderDetailKey
			SET @OutPut=1;
		END;
END

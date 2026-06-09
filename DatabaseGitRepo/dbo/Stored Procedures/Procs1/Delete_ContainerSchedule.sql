CREATE PROCEDURE [dbo].[Delete_ContainerSchedule]
@OrderDetailKey INT,
@UserKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN
		SET NOCOUNT ON;
		SET FMTONLY OFF;

		SET @OutPut=0;

		DECLARE @OrderKey INT;
	
		SET @OrderKey= (SELECT DISTINCT OrderKey FROM dbo.OrderDetail WHERE OrderDetailKey=@OrderDetailKey );

		SELECT RouteKey INTO #RouteKey
		FROM dbo.[Routes] 
		WHERE OrderDetailKey=@OrderDetailKey

		IF ( SELECT COUNT(1) FROM dbo.[Routes] WHERE OrderDetailKey=@OrderDetailKey )= 0
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
				 WHERE RT.OrderDetailKey=@OrderDetailKey 
				    AND (IV.Orderdetailkey IS NOT NULL OR V.RouteKey IS NOT NULL ) )>0
			BEGIN
				SET @OutPut=0;
				RETURN;
			END		

			DELETE FROM dbo.OrderExpense WHERE RouteKey IN ( SELECT RouteKey FROM #RouteKey )

			DELETE FROM dbo.[Routes] WHERE OrderDetailKey= @OrderDetailKey;

			UPDATE dbo.OrderDetail
			SET LegTypeKey=NULL,LastFreeDay=NULL,CutOffDate=NULL,StatusDate=GETDATE(),
				[Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Open' AND IsActive=1 )				
			WHERE OrderDetailKey=@OrderDetailKey;

			UPDATE dbo.OrderHeader
			SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WHERE [Description]='Open' AND IsActive=1 ),
				StatusDate=GETDATE()
			WHERE OrderKey= @OrderKey;

			exec UpdateContainerStatus @OrderDetailKey

			SET @OutPut=1;
		END
END

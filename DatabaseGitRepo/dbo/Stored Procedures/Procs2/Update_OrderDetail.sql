

/*
declare  @out bit 
execute [Update_OrderDetail] 234,172,'MSKU678955',2,'','78',88.00,'Over Weight,Hazard',1,@out output

select @out
*/
CREATE PROCEDURE [dbo].[Update_OrderDetail]
@OrderKey		INT,
@OrderDetailKey INT,
@ContainerNo	VARCHAR(30),
@ContainerSize	SMALLINT,
@Chassis		VARCHAR(20),
@SealNo			VARCHAR(20),
@Weight			DECIMAL(18,2),
@WeightUnit		SMALLINT,
@Comment		VARCHAR(500),
@CreateUserKey	INT,
@VesselETA		DateTime = '1/1/1900',
@OutPut			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Comment= LTRIM(RTRIM(@Comment))

	CREATE TABLE #ExpenseItem
	(
		ExpenseItem VARCHAR(50),
		OrderDetailKey INT,
		ItemID VARCHAR(50),
		ItemKey INT
	);	

	DECLARE   
		 @New_CommentKey INT,
		 @RouteKey INT;	

	UPDATE dbo.OrderDetail  
	SET 
		ContainerNo = @ContainerNo ,
		ContainerSizeKey = @ContainerSize,
		Chassis = @Chassis ,
		SealNo  = @SealNo,
		[Weight] = @Weight,
		WeightUnit = @WeightUnit,
		LastUpdateDate=GETDATE(),
		VesselETA = @VesselETA
	WHERE OrderDetailKey = @OrderDetailKey AND OrderKey = @OrderKey;
	--*******************Expense Update******************

	SELECT DISTINCT C.CommentKey INTO #Comment
	FROM OrderDetailComments A 
	INNER JOIN Comment C ON C.CommentKey=A.CommentKey
	WHERE A.OrderDetailKey=@OrderDetailKey

	SET @Comment=LTRIM(RTRIM(@Comment))
	SET @RouteKey= ( SELECT TOP 1 RouteKey FROM dbo.[Routes] WHERE OrderDetailKey=@OrderDetailKey )

	

	--***********************Update Container Type items****************
		EXECUTE Update_ContainerTypeItem @OrderDetailKey= @OrderDetailKey,@ContType=@Comment,@CreateUserKey=@CreateUserKey
	--*****************************************************************	

	
	--IF ISNULL(RTRIM(LTRIM(@Comment)),'')<>'' --AND ISNULL(@RouteKey,0)=0
	--BEGIN
	--	IF   (	SELECT COUNT(1) 
	--			FROM dbo.Comment CM
	--				INNER JOIN OrderDetailComments ODC ON ODC.CommentKey=CM.CommentKey  
	--			WHERE [Description]= @Comment AND ODC.OrderDetailKey= @OrderDetailKey
	--		 )=0
	--	BEGIN	
	--		DELETE 
	--		FROM OrderDetailComments 
	--		WHERE CommentKey IN ( SELECT CommentKey FROM #Comment )

	--		DELETE FROM dbo.Comment WHERE CommentKey IN ( SELECT CommentKey FROM #Comment )
	--		--exec [Container_TypeInsert] @OrderdetailKey, 0

	--		INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
	--		VALUES (@Comment, GETDATE(),@CreateUserKey);

	--		SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) 

	--		INSERT INTO dbo.OrderDetailComments(OrderDetailKey,CommentKey)
	--		VALUES (@OrderDetailKey, @New_CommentKey)

	--		exec [Container_TypeInsert] @OrderdetailKey, @New_CommentKey
	--	END
	--END
	SET @OutPut=1;	
END;

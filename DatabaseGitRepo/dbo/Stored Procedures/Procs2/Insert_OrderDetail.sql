

CREATE PROCEDURE [dbo].[Insert_OrderDetail]
@Orderkey		INT,
@ContainerId    VARCHAR(50),
@Containerno	VARCHAR(30),
@ContainerSize	SMALLINT,
@Chassis		VARCHAR(30)=NUll,
@Sealno			VARCHAR(30)=NULL,
@Weight			DECIMAL(18,2)=Null,
@WeightUnit		SMALLINT=0,
@Comment		VARCHAR(500)=NULL,
@CreateUserKey	INT,
@VesselETA		DateTime = null,
@IsHazardus		BIT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

    DECLARE 
		@NewOrderDetailKey	INT,
		@New_CommentKey		INT,
		@SourceAddrKey		INT,
		@DestAddrKey		INT,
		@Ouput				BIT,
		@OrderDetailStatus  SMALLINT,
		@OrderType          INT

		SET @Comment= LTRIM(RTRIM(@Comment))

		SET @Ouput=0

		SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
		SELECT @OrderType= (  SELECT OrderTypeKey  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )

		IF @OrderDetailStatus=11
		BEGIN
			UPDATE dbo.OrderDetail
			SET [Status]=11
			WHERE OrderKey=@Orderkey and [Status]<>11
		END

		SET @SourceAddrKey=( SELECT SourceAddrKey      FROM OrderHeader WHERE OrderKey= @Orderkey )
		SET @DestAddrKey=(   SELECT DestinationAddrKey FROM OrderHeader WHERE OrderKey= @Orderkey )

		INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey,
			Chassis,SealNo,[Weight],WeightUnit,[Status],StatusDate,CreateUserKey,SourceAddrKey,
			DestinationAddrKey,CreateDate,IsHazardus, VesselETA) 
		VALUES  ( @Orderkey , @ContainerId,@Containerno , @ContainerSize ,
			@Chassis,@Sealno,@Weight, @WeightUnit,@OrderDetailStatus, GETDATE(),@CreateUserKey,@SourceAddrKey,
			@DestAddrKey,GETDATE(),@IsHazardus, @VesselETA);
   
	    SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 
		IF(@OrderType=4)
		BEGIN
			UPDATE OrderDetail SET IsEmpty=1 WHERE OrderDetailKey=@NewOrderDetailKey
		END

	    IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''
		BEGIN
			--***********************Update Container Type items****************
				EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@Comment,@CreateUserKey=@CreateUserKey
			--*****************************************************************			
		END	

		-- exec CreateDefaultRoutes @Orderkey, @NewOrderDetailKey, @CreateUserKey

		SET @Ouput= 1

		SELECT @Ouput AS Result
END;

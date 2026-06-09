/*
DECLARE @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 

  SET @JSONString = '{"OrderDetailStopKey":676979,"OrderDetailKey":225065,"ShipFromKey":42398,"StopTypeCode":"SF","AddressType":"Port"}'
  EXEC Container_InsertUpdate_ShipFrom @UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
  SELECT @Reason AS Reason,@Status AS Status
  */

CREATE PROCEDURE [dbo].[Container_InsertUpdate_ShipFrom]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @ShipFromKey	INT=0,@OrderDetailStopKey INT=0, @OrderDetailKey INT=0, @USerName VARCHAR(100),@StopName NVARCHAR(100)='',
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)='', @OrderKey INT=0, @OrderStopKey INT =0,
			@AddressType NVARCHAR(100), @StopTypeCode NVARCHAR(100), @StopTypeKey INT=0

	SELECT  @ShipFromKey = ShipFromKey, @OrderDetailStopKey = OrderDetailStopKey, @OrderDetailKey = OrderDetailKey,
			@AddressType = AddressType, @StopTypeCode = StopTypeCode
	FROM OPENJSON(@JSONString,'$')
    WITH (
			ShipFromKey				INT				'$.ShipFromKey',
			OrderDetailStopKey		INT				'$.OrderDetailStopKey',
			OrderDetailKey			INT				'$.OrderDetailKey',
			AddressType				NVARCHAR(100)	'$.AddressType',
			StopTypeCode			NVARCHAR(100)	'$.StopTypeCode'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey = OrderDetailKey
	SELECT @OrderKey = ISNULL(OrderKey,0) FROM OrderDetail WHERE OrderDetailKey = OrderDetailKey
	SELECT @StopTypeKey = StopTypeKey FROM StopsMaster WHERE StopTypeShortcode = @StopTypeCode
	SELECT @OrderStopKey = ISNULL(OrderStopKey,0) FROM OrderDetailStops WHERE OrderDetailKey = @OrderDetailKey AND StopTypeKey=@StopTypeKey
	SELECT @StopName=AddrName FROM Address WHERE AddrKey=@ShipFromKey
	SET @OrderStopKey=CASE WHEN @OrderStopKey =0 THEN NULL ELSE @OrderStopKey END

	--select @OrderDetailStopKey as OrderDetailStopKey

	SET @Status=0;
	SET @Reason='Failure';
	IF(isnull(@OrderDetailStopKey,0)=0)
	BEGIN

		DECLARE @StopNumber INT=0, @StopCount INT=0, @MaxStopNumber INT=0
		IF(@StopTypeCode='SF')
		BEGIN
			SET @StopNumber=1;
		END
		IF(@StopTypeCode='ST')
		BEGIN
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=2)
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=2)
			SET @MaxStopNumber=(SELECT MAX(StopNumber) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=2)
			SET @StopNumber=CASE WHEN @StopCount>0 THEN @MaxStopNumber+1 ELSE 2 END;
		END
		IF(@StopTypeCode='RT')
		BEGIN
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=4)
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=4)
			SET @MaxStopNumber=(SELECT MAX(StopNumber) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=4)
			SET @StopNumber=CASE WHEN @StopCount>0 THEN @MaxStopNumber+1 ELSE 3 END;
		END
		IF(@StopTypeCode='AF')
		BEGIN
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=1)
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=1)
			SET @MaxStopNumber=(SELECT MAX(StopNumber) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=1)
			SET @StopNumber=CASE WHEN @StopCount>0 THEN @MaxStopNumber+1 ELSE 2 END;
		END
		IF(@StopTypeCode='RT')
		BEGIN
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=3)
			SET @StopCount=(SELECT COUNT(1) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=3)
			SET @MaxStopNumber=(SELECT MAX(StopNumber) FROM OrderDetailStops WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey AND StopTypeKey=3)
			SET @StopNumber=CASE WHEN @StopCount>0 THEN @MaxStopNumber+1 ELSE 4 END;
		END
		--INSERT INTO Order Detail STOPS FIRST
		INSERT INTO OrderDetailStops
		(OrderDetailKey,OrderStopKey,StopTypeKey,StopName,StopAddrKey,StopNumber,LocationType,StatusKey,CreateDate,CreateUserKey,IsDeleted)
		VALUES(@OrderDetailKey,@OrderStopKey,@StopTypeKey,@StopName,@ShipFromKey,@StopNumber,@AddressType,1,GETDATE(),@UserKey,0)

		SET @OrderDetailStopKey=SCOPE_IDENTITY()
		IF(@StopTypeCode='SF')
		BEGIN
		UPDATE OrderDetail 
		SET ShipFromStopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		IF(@StopTypeCode='ST')
		BEGIN
		UPDATE OrderDetail 
		SET ShipToStopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		IF(@StopTypeCode='RT')
		BEGIN
		UPDATE OrderDetail 
		SET ReturnToStopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		IF(@StopTypeCode='AF')
		BEGIN
		UPDATE OrderDetail 
		SET StopOffA_StopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		--IF(@StopTypeCode='AF')
		--BEGIN
		--UPDATE OrderDetail 
		--SET StopOffB_StopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		--WHERE OrderDetailKey= @OrderDetailKey;
		--END
		IF(@StopTypeCode='AT')
		BEGIN
		UPDATE OrderDetail 
		SET StopOffC_StopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		SELECT @OrderDetailKey AS OrderDetailKey, @OrderDetailStopKey AS OrderDetailStopKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
		SET @Status=1;
		SET @Reason='Success';
	END
	
	IF(@OrderDetailStopKey>0)
	BEGIN
	BEGIN TRY
		UPDATE OrderDetailStops 
		SET StopAddrKey= @ShipFromKey, StopName=@StopName, UpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailStopKey= @OrderDetailStopKey;

		SET @Comment=CASE WHEN @StopTypeCode='SF' THEN 'ShipFrom Location Changed'
					 WHEN @StopTypeCode='ST' THEN 'ShipTo Location Changed'
					 WHEN @StopTypeCode='RT' THEN 'ReturnTo Location Changed'
					 WHEN @StopTypeCode='AF' THEN 'AF Location Changed'
					 WHEN @StopTypeCode='AT' THEN 'AT Location Changed' END

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Location', 'Text' , @Comment

		SELECT @OrderDetailKey AS OrderDetailKey, @OrderDetailStopKey AS OrderDetailStopKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
		SET @Status=1;
		SET @Reason='Success';
	END TRY
	BEGIN CATCH;
			print error_message();
			SET @Status=0;
			SET @Reason='Failure';
	END CATCH
	END
END

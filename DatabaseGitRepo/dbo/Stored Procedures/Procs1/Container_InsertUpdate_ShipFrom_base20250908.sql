/*
declare @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 

  SET @JSONString = '{"OrderDetailStopKey":676979,"OrderDetailKey":225065,"ShipFromKey":42398,"StopTypeCode":"SF","AddressType":"Port"}'
  EXEC Container_InsertUpdate_ShipFrom @UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
  select @Reason,@Status
  */

CREATE PROCEDURE [dbo].[Container_InsertUpdate_ShipFrom_base20250908]
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
		--INSERT INTO Order Detail STOPS FIRST
		INSERT INTO OrderDetailStops
		(OrderDetailKey,OrderStopKey,StopTypeKey,StopName,StopAddrKey,StopNumber,LocationType,StatusKey,CreateDate,CreateUserKey,IsDeleted)
		VALUES(@OrderDetailKey,@OrderStopKey,@StopTypeKey,@StopName,@ShipFromKey,0,@AddressType,1,GETDATE(),@UserKey,0)

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
		IF(@StopTypeCode='AF')
		BEGIN
		UPDATE OrderDetail 
		SET StopOffB_StopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
		IF(@StopTypeCode='AT')
		BEGIN
		UPDATE OrderDetail 
		SET StopOffC_StopKey= @OrderDetailStopKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		END
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

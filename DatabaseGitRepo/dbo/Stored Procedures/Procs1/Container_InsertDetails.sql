CREATE PROCEDURE [dbo].[Container_InsertDetails]
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
	SET @Status=0;
	SET @Reason='Failure';
	DECLARE @OrderKey INT, @OrderDetailKey INT=0,@ContainerNo NVARCHAR(20),@SizeKey INT,
		    @SealNo NVARCHAR(30),@Weight DECIMAL,@WeightUnit SMALLINT,@VesselETA DATETIME,
			@OrderTypeKey INT, @ShipFromStopKey INT,@ShipToStopKey INT, @ReturnToStopKey INT,
			@StopOffA_StopKey INT,@StopOffB_StopKey INT,@StopOffC_StopKey INT,@StopOffD_StopKey INT,
			@PriorityKey INT, @USerName NVARCHAR(100)

	SELECT @OrderKey = OrderKey, @OrderDetailKey = OrderDetailKey,@ContainerNo=ContainerNo,@SizeKey=SizeKey,
		   @SealNo=SealNo,@Weight=Weight,@WeightUnit=WeightUnit,@VesselETA=VesselETA
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderKey		INT				'$.OrderKey',
			OrderDetailKey	INT				'$.OrderDetailKey',
			ContainerNo		NVARCHAR(20)	'$.ContainerNo',
			SizeKey			INT				'$.SizeKey',
			SealNo			NVARCHAR(30)	'$.SealNo',
			Weight			DECIMAL			'$.Weight',
			WeightUnit		SMALLINT		'$.WeightUnit',
			VesselETA		DATETIME		'$.VesselETA'
		)

	IF(@OrderDetailKey=0)
	BEGIN
		INSERT INTO OrderDetail
				(OrderKey,ContainerNo,ContainerSizeKey,SealNo,Weight,Status,CreateUserKey,CreateDate
				,OrderTypeKey,ShipFromStopKey,ShipToStopKey,ReturnToStopKey,StopOffA_StopKey,StopOffB_StopKey
				,StopOffC_StopKey,StopOffD_StopKey,PriorityKey)
		SELECT	@OrderKey,@ContainerNo,@SizeKey,@SealNo,@Weight,1,@UserKey,GETDATE(),
				@OrderTypeKey,@ShipFromStopKey,@ShipToStopKey,@ReturnToStopKey,@StopOffA_StopKey,@StopOffB_StopKey,
				@StopOffC_StopKey,@StopOffD_StopKey,@PriorityKey

		SET @OrderDetailKey=SCOPE_IDENTITY();
	END

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

	SET @Status=1;
	SET @Reason='Success';
	SELECT @OrderDetailKey AS OrderDetailKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END

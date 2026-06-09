/*
Declare @UserKey		INT=1144,
	@JsonString		VARCHAR(MAX)='{"LegKey":17,"OrderDetailKey":221260,"LegID":"","ContainerNo":"","PickupAddrKey":1198,"DeliveryAddrKey":1705,"ChassisType":"","VoucherKey":297729,"ActualArrival":"2025-06-20T05:24","ActualDeparture":"2025-06-20T05:24"}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	EXEC Routes_ManualRouteAddition @UserKey, @JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
	*/

	/*
Declare @UserKey		INT=1144,
	@JsonString		VARCHAR(MAX)='{"OrderDetailKey":223712,"LegKey":36,"ChassisKey":1596, "ChassisCategoryKey":2, "ChassisType":"20'' Triaxle","PickupAddrKey":18875,"DeliveryAddrKey":32,"ChassisNo":"JCTD900007","ActualArrival":"2026-04-30T12:45:00.000Z","ActualDeparture":"2026-04-17T12:45:00.000Z","CarrierKey":0,"VoucherKey":299405}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	EXEC Routes_ManualRouteAddition @UserKey, @JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
	*/
CREATE PROCEDURE [dbo].[Routes_ManualRouteAddition] 
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END

	DECLARE @OrderDetailKey INT, @LegKey  INT, @PickupAddrKey INT, @DeliveryAddrKey INT,
			@ChassisType NVARCHAR(30), @ChassisKey INT, @ChassisNo NVARCHAR(50),
			@ActualArrival	NVARCHAR(30), @ActualDeparture NVARCHAR(30), @CarrierKey INT, @OrderKey INT,
			@FromLocation NVARCHAR(200), @ToLocation  NVARCHAR(200), @VoucherKey INT,
			@LegNo SMALLINT, @LegType NVARCHAR(50), @LegId NVARCHAR(50), @RouteKey INT, @ChassisCategoryKey INT

	SELECT @OrderDetailKey = OrderDetailKey, @LegKey = LegKey, @PickupAddrKey = PickupAddrKey,
		   @DeliveryAddrKey = DeliveryAddrKey, @ChassisType = ChassisType,
		   @ChassisKey = ChassisKey, @ChassisNo = ChassisNo, @CarrierKey = CarrierKey,
		   @ActualArrival = ActualArrival, @ActualDeparture = ActualDeparture, @VoucherKey = VoucherKey, @ChassisCategoryKey = ChassisCategoryKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey		INT				'$.OrderDetailKey',
			LegKey				INT				'$.LegKey',
			PickupAddrKey		INT				'$.PickupAddrKey',
			DeliveryAddrKey		INT				'$.DeliveryAddrKey',
			ChassisType			NVARCHAR(30)	'$.ChassisType',
			ChassisKey			INT				'$.ChassisKey',
			ChassisNo			NVARCHAR(50)	'$.ChassisNo',
			CarrierKey			INT				'$.CarrierKey',
			ActualArrival		NVARCHAR(30)	'$.ActualArrival',
			ActualDeparture		NVARCHAR(30)	'$.ActualDeparture',
			VoucherKey			INT				'$.VoucherKey',
			ChassisCategoryKey	INT				'$.ChassisCategoryKey'
		)

	BEGIN TRAN
	BEGIN TRY
		SELECT TOP 1 @OrderKey = OrderKey FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey
		SELECT @FromLocation = AddrName FROM [Address] WITH(NOLOCK) WHERE AddrKey = @PickupAddrKey
		SELECT @ToLocation = AddrName FROM [Address] WITH(NOLOCK) WHERE AddrKey = @DeliveryAddrKey
		SELECT @LegNo = ISNULL(MAX(LegNo),0)+1 FROM Routes WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey
		SELECT TOP 1 @LegType = LegType FROM Leg WITH(NOLOCK) WHERE LegKey = @LegKey
		SELECT @LegId = LegId FROM Leg WITH(NOLOCK) WHERE LegKey = @LegKey

		SET @ActualArrival   = LEFT(REPLACE(ISNULL(@ActualArrival,   ''), 'Z', ''), 16) + ':00';
		SET @ActualDeparture = LEFT(REPLACE(ISNULL(@ActualDeparture, ''), 'Z', ''), 16) + ':00';

		INSERT INTO Routes
		(
			OrderDetailKey, OrderKey, ActualArrival, ActualDeparture, 
			SourceAddrKey, FromLocation, DestinationAddrKey, ToLocation,
			ChassisNo, ChassisType, ChassisKey, DriverKey, 
			LegKey, LegNo, LegType, LegId, 
			PickupDateFrom, PickupDateTo,
			DeliveryDateFrom, DeliveryDateTo, 
			ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, 
			IsManual, ManualRouteUser, ManualRouteAddedDate, 
			Status, CarrierAssignedBy, ChassisCategoryKey
		)
		VALUES
		(
			@OrderDetailKey, @OrderKey, @ActualArrival, @ActualDeparture, 
			@PickupAddrKey, @FromLocation, @DeliveryAddrKey, @ToLocation,
			@ChassisNo, @ChassisType, @ChassisKey, @CarrierKey, 
			@LegKey, @LegNo, @LegType, @LegId, 
			@ActualDeparture, @ActualDeparture,
			@ActualArrival, @ActualArrival, 
			@ActualDeparture, @ActualArrival, @ActualDeparture, 
			1, @UserKey, GETDATE(), 
			5, @UserKey, @ChassisCategoryKey
		)

		SET @RouteKey = SCOPE_IDENTITY();

		IF(@VoucherKey > 0)
		BEGIN
			INSERT INTO RouteVouchers
			(RouteKey, VoucherKey)
			SELECT @RouteKey, @VoucherKey

			INSERT INTO VoucherDetail
			(VoucherKey, ItemKey, Description, UnitCost, Qty, ExtCost, RouteKey, Remarks, CreateUserKey, CreateDate, IsDeleted)
			SELECT @VoucherKey, 32, 'DRIVER PAY', 0, 1, 0, @RouteKey, '', @UserKey, GETDATE(), 0 -- ItemKey 32 = Driver Pay
		END

		SET @Reason = 'Success'
		SET @Status = 1

		DECLARE @UserName NVARCHAR(200), @ContainerNo NVARCHAR(100);

		SELECT @ContainerNo = ContainerNo 
		FROM OrderDetail OD WITH(NOLOCK) 
		WHERE OrderDetailKey = @OrderDetailKey;

		SELECT @UserName = ISNULL(UserName, '') 
		FROM [User] WITH(NOLOCK) 
		WHERE UserKey = @UserKey;

		INSERT INTO dbo.AuditLogDetail
		(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		VALUES
		(
			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text',
			' Manual Route added ( ' + @LegId + ' ) ' + @FromLocation + ' to ' + @ToLocation + '  by ' + @UserName
		);

		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
		SET @Status = 0;
		SET @Reason = 'Failed to save data';
		ROLLBACK TRAN;
	END CATCH
END
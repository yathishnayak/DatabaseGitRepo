/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey": 1290}'
	EXEC [Validate_DriverStatusChange_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Validate_DriverStatusChange_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@DriverKey		INT,
		@Key			SMALLINT,
		@Value			VARCHAR(100)

	SELECT 
		@DriverKey			=		DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		DriverKey				INT					'$.DriverKey'
	)

	DECLARE @CNT INT = 0

	--// Check Driver exists
	SELECT @CNT = COUNT(1) FROM Driver WITH (NOLOCK) WHERE DriverKey = @DriverKey
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Key = 9 
		SET @Value = 'Driver Not Found'
	END
	ELSE
	BEGIN
		--// check pending deliveries
		SET @CNT = 0
		SELECT @CNT = COUNT(1) 
		FROM Routes RT WITH (NOLOCK)
		WHERE RT.DriverKey = @DriverKey AND RT.Status <> 5 -- LEG COMPLETED STATUS
			AND (RT.ActualArrival IS NULL OR RT.ActualDeparture IS NULL)

		IF(@CNT > 0)
		BEGIN
			SET @Key = 8
			SET @Value = 'Can''t make Inactive as some Assigned Legs are still pending to delivery'
			-- return
		END
		ELSE
		BEGIN
			--// Check Voucher pending for the Driver
			SET @CNT = 0
			SELECT @cnt =  Count(1)
			FROM VoucherHeader VH WITH (NOLOCK)
			INNER JOIN VoucherDetail VD WITH (NOLOCK) on VH.VoucherKey = VD.Voucherkey
			INNER JOIN Routes RT WITH (NOLOCK) on VD.RouteKey = RT.RouteKey
			WHERE RT.DriverKey = @DriverKey AND VH.StatusKey IN (1,2)

			IF(@CNT > 0)
			BEGIN
				SET @Key = 7
				SET @Value = 'Can''t make Inactive as some Vouchers pending against this Carrier'
				-- return
			END
			ELSE
			BEGIN
				--//Check Route Complete, but Voucher not Created for the Driver
				SET @CNT = 0
				SELECT @CNT = count(1)
				FROM Routes RT WITH (NOLOCK)
				LEFT JOIN VoucherDetail VD WITH (NOLOCK) on RT.RouteKey = VD.RouteKey
				WHERE RT.Status = 5 AND RT.DriverKey = @DriverKey
						AND VD.RouteKey IS NULL

				IF(@CNT > 0)
				BEGIN
					SET @Key = 6
					SET @Value = 'Can''t make Inactive as some Voucher Creation pending against this Carrier'
					-- return
				END
				ELSE
				BEGIN
					SET @Key = 1
					SET @Value = 'Carrier Status can be changed'
				END
			END
		END
	END

	SELECT @Key AS [Key], @Value AS [Value]
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER


	SET @Status = 1
	SET @Reason = 'Success'
END

CREATE PROCEDURE [dbo].[Chassis_InsertUpdate_V2] 
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @ChassisKey INT,
			@ChassisNo			VARCHAR(50),
			@ChassisType		VARCHAR(50),
			@StatusKey			SMALLINT = 1,
			@CompanyKey			SMALLINT = 1,
			@MarketLocationKey	INT;

	SELECT @ChassisKey = ChassisKey, @ChassisNo = ChassisNo, @ChassisType = ChassisType, @StatusKey = StatusKey, @CompanyKey = CompanyKey, @MarketLocationKey=MarketLocationKey
	from OPENJSON(@JSONString, '$')
	with (
			ChassisKey int '$.ChassisKey',
			ChassisNo  varchar(50)  '$.ChassisNo',
			ChassisType  varchar(50)  '$.ChassisType',
			StatusKey SMALLINT '$.StatusKey',
			CompanyKey SMALLINT '$.CompanyKey',
			MarketLocationKey int '$.MarketLocationKey'
		 )

		DECLARE		@CNT INT = 0
	SELECT		@CNT = COUNT(1) FROM Chassis WITH (NOLOCK) WHERE chassisNo = @ChassisNo
	IF(ISNULL(@ChassisKey, 0)=0 AND @CNT > 0)
		BEGIN
			SET @Status = 0
			SET @Reason = 'Chassis No Already Exists'
			return
		END

		if(isnull(@ChassisNo,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = 'Chassis No Can''t be Empty'
			return
		END

		if(isnull(@ChassisType,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = 'Chassis Type Can''t be Empty'
			return
		END


	BEGIN TRANSACTION
	BEGIN TRY

		IF(ISNULL(@ChassisKey,0) = 0)
		BEGIN
			INSERT INTO		Chassis 
							(chassisNo, CreateDate, ChassisType, StatusKey, CompanyKey, MarketLocationKey, IsEditable, CreateUser,IsActive,IsDelete, UpdateDate, UpdateUser)
			SELECT			@ChassisNo, GETDATE(), @ChassisType, @StatusKey, @CompanyKey, @MarketLocationKey, 1, @UserKey,1,0, GETDATE(), @UserKey
			SET				@ChassisKey = SCOPE_IDENTITY()

			SET				@Status = 1
			SET				@Reason = 'Chassis Added'

		END
		ELSE
		BEGIN
			UPDATE			Chassis 
			SET				chassisNo = @ChassisNo,
							ChassisType = @ChassisType,
							StatusKey = @StatusKey,
							CompanyKey = @CompanyKey,
							MarketLocationKey = @MarketLocationKey,
							UpdateDate = GETDATE(),
							UpdateUser = @UserKey
			WHERE			chassisKey = @ChassisKey

			SET @Status = 1
			SET @Reason = 'Chassis Info Updated'
		END
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		SET			@Status = 0
		SET			@Reason = 'Record Failed to Update'

		PRINT		@@error
		PRINT		Error_Message()
		PRINT		'Rollback'

		ROLLBACK TRANSACTION
	END CATCH
END
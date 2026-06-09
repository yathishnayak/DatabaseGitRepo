
CREATE Procedure [dbo].[Chassis_InsertUpdate]
/*

DECLARE @Status BIT = 0, @Reason VARCHAR(100) = ''

EXEC Chassis_InsertUpdate 0,'Chassis No','Type',1,1,1,1, @Status OUTPUT, @Reason OUTPUT

SELECT @Status, @Reason
*/
(
	@ChassisKey			INT OUTPUT,
	@ChassisNo			VARCHAR(50),
	@ChassisType		VARCHAR(50),
	@StatusKey			SMALLINT = 1,
	@CompanyKey			SMALLINT = 1,
	@MarKetLocationKey	INT,
	@UserKey			INT,
	@Status				BIT = 0 OUTPUT,
	@Reason				VARCHAR(100) OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE		@CNT INT = 0
	SELECT		@CNT = COUNT(1) FROM Chassis WHERE chassisNo = @ChassisNo
	IF(ISNULL(@ChassisKey, 0)=0 AND @CNT > 0)
		BEGIN
			SET @Status = 0
			SET @Reason = 'Duplicate Chassis No already Exists'
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
							(chassisNo, CreateDate, ChassisType, StatusKey, CompanyKey, MarKetLocationKey, IsEditable, CreateUser,IsActive,IsDelete, UpdateDate, UpdateUser)
			SELECT			@ChassisNo, GETDATE(), @ChassisType, @StatusKey, @CompanyKey, @MarKetLocationKey, 1, @UserKey,1,0, GETDATE(), @UserKey
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
							MarketLocationKey = @MarKetLocationKey,
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

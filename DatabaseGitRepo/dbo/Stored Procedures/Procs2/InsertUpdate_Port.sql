CREATE Procedure [dbo].[InsertUpdate_Port]
/*

DECLARE @Status BIT = 0, @Reason VARCHAR(100) = ''

EXEC InsertUpdate_Port 0,'Port ID New ggg 1',1705,1,1,1,10,30, @Status OUTPUT, @Reason OUTPUT

SELECT @Status, @Reason
*/
(
	@ShippingPortKey		INT OUTPUT,
	@ShippingPortID			VARCHAR(50),
	@AddrKey				INT,
	@StatusKey				SMALLINT,
	@CompanyKey				SMALLINT,
	@IsActive				BIT,
	@MarketLocationKey		INT,
	@UserKey				INT,
	@PriceGroupingKey		INT=0,
	@Status					BIT=1 OUTPUT,
	@Reason					VARCHAR(100) OUTPUT
)
AS

BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@ShippingPortKey=0)
			BEGIN
				INSERT INTO			ShippingPort
									(ShippingPortID,AddrKey,StatusKey,CompanyKey,MarketLocationKey,
									IsActive,IsDeleted,CreateDate,CreateUserKey,Updatedate,UpdateUserKey,PriceGroupingKey)
				SELECT				@ShippingPortID,@AddrKey,@StatusKey,@CompanyKey, @MarketLocationKey,
									@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey, @PriceGroupingKey

				SET					@ShippingPortKey = SCOPE_IDENTITY()
				SET					@Status = 1
				SET					@Reason = 'Record Created Successfully'

			END
		ELSE
			BEGIN
				UPDATE				ShippingPort
				SET					ShippingPortID=@ShippingPortID,
									AddrKey=@AddrKey,
									StatusKey=@StatusKey,
									CompanyKey=@CompanyKey,
									MarketLocationKey = @MarketLocationKey,
									IsActive = @IsActive ,
									Updatedate = GETDATE(),
									UpdateUserKey = @UserKey,
									PriceGroupingKey=@PriceGroupingKey
				WHERE				ShippingPortKey=@ShippingPortKey

				SET					@Status = 1
				SET					@Reason = 'Record Updated Successfully'

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

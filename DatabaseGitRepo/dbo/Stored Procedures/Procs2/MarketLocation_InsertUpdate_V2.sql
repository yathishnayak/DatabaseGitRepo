/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{
									"MarketLocationKey": 55,
									"MarketLocation": "Test location abc",
									"AddrKey": 22255,
									"IsActive": true,
									"IsDeleted": false,
									"AddressData": {
										"AddrKey": 22255,
										"AddrName": "JCT-Fontana",
										"Address1": "10691 Poplar Ave",
										"Address2": "",
										"City": "Fontana",
										"Zip": "",
										"State": "CA",
										"Country": "USA",
										"Email": "testmarket@market.com11",
										"Email2": " ",
										"Phone": "1077720959",
										"Phone2": "",
										"Fax": " "
									}
								}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [MarketLocation_InsertUpdate_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[MarketLocation_InsertUpdate_V2] 
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
		SET @Reason='Parameter not Present';
		SET @Status=0
		RETURN;
	END

	SET @Status=0;
	SET @Reason='Failure';

	DECLARE
		@ReturnAddrKey NVARCHAR(100) = '',
		@AddressKey INT=0;

	DECLARE
		@MarketLocationKey		INT				= 0,
		@MarketLocation			NVARCHAR(100)	= '',
		@AddrKey				INT				= 0,
		@AddressData			NVARCHAR(MAX)	= '',
		@IsActive				BIT				= 0;

	SELECT
			@MarketLocationKey = MarketLocationKey,
			@MarketLocation = MarketLocation,
			@AddrKey = AddrKey,
			@AddressData = AddressData,
			@IsActive = IsActive
	FROM OPENJSON(@JsonString, '$')
	WITH(
			MarketLocationKey	INT				'$.MarketLocationKey',
			MarketLocation		NVARCHAR(100)	'$.MarketLocation',
			AddrKey				INT				'$.AddrKey',
			AddressData			NVARCHAR(MAX)	'$.Address' AS JSON,
			IsActive			BIT				'$.IsActive'
		)
	
	-- Validation: MarketLocation is required
	IF(ISNULL(@MarketLocation,'') = '')
	BEGIN
		SET @Reason='MarketLocation is required';
		SET @Status=0;
		RETURN;
	END

	-- Validation: AddressData is required
	IF(ISNULL(@AddressData,'') = '')
	BEGIN
		SET @Reason='AddressData is required';
		SET @Status=0;
		RETURN;
	END

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
		BEGIN
			SET @Reason='Invalid UserKey - User does not exist';
			SET @Status=0;
			RETURN;
		END

		-- Call Address_InsertUpdate
		EXEC dbo.Address_InsertUpdate @UserKey, @AddressData, @ReturnAddrKey OUTPUT, 0, ''
		PRINT '@ReturnAddrKey'
		PRINT @ReturnAddrKey
		SELECT @AddressKey = AddressKey
		FROM OpenJson(@ReturnAddrKey,'$')
		WITH(
			AddressKey INT '$.AddrKey' 
		)

		PRINT 'addrkey'
		PRINT @AddressKey

		-- FIX: Validate AddressKey was returned
		IF(ISNULL(@AddressKey, 0) = 0)
		BEGIN
			SET @Reason='Failed to create or retrieve Address';
			SET @Status=0;
			RETURN;
		END

		BEGIN TRAN;

		IF(EXISTS (SELECT 1 FROM dbo.MarketLocation WHERE MarketLocation = @MarketLocation AND MarketLocationKey <> ISNULL(@MarketLocationKey,0)))
		BEGIN
			SET @Status = 0;
			SET @Reason = 'MarketLocation Name Already Exist';
			ROLLBACK;
			RETURN;
		END

		IF(ISNULL(@MarketLocationKey,0) = 0)
		BEGIN
			-- INSERT mode
			--IF(EXISTS (SELECT 1 FROM dbo.MarketLocation WHERE MarketLocation = @MarketLocation))
			--BEGIN
			--	SET @Status = 0;
			--	SET @Reason = 'MarketLocation Name Already Exist';
			--	ROLLBACK;
			--	RETURN;
			--END

			PRINT 'insert'
			INSERT INTO dbo.MarketLocation
						(MarketLocation,AddrKey,IsActive,IsDeleted,CreateDate,CreateUserKey)
			VALUES		(@MarketLocation,@AddressKey,@IsActive,0,GETDATE(),@UserKey)

			SET @MarketLocationKey = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			
			PRINT 'update'
			UPDATE	dbo.MarketLocation
			SET		MarketLocation = @MarketLocation, 
					AddrKey = @AddressKey, 
					UpdateDate = GETDATE(),
					UpdateUserKey = @UserKey, 
					IsActive = @IsActive
			WHERE	MarketLocationKey = @MarketLocationKey 

			-- FIX: Verify update affected rows
			IF @@ROWCOUNT = 0
			BEGIN
				SET @Status = 0;
				SET @Reason = 'No records were updated';
				ROLLBACK;
				RETURN;
			END
		END

		COMMIT;
		SET @Status=1;
		SET @Reason='Success';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status=0;
		SET @Reason=ERROR_MESSAGE();
	END CATCH	
END
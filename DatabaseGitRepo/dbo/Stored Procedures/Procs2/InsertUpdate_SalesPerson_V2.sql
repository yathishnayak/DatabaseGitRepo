/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"SalesPersonKey":29,"SalesPersonID":"fdfd","SalesPersonName":"Test fdf","AddrKey":46287,"FirstName":"fdsf","IsActive":false,"Address":{"AddrKey":46287,"AddrName":"fsdf","Address1":"gfdg","Address2":" ","City":"Bird City","Zip":"67731","State":"KS","Country":"USA","Email":" ","Email2":" ","Phone":"1","Phone2":" ","Fax":" ","Website":" "},"LinkedUserKey":243,"LinkedUserName":"AAA -"}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [InsertUpdate_SalesPerson_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"Address":{"AddrName":"test","Address1":"test","Zip":"576102","City":"Udupi","CityKey":43194,"State":"Karnataka","Country":"India","Phone":"6985677"},"SalesPersonID":"amrutha","SalesPersonName":"amrutha","IsActive":true,"LinkedUserKey":1037}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [InsertUpdate_SalesPerson_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_SalesPerson_V2]
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX),
	@JSONOutput		NVARCHAR(MAX) = '' OUTPUT,
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

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

	DECLARE @SalesPersonKey			INT,
			@SalesPersonID			VARCHAR(10),
			@SalesPersonName		VARCHAR(100),
			@AddrKey				INT,
			@AddressData			NVARCHAR(MAX),
			@LinkedUserKey		    INT,
			@IsActive	            BIT
							
	SELECT
		@SalesPersonKey		= SalesPersonKey, 
		@SalesPersonID		= SalesPersonID, 
		@SalesPersonName	= SalesPersonName,
		@AddrKey			= AddrKey,
		@AddressData		= AddressData,
	    @LinkedUserKey		= LinkedUserKey, 
		@IsActive			= IsActive
	FROM OPENJSON (@JSONString, '$')
	WITH ( 
			SalesPersonKey		INT		        '$.SalesPersonKey',
			SalesPersonID		VARCHAR(10)	    '$.SalesPersonID',
			SalesPersonName		VARCHAR(100)	'$.SalesPersonName',
			AddrKey			    INT	            '$.AddrKey',
			AddressData			NVARCHAR(MAX)	'$.Address' AS JSON,
			LinkedUserKey		INT		        '$.LinkedUserKey',
			IsActive		    BIT	            '$.IsActive'	
		)

	-- Validation: AddressData is required
	IF(ISNULL(@AddressData,'') = '')
	BEGIN
		SET @Reason='AddressData is required';
		SET @Status=0;
		RETURN;
	END
	
		-- Validate UserKey exists
		IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
		BEGIN
			SET @Reason='Invalid UserKey - User does not exist';
			SET @Status=0;
			RETURN;
		END

	BEGIN TRY


		-- Call Address_InsertUpdate
		EXEC dbo.Address_InsertUpdate @UserKey, @AddressData, @ReturnAddrKey OUTPUT, 0, ''
		--DECLARE @AddrStatus BIT, 
		--@AddrReason VARCHAR(1000);

		--EXEC dbo.Address_InsertUpdate 
		--@UserKey, 
		--@AddressData, 
		--@ReturnAddrKey OUTPUT, 
		--@AddrStatus OUTPUT,     
		--@AddrReason OUTPUT;    
		
		--	IF (@AddrStatus = 0)
		--BEGIN
		--	SET @Status = 0;
		--	SET @Reason = @AddrReason;
		--	RETURN;
		--END

		SELECT @AddressKey = AddressKey
		FROM OPENJSON(@ReturnAddrKey,'$')
		WITH(
			AddressKey INT '$.AddrKey' 
		)

		-- Validate AddressKey was returned
		IF(ISNULL(@AddressKey, 0) = 0)
		BEGIN
			SET @Reason='Failed to create or retrieve Address';
			SET @Status=0;
			RETURN;
		END

		BEGIN TRAN;

		IF(ISNULL(@SalesPersonKey,0) = 0)
		BEGIN
			-- INSERT mode
			IF(EXISTS (SELECT 1 FROM dbo.SalesPerson WHERE SalesPersonID = @SalesPersonID))
			BEGIN
				SET @Status = 0;
				SET @Reason = 'SalesPersonID Already Exists';
				ROLLBACK;
				RETURN;
			END

			INSERT INTO dbo.SalesPerson( SalesPersonID, SalesPersonName, FirstName, AddrKey, IsActive, CreateUser, CreateDate, LinkedUserKey )
								SELECT @SalesPersonID, @SalesPersonName, @SalesPersonName, @AddressKey, @IsActive, @UserKey, GETDATE(), @LinkedUserKey

			SET @SalesPersonKey = SCOPE_IDENTITY()

			SET @Reason = 'Inserted Successfully'
		END
		ELSE
		BEGIN
			-- UPDATE mode
			UPDATE dbo.SalesPerson
			SET
				SalesPersonID = @SalesPersonID,
				SalesPersonName = @SalesPersonName,
				FirstName = @SalesPersonName,
				AddrKey = @AddressKey,
				IsActive = @IsActive,
				UpdateUser = @UserKey,
				UpdateDate = GETDATE(),
				LinkedUserKey = @LinkedUserKey
			WHERE SalesPersonKey = @SalesPersonKey

			SET @Reason = 'Updated Successfully'

			IF @@ROWCOUNT = 0
			BEGIN
				SET @Status = 0;
				SET @Reason = 'No records were updated';
				ROLLBACK;
				RETURN;
			END
		END

		COMMIT;
		SET @Status = 1;
		-- SET @Reason = 'Success';

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END CATCH
END
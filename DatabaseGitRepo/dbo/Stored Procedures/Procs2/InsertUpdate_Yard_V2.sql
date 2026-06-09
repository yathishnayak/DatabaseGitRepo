/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{
									"YardId": 10,
									"ShortName": "JCT-Fontana",
									"Name": "10691 Poplar Ave",
									"MarketLocationKey": 0,
									"IsActive": true,
									"AddrKey": 22255,
									"Address": {
										"AddrName": "JCT-Fontana",
										"Address1": "10691 Poplar Ave",
										"Address2": "",
										"City": "Fontana",
										"State": "CA",
										"Country": "USA",
										"AddrKey": 22255,
										"Phone": "1077720959",
										"Phone2": "",
										"Email": "test@123",
										"Email2": " ",
										"Fax": " ",
										"Website": " "
									}
								}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [InsertUpdate_Yard_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[InsertUpdate_Yard_V2]
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
		@YardId				SMALLINT		= 0,
		@ShortName			VARCHAR(20)		= '',
		@Name				VARCHAR(100)	= '',
		@AddrKey			INT				= 0,
		@Address			NVARCHAR(MAX)	= '',
		@MarketLocationKey	INT				= 0,
		@IsActive			BIT				= 0;

	SELECT
			@YardId = YardId,
			@ShortName = ShortName,
			@Name = [Name],
			@AddrKey = AddrKey,
			@Address = [Address],
			@MarketLocationKey = MarketLocationKey,
			@IsActive = IsActive
		FROM OPENJSON(@JsonString, '$')
		WITH(
				YardId				SMALLINT		'$.YardId',
				ShortName			VARCHAR(20)		'$.ShortName',
				[Name]				VARCHAR(100)	'$.Name',
				AddrKey				INT				'$.AddrKey',
				[Address]			NVARCHAR(MAX)	'$.Address' AS JSON,
				MarketLocationKey	INT				'$.MarketLocationKey',
				IsActive			BIT				'$.IsActive'
			)

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM [User] WHERE UserKey = @UserKey)
		BEGIN
			SET @Reason='Invalid UserKey - User does not exist';
			SET @Status=0;
			RETURN;
		END

		DECLARE @CNTId INT = 0,
				@CNTName INT = 0;

		 SELECT  @CNTId = COUNT(1) FROM Yard Y WHERE Y.YardId <> @YardId AND Y.ShortName = @ShortName
		 SELECT  @CNTName = COUNT(1) FROM Yard Y WHERE Y.YardId <> @YardId AND Y.Name = @Name

		 IF ISNULL(@CNTId,0) > 0
			BEGIN
				SET @Status = 0;
				SET @Reason = 'Yard Name Already Exist';
				RETURN;
			END
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @Status=0;
				SET @Reason = 'Yard Description Already Exist';
				RETURN;
			END

		IF(ISNULL(@Address,'')<>'')    
		BEGIN    		
			EXEC Address_InsertUpdate @UserKey, @Address, @ReturnAddrKey OUTPUT, 0, ''
			PRINT '@ReturnAddrKey'
			PRINT @ReturnAddrKey
			SELECT @AddressKey = AddressKey
			FROM OpenJson(@ReturnAddrKey,'$')
			WITH(
				AddressKey INT '$.AddrKey' 
			)
		END

			BEGIN TRAN;
			IF(@AddressKey>0)
			BEGIN
				IF(SELECT COUNT(1) FROM dbo.Yard WHERE AddrKey = @AddressKey AND YardId = @YardId)>0
				BEGIN
					UPDATE	dbo.Yard
						SET	
							ShortName=@ShortName,
							Name=@Name,
							MarketLocationKey = @MarketLocationKey,
							IsActive=@IsActive,
							UpdateDate = GETDATE(),
							UpdateUserKey = @UserKey
						WHERE	
							YardId=@YardId


							SET @Status=1;
							SET	@Reason='Yard Updated SuccessFully';
				END
				ELSE
				BEGIN
					INSERT INTO	dbo.Yard
						(ShortName,[Name],AddrKey,MarketLocationKey,IsActive,IsDeleted,CreateDate,CreateUserKey,UpdateDate,UpdateUserKey)
					VALUES	(@ShortName,@Name,@AddressKey,@MarketLocationKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey)
					SET	@YardId = SCOPE_IDENTITY()

						SET @Status=1;
						SET	@Reason='Yard Added SuccessFully';
				END
			END	

		COMMIT;
		--SET @Status=1;
		--SET @Reason='Success';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status=0;
		SET @Reason=ERROR_MESSAGE();
	END CATCH
END
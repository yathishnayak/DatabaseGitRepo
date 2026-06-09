/*

DECLARE 
	@UserKey INT = 714,
	@JSONString NVARCHAR(MAX) = '{
								"YardId": 23,
								"ShortName": "Test1",
								"Name": "Test-Trikaiser1",
								"MarketLocationKey": 3,
								"IsActive": true,
								"AddrKey": 44137,
								"YardType": "Local",
								"Address": {
									"AddrKey": 44137,
									"AddrName": "Breakthru Beverage",
									"Address1": "1849 West Cheyenne Avenue North Las Vegas",
									"Address2": "",
									"City": "North Las Vegas",
									"State": "NV",
									"ZipCode": "89032",
									"Country": "US",
									"Phone": "1",
									"CityKey": 44450,
									"ValidAddressKey": 258,
									"IsValid": 1
								}
							}',
	@Status BIT = 0,
	@Reason VARCHAR(100) = ''
    EXEC [Yard_InsertUpdate] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
    SELECT @Status AS Status, @Reason AS Reason

*/
CREATE PROC [dbo].[Yard_InsertUpdate]
(
    @UserKey		    INT,
    @JSONString			NVARCHAR(MAX),
    @Status				BIT = 0 OUTPUT,
    @Reason				VARCHAR(100) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    -- SET FMTONLY OFF  -- (not needed, can be removed safely)

    IF(ISNULL(@JSONString,'') = '')
	BEGIN
        SET @Status = 0
        SET @Reason = 'Data not received'
        RETURN;
    END

	DECLARE 
	@YardId				SMALLINT  = 0,
	@ShortName			VARCHAR(20) = '',
	@Name				VARCHAR(100) = '',
	@AddrKey			INT = 0,
	@MarketLocationKey	INT = 0,
	@IsActive			BIT = 0,
	@YardType			VARCHAR(50) = '',
	@AddressData		NVARCHAR(MAX)

	SELECT
	@YardId					=		YardId,
	@ShortName				=		ShortName,
	@Name					=		[Name],
	@AddrKey				=		AddrKey,
	@MarketLocationKey		=		MarketLocationKey,
	@IsActive				=		IsActive,
	@YardType				=		YardType,
	@AddressData			=		AddressData
	FROM OPENJSON(@JSONString,'$')
	WITH(
		YardId				SMALLINT			'$.YardId',
		ShortName			VARCHAR(20)			'$.ShortName',
		[Name]				VARCHAR(100)		'$.Name',
		AddrKey				INT					'$.AddrKey',
		MarketLocationKey	INT					'$.MarketLocationKey',
		IsActive			BIT					'$.IsActive',
		YardType			VARCHAR(50)			'$.YardType',
		AddressData			NVARCHAR(MAX)		'$.Address' AS JSON
	)
		
	DECLARE
        @ReturnAddrKey NVARCHAR(100) = '',
		@tempYardAddrKey INT = ISNULL(@AddrKey,0)

	BEGIN TRANSACTION
	BEGIN TRY
		if(ISNULL(@AddressData, '') <> '')
        BEGIN
            print 'Address'
            EXEC Address_InsertUpdate @UserKey, @AddressData, @ReturnAddrKey OUTPUT, 0, ''
            print '@ReturnAddrKey' print @ReturnAddrKey
            SELECT @tempYardAddrKey = AddressKey
            FROM OPENJSON(@ReturnAddrKey,'$')
            WITH(
                AddressKey INT '$.AddressKey' 
            )


            print '@tempYardAddrKey'
            print @tempYardAddrKey            
			SET @AddrKey = @tempYardAddrKey
		END

        -- New duplicate ShortName check
        IF EXISTS(SELECT 1 FROM Yard WITH(NOLOCK) WHERE [Name] = @Name AND ShortName = @ShortName AND YardId <> @YardId)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Duplicate ShortName';
            ROLLBACK TRANSACTION;
            RETURN;
        END

		IF (ISNULL(@YardId,0) = 0)
		BEGIN
			INSERT INTO		Yard
							(ShortName,[Name],AddrKey,MarketLocationKey,IsActive,IsDeleted,CreateDate,CreateUserKey,UpdateDate,UpdateUserKey, YardType)
			SELECT			@ShortName,@Name,@AddrKey,@MarketLocationKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey, @YardType
			SET				@YardId = SCOPE_IDENTITY()

			SET				@Status = 1
			SET				@Reason = 'Record Created Successfully'
		END
		ELSE
		BEGIN
			UPDATE			Yard
			SET				ShortName			=		@ShortName,
							[Name]				=		@Name,
							--AddrKey=@AddrKey,
							MarketLocationKey	=		@MarketLocationKey,
							IsActive			=		@IsActive,
							UpdateDate			=		GETDATE(),
							UpdateUserKey		=		@UserKey,
							YardType			=		@YardType
			WHERE			YardId				=		@YardId

			SET				@Status = 1
			SET				@Reason = 'Record Updated Successfully'
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

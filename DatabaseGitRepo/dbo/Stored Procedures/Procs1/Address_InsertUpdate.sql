/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{
									"CustKey": 0,
									"AddressType": "Pickup",
									"AddrName": "Test",
									"Address1": "angd",
									"Zip": "12234",
									"City": "Albany",
									"State": "NY",
									"Country": "USA",
									"CityKey": 36333,
									"Phone": 1,
									"Address2": "-"
								}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [Address_InsertUpdate] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason, @JSONOutput  AS JSONOutput

*/

CREATE PROCEDURE [dbo].[Address_InsertUpdate]
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
	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
		SET @Reason='Parameter not Present';
		SET @Status=0
		RETURN;
	END
	SET @Status=0;
	SET @Reason='Failure';

    --print @JSONString

	DECLARE @AddressKey	INT=0,@AddressName NVARCHAR(200),@AddressLine1 NVARCHAR(1000),@AddressLine2 NVARCHAR(1000), @State NVARCHAR(100), 
			@City NVARCHAR(100), @Country NVARCHAR(10)='', @Zip NVARCHAR(100), @ValidAddressKey INT, @UserName VARCHAR(100)='',
			@WebSite NVARCHAR(200),@Phone NVARCHAR(20),@Email NVARCHAR(100),@Fax NVARCHAR(20),@Phone2 NVARCHAR(20),@Email2 NVARCHAR(100),
			@CityKey INT,@IsValid SMALLINT=0

	SELECT  @AddressKey = ISNULL(AddrKey,0), @AddressName=AddrName, @AddressLine1 = AddressLine1, @AddressLine2 = AddressLine2, 
			@State = State, @City=City,	@Country=Country,	@Zip = Zip, @ValidAddressKey = ValidAddressKey,
			@WebSite = WebSite, @Phone=Phone,	@Email=Email,	@Fax = Fax, @Phone2 = Phone2,
			@Email2 = Email2, @CityKey=CityKey,	@IsValid=IsValid

	FROM OPENJSON(@JSONString,'$')
    WITH (
			AddrKey			INT				'$.AddrKey',			
			AddrName		NVARCHAR(200)	'$.AddrName',
			AddressLine1	NVARCHAR(1000)	'$.Address1',
			AddressLine2	NVARCHAR(1000)	'$.Address2',
			State			NVARCHAR(100)	'$.State',
			City			NVARCHAR(100)	'$.City',
			Country			NVARCHAR(10)	'$.Country',
			Zip				NVARCHAR(100)	'$.Zip',
			ValidAddressKey	INT				'$.ValidAddressKey',
			WebSite			NVARCHAR(200)	'$.Website',
			Phone			NVARCHAR(20)	'$.Phone',
			Email			NVARCHAR(100)	'$.Email',
			Fax				NVARCHAR(20)	'$.Fax',
			Phone2			NVARCHAR(20)	'$.Phone2',
			Email2			NVARCHAR(100)	'$.Email2',
			CityKey			INT				'$.CityKey',
			IsValid			SMALLINT    	'$.IsValid'
		)
    -- print '@AddressKey' print @AddressKey

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

	-- IF(@AddressKey=0)
	-- BEGIN
    --     print 'Insert'
	-- 	INSERT INTO Address
	-- 	(AddrName,Address1,Address2,City,State,ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey,IsValid,ValidAddressKey)
	-- 	SELECT @AddressName,@AddressLine1,@AddressLine2,@City,@State,@Zip,@Country,@WebSite,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey,
    --     @IsValid,@ValidAddressKey

	-- 	SET @AddressKey = SCOPE_IDENTITY();
	-- END
	-- ELSE
	-- BEGIN
    --     print 'Update'
    --     print @AddressKey
	-- 	UPDATE Address SET IsValid=@IsValid ,AddrName=@AddressName,Address1=@AddressLine1,Address2=@AddressLine2,City=@City,State=@State,
	-- 	ZipCode=@Zip,Country=@Country,Website=@WebSite,Phone=@Phone,Email=@Email,Fax=@Fax,Phone2=@Phone2,Email2=@Email2,CityKey=@CityKey,
	-- 	ValidAddressKey=@ValidAddressKey
	-- 	WHERE AddrKey=@AddressKey


	-- END
	-- SELECT @AddressKey AS AddressKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	-- SET @Status=1;
	-- SET @Reason='Success';

    PRINT 'Check AddressKey';
    PRINT @AddressKey;	

    BEGIN TRY
        BEGIN TRANSACTION;

		IF (@AddressKey = 0)
        BEGIN
			SET @AddressKey =  (SELECT ISNULL(( SELECT TOP 1 AddrKey FROM Address
									WHERE LTRIM(RTRIM(Address1)) = LTRIM(RTRIM(@AddressLine1))
									  AND LTRIM(RTRIM(City)) = LTRIM(RTRIM(@City))
									  AND LTRIM(RTRIM([State])) = LTRIM(RTRIM(@State))
									  AND LTRIM(RTRIM(Country)) = LTRIM(RTRIM(@Country))
									  AND LTRIM(RTRIM(ZipCode)) = LTRIM(RTRIM(@Zip))
								), 0));
		END
		print '@AddressKey After ltrim rtrim'
		print @AddressKey

            IF (@AddressKey = 0)
                BEGIN
                    PRINT 'Insert';
                    PRINT @AddressKey;
                    INSERT INTO Address
                    (
                        AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax,
                        Phone2, Email2, CityKey, IsValid, ValidAddressKey
                    )
                    SELECT
                        @AddressName, @AddressLine1, @AddressLine2, @City, @State, @Zip, @Country, @WebSite,
                        @Phone, @Email, @Fax, @Phone2, @Email2, @CityKey, @IsValid, @ValidAddressKey;

                    SET @AddressKey = SCOPE_IDENTITY();
                END
            ELSE
                BEGIN

					IF(@CityKey = 0)
						SET @CityKey = NULL;

                    PRINT 'Update';
                    PRINT @AddressKey;
                    UPDATE Address
                    SET
                        IsValid         =   @IsValid,
                        AddrName        =   @AddressName,
                        Address1        =   @AddressLine1,
                        Address2        =   @AddressLine2,
                        City            =   @City,
                        State           =   @State,
                        ZipCode         =   @Zip,
                        Country         =   @Country,
                        Website         =   @WebSite,
                        Phone           =   @Phone,
                        Email           =   @Email,
                        Fax             =   @Fax,
                        Phone2          =   @Phone2,
                        Email2          =   @Email2,
                        CityKey         =   @CityKey,
                        ValidAddressKey =   @ValidAddressKey
                    WHERE AddrKey       =   @AddressKey;
                END

        -- Success Output
        SET @JsonOutPut= (SELECT @AddressKey AS AddrKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        print '@JsonOutPut' print @JsonOutPut
        SET @Status = 1;
        SET @Reason = 'Success';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback changes on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capture error info
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

        -- Optional: Return error as JSON
        SELECT @Status AS Status, @Reason AS Reason FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH;

END

/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"AddressKey":26265}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Address_GetByKey] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Address_GetByKey]
(
	@UserKey    INT = 0,
	@JSONString NVARCHAR(MAX) = '',
	@Status     BIT = 0 OUTPUT,
	@Reason     VARCHAR(1000) = '' OUTPUT,
	@IsDebug	BIT = 0
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

	DECLARE @AddrKey INT=0	
	SELECT  @AddrKey = AddrKey
	FROM OPENJSON(@JSONString,'$')
	WITH (
		AddrKey		INT		'$.AddressKey'
		)

	-- check if record exists
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.[Address] 
        WHERE AddrKey = @AddrKey
    )
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Address not found';
        RETURN;
    END

    SELECT
        A.AddrKey,
        A.AddrName,
        A.Address1,
        A.Address2,
        A.City,
        A.CityKey,
        A.[State],
        A.ZipCode AS Zip,
        A.Country,
        A.Website,
        A.Phone,
        A.Phone2,
        A.Email,
        A.Email2,
        A.Fax 
    FROM dbo.[Address] A WITH(NOLOCK)
    WHERE A.AddrKey = @AddrKey
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    SET @Status = 1;
    SET @Reason = 'Success';
END;

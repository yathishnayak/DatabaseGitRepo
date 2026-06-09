/**
DECLARE 
	@UserKey		INT				= 512,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0,
	@JSONOutput		NVARCHAR(MAX),
	@Reason			VARCHAR(100)	=''
EXEC Get_WarehouseList_V2 @UserKey,@JSONString,@JSONOutput OUTPUT, @Status OUTPUT,@Reason OUTPUT  -- , @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_WarehouseList_V2]
(
    @UserKey      INT = 488,
    @JSONString   NVARCHAR(MAX) = '',
    @JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
    @Status       BIT = 0 OUTPUT,
    @Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    BEGIN TRY
        -- Initialize output parameters
        SET @Reason = 'Success';
        SET @Status = 1;

        -- Get warehouse list with address details in JSON format
            SELECT 
                W.WarehouseKey,
                W.WarehouseID,
                W.AddrKey,
                W.StatusKey,
                W.CompanyKey,
                [Address] = JSON_QUERY((
                    SELECT 
                        A.AddrKey,
                        A.AddrName,
                        A.Address1,
                        A.Address2,
                        A.City,
                        A.CityKey,
                        A.State,
                        A.ZipCode AS Zip,
                        A.Country,
                        A.Fax,
                        A.Website,
                        A.Email,
                        A.Email2,
                        A.Phone,
                        A.Phone2
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ))
            FROM dbo.Warehouse W WITH (NOLOCK)
                INNER JOIN dbo.Address A WITH (NOLOCK) ON W.AddrKey = A.AddrKey
            FOR JSON PATH;

    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = 'Error: ' + ERROR_MESSAGE();
        SET @JSONOutput = NULL;
    END CATCH
END
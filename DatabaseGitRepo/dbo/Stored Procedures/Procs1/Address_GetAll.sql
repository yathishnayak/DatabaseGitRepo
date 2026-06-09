/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Address_GetAll] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Address_GetAll]
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

    SELECT
        A.AddrKey,
        A.AddrName,
        A.Address1,
        A.Address2,
        A.City,
        A.CityKey,
        A.[State],
        A.ZipCode,
        A.Country,
        A.Website,
        A.Phone,
        A.Phone2,
        A.Email,
        A.Email2,
        A.Fax ,
        IsValid,
        ValidAddressKey
    FROM dbo.[Address] A WITH(NOLOCK)
    FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';
END;

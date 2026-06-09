/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{
									"SearchText": "9810"
								}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [Address_Search] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Address_Search]
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

	DECLARE @SearchText	NVARCHAR(MAX)=''

	SELECT  @SearchText = SearchText

	FROM OPENJSON(@JSONString,'$')
    WITH (			
			SearchText		NVARCHAR(MAX)	'$.SearchText'
		)

	SELECT AddressList = 
		(SELECT AddrKey, AddrName, Address1, Address2, City, [State], ZipCode, Country, Website, 
			Phone, Email, Fax, Phone2, Email2, CityKey, IsValid, ValidAddressKey 
			--INSERT INTO #TempAddress
			FROM [Address]
			WHERE AddrName LIKE '%' + @SearchText + '%' 
			   OR ZipCode LIKE '%' + @SearchText + '%'
			FOR JSON PATH)

        -- Success Output
        --SET @JsonOutPut= (SELECT @AddressKey AS AddressKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        print '@JSONString' print @JSONString
        SET @Status = 1;
        SET @Reason = 'Success';
END

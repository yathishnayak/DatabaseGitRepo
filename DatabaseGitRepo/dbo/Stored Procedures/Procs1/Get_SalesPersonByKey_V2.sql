/*

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"SalePersonKey":4}',
	@Status BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_SalesPersonByKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status AS Status, @Reason AS Reason

*/

CREATE PROC [dbo].[Get_SalesPersonByKey_V2]
(
	@UserKey      INT=488,
	@JSONString   NVARCHAR(MAX)='',
	--@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @Status = 0;
	SET @Reason = 'FAIL';

	DECLARE @SalePersonKey INT;

	SET @SalePersonKey = JSON_VALUE(@JSONString, '$.SalePersonKey');

	IF(ISNULL(@SalePersonKey, 0)=0)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Invalid or missing SalePersonKey in JSON';
		RETURN;
	END

	SELECT 
		SalesPersonKey, 
		SalesPersonID, 
		SalesPersonName,
		FirstName, 
		LastName, 
		SP.AddrKey, 
		IsActive,
		LinkedUserKey, 
		U.UserName as LinkedUserName
	FROM SalesPerson SP WITH (NOLOCK)
	INNER JOIN Address  A  WITH (NOLOCK) ON SP.AddrKey = A.AddrKey
	LEFT JOIN [User] U  WITH (NOLOCK) ON SP.LinkedUserKey = U.UserKey
	WHERE SalesPersonKey = @SalePersonKey
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'SUCCESS'
End

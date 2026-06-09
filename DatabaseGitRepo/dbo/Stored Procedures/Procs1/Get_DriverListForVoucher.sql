/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@IsDebug BIT=1
EXEC [Get_DriverListForVoucher] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Get_DriverListForVoucher]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS 
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON


	SELECT DriverKey, DriverID, Firstname AS FirstName, LastName FROM DRIVER
	WHERE TRY_CAST(
					  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
				  ) AS INT) BETWEEN 700 AND 946
	ORDER BY DriverID
		FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;
END
/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@IsDebug BIT=1
EXEC [Get_AllCustomerName] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_AllCustomerName]
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

	SELECT DISTINCT TRIM(CustName) AS CustName FROM Customer
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;
END
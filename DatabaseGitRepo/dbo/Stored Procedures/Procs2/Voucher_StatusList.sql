/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT=0, 
	@IsDebug INT = 0,
	@Reason VARCHAR(100)=''
EXEC Voucher_StatusList @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Voucher_StatusList]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Status = 0
	SET @Reason='Failure'

	SELECT StatusKey,[Description] 
	FROM VoucherStatus WITH(NOLOCK)  WHERE Statuskey IN (2,3)
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';
END

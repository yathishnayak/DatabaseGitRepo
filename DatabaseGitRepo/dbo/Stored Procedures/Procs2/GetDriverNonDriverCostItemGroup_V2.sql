/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT=0, 
	@IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec [GetDriverNonDriverCostItemGroup_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetDriverNonDriverCostItemGroup_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '{}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT DriverNonDriverCostKey,DriverNonDriverCostId,DriverNonDriverCostDesc 
	FROM DriverNonDriverCostItems WITH (NOLOCK) WHERE ISActive=1 AND IsDeleted=0
	FOR JSON PATH


		SET @Status = 1
		SET @Reason = 'Success'
END



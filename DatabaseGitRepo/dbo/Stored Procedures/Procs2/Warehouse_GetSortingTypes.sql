/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
EXEC [Warehouse_GetSortingTypes] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @reason AS Reason
**/
CREATE PROCEDURE [dbo].[Warehouse_GetSortingTypes]
(
	@UserKey      INT = 512,
	@JSONString   NVARCHAR(MAX) = '',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN

	SET @Status = 1
	SET @Reason = 'Success'

	SELECT SortingKey,Description
	FROM Warehouse_Container_Sorting WITH (NOLOCK)
	WHERE IsActive = 1

	FOR JSON PATH;
END
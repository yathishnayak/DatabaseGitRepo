
CREATE PROCEDURE [dbo].[Get_ItemType_V2]
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

	SELECT I.ItemTypeKey,I.ItemType,I.Description AS ItemTypeDescription,CreateDate
	FROM dbo.ItemType I
	FOR JSON PATH


		SET @Status = 1
		SET @Reason = 'Success'
END


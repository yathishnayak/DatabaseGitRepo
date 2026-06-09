
CREATE PROCEDURE [dbo].[Get_ItemCategory_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SELECT CategoryKey,[Name] CategoryName FROM ItemCategory
	FOR JSON PATH
END

	

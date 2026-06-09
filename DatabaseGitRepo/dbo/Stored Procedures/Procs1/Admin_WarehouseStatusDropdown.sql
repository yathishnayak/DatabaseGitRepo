CREATE Procedure [dbo].[Admin_WarehouseStatusDropdown](
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' output ,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = ''  output
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	  SET @Reason='Success'
	  SET @Status=1
	  SELECT StatusKey,Description FROM WarehouseStatus FOR JSON PATH;
END

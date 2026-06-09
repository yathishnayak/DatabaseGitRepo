
CREATE PROCEDURE [dbo].[Scheduler_GetLocationConversions]
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
	SET @Status=1
	SET @Reason='Success'

	SELECT DISTINCT LocationConvert FROM LocationConversion
	--UNION ALL 
	--SELECT 'Shipper' LocationConvert 
	--UNION ALL
	--SELECT 'Customer' LocationConvert 
	FOR JSON PATH;
END
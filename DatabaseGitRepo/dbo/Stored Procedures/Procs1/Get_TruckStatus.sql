
/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX) = '',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@JSONOutput NVARCHAR(MAX)='';
EXEC [Get_TruckStatus] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT;
SELECT  @Status AS Status, @Reason AS Reason;
*/

CREATE PROCEDURE [dbo].[Get_TruckStatus]	
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 output,
	@Reason       VARCHAR(100) = '' OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

		SELECT TS.TruckStatusKey,TS.TruckStatus From TruckStatus TS WITH(NOLOCK)
		WHERE IsActive = 1 and IsDelete = 0
		FOR JSON PATH

		SET @Status = 1;
		SET @Reason = 'Success';
		
END

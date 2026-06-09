/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@JSONOutput     NVARCHAR(MAX) = '',
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [WeightUnit_GetList] @Userkey, @JSONSTRING, @JSONOutput OUTPUT, @Status OUTPUT, @Reason Output
SELECT @Status AS Status, @Reason AS Reason, @JSONOutput AS JSONOutput
**/
CREATE PROCEDURE [dbo].[WeightUnit_GetList]
(
	@UserKey      INT = 512,
	@JSONString   NVARCHAR(MAX) = '',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	SET @Status = 1;
	SET @Reason = 'SUCCESS';

	SET @JSONOutput = (SELECT WeightUnitKey,WeightUnit FROM WeighUnit WITH(NOLOCK) FOR JSON PATH)
	SELECT @JSONOutput;
END
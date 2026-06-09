/*
DECLARE 
	@UserKey INT = 944, 
	@JSONString NVARCHAR(MAX),
	@Status BIT = 0,
	@Reason VARCHAR(1000), 
	@IsDebug BIT = 1 

SET @JSONString ='{}' 
EXEC [dbo].[Get_AppConfig] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Get_AppConfig]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
		SELECT 
			CompanyKey,
			ConfigId,
			ConfigName,
			ConfigValue1,
			ConfigValue2,
			ConfigValue3 FROM AppConfig

            
        FOR JSON PATH
	);
 
	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';

END

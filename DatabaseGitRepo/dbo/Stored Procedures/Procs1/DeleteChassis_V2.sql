/*
DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"ChassisKey":0}'
 
EXEC [DeleteChassis_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[DeleteChassis_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE  @ChassisKey INT,@CNT INT = 0;
	SELECT @ChassisKey = chassisKey
	from OPENJSON(@JSONString, '$')
	with (
			ChassisKey int '$.ChassisKey'
		 )

	
	SET @CNT = (SELECT COUNT(chassisNo) FROM Chassis WHERE chassisKey = @chassisKey)
	IF(@CNT = 0)
		BEGIN
			SET @Reason = 'No record found for the given chassis data';
			SET @Status = 0;
			RETURN;
		END
ELSE
		BEGIN 
			UPDATE		Chassis
			SET			IsActive = 0 , IsDelete = 1, UpdateDate = GETDATE(), UpdateUser = @UserKey 
			WHERE		chassisKey = @chassisKey

			SET @Reason = 'Chassis Deleted Successfully'
			SET @Status = 1;
			RETURN;
		END
END
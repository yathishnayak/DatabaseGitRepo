
CREATE Procedure [dbo].[DeleteChassis]
(
	@chassisKey  INT ,
	@UserKey     INT,
	@OutPut      bit = 0 OUTPUT,
	@Reason      varchar(100) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CNT INT = 0;
	SET @CNT = (SELECT COUNT(chassisNo) FROM Chassis WHERE chassisKey = @chassisKey)
	IF(@CNT = 0)
		BEGIN
			SET @Reason = 'No record found for the given chassis data';
			SET @OutPut = 0;
			RETURN;
		END
ELSE
		BEGIN 
			UPDATE		Chassis
			SET			IsActive = 0 , IsDelete = 1, UpdateDate = GETDATE(), UpdateUser = @UserKey 
			WHERE		chassisKey = @chassisKey

			SET @Reason = 'Chassis Deleted Successfully'
			SET @OutPut = 1;
			RETURN;
		END
END

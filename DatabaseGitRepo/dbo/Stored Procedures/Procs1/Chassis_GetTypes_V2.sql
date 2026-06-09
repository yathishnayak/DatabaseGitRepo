CREATE  PROCEDURE [dbo].[Chassis_GetTypes_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '{}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT  DISTINCT ChassisType
	FROM Chassis WITH (NOLOCK)	WHERE ChassisType <> 'Ext'
	ORDER BY ChassisType
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'


  END
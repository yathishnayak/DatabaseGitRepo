 
/*
SELECT * FROM ContainerLocation

DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{}'
 
EXEC [Get_ContainerLocation] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/
CREATE PROCEDURE [dbo].[Get_ContainerLocation]
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
 
	DECLARE @ContainerLocationKey INT;
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult = (
		SELECT CL.ContainerLocationKey,CL.LocationDescription,CL.IsActive,CL.IsDeleted
		FROM ContainerLocation CL
		WHERE CL.IsActive = 1
		ORDER BY CL.ContainerLocationKey
	FOR JSON PATH
	);
 
	SELECT @JSONResult AS JSONResult
		
	SET @Status = 1;
	SET @Reason = 'Success';

END

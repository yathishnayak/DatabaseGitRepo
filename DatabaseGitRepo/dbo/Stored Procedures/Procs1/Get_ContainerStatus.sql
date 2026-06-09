/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX) = '',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@JSONOutput NVARCHAR(MAX)='';

EXEC [Get_ContainerStatus] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT;

SELECT  @Status, @Reason ;
*/

CREATE PROCEDURE [dbo].[Get_ContainerStatus]
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

		SELECT ContainerStatusKey,ContainerStatus From ContainerStatus 
		WHERE IsActive=1 AND IsDelete=0
		FOR JSON PATH


		SET @Status = 1;
		SET @Reason = 'Success';
		
END

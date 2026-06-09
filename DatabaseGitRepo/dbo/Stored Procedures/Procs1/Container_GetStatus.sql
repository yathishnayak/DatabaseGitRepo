CREATE PROCEDURE [dbo].[Container_GetStatus]
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;
SET ARITHABORT ON;

	SET @Status=0;
	SET @Reason='Failure';
	
	
	--SELECT [Status] AS StatusKey, [Description] AS StatusName 
	--		FROM OrderDetailStatus 
	--		WHERE StatusType='Schedule' FOR JSON PATH;

	SELECT  StatusKey, StatusName 
			FROM Scheduler_GnosisContainerStatus WITH(NOLOCK)
			FOR JSON PATH;
	SET @Status=1;
	SET @Reason='SUCCESS';
END
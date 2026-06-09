CREATE PROCEDURE [dbo].[Insert_ScheduleDocument]
/*
Insert Multiple Scheduler Documents - Scheduler Screen
*/
@DocumentKey	VARCHAR(100),
@RouteKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	
	INSERT INTO dbo.SchedulerDocument(DocumentKey,RouteKey) 
	SELECT [Value],@RouteKey
	FROM [Fn_SplitParam] ( @DocumentKey );

	SET @OutPut=1;
END

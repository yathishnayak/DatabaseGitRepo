CREATE PROCEDURE [dbo].[Update_DriverNotesbyOrderDetailKey]
/*
RoutsDL
*/
@OrderKey		INT,
@OrderDetailKey INT,
@DriverNotes	VARCHAR(500),
@CreateUserKey	INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	
	DECLARE @New_CommentKey INT;

	INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
		VALUES (@DriverNotes, GETDATE(),@CreateUserKey);
		
	SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

	INSERT INTO dbo.SchedulerDriverComment(CommentKey,RouteKey,OrderDetailKey)
	VALUES (@New_CommentKey, Null,@OrderDetailKey);

	SET @OutPut=1;
END

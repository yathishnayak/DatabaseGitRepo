CREATE PROCEDURE [dbo].[Update_OrderHeaderStatus]
/*
Order Screen
*/
@Orderkey	INT,
@StatusKey	SMALLINT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.OrderHeader 
	SET [Status]= @StatusKey, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey  ,StatusDate=GETDATE()
	WHERE Orderkey = @OrderKey;

	SET @OutPut=1;
END

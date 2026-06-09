CREATE PROCEDURE [dbo].[Insert_User]
@UserKey	INT,
@UserName	VARCHAR(50),
@OutPut		BIT OUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	INSERT INTO dbo.[User] (UserKey,UserName)
	VALUES(@UserKey,@UserName)

	SET @OutPut=1;
END;

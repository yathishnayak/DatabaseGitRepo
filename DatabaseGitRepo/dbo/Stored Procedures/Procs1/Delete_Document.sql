
CREATE PROCEDURE [dbo].[Delete_Document]
@DocumnetKey	INT ,
@DeletedUserKey INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.Document  
	SET IsDeleted = 1 , DeletedDate = GETDATE(),DeletedUserKey=@DeletedUserKey
	WHERE DocumentKey = @DocumnetKey;

  SET @OutPut=1;
	
END

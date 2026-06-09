
CREATE PROCEDURE [dbo].[Insert_Document]
@DocumentType		INT,
@createuserKey		INT,
@OriginalFileName	VARCHAR(500),
@CustomerGroup		SMALLINT,
@OriginalFileType	VARCHAR(50),
@FileSizeinMB		SMALLINT,
@PaymentTerms		SMALLINT,
@FilePath			VARCHAR(500),
@DocumnetKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.Document ( DocumentType,CreateDate,CreateUserKey,OriginalFileName,OriginalFileType,FileSizeinMB,IsDeleted,DeletedDate,FilePath  ) 
	VALUES ( @DocumentType, GETDATE(), @createuserKey,@OriginalFileName,@OriginalFileType,@FileSizeinMB,0,NULL,@FilePath)

	SET @DocumnetKey= ( SELECT SCOPE_IDENTITY() )
END

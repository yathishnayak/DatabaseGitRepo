

CREATE PROC [dbo].[TMS_Integration_UpdateDocumentStatus_Melrose](
	@JsonString NVARCHAR(MAX)
)AS BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @dodockey INT;

	SELECT  @dodockey = DoDocKey
	FROM	OPENJSON(@JsonString,'$')
			WITH(
				DoDocKey INT '$.DODockey'
			)

	UPDATE  Integration_JCB.dbo.Melrose_Documents
	SET		IsMovedToTMS = 1, MovedToTMSDate = GETDATE()
	WHERE	@dodockey = DODockey
	RETURN;
END


CREATE PROCEDURE [dbo].[Insert_DriverDocument]
/*
dbo.fn_insert_orderheader_document
Insert Multiple Order Detail Documents 
*/
@DocumentKey	VARCHAR(100),
@DriverKey		INT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document 
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM DriverDocuments ODD 
		INNER JOIN dbo.Document D ON D.DocumentKey=ODD.DocumentKey 
	WHERE D.IsDeleted=0 AND ODD.DriverKey=@DriverKey;

	
	INSERT INTO dbo.DriverDocuments(DriverKey, Documentkey)
	SELECT @DriverKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );
END

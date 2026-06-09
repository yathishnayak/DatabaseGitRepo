
CREATE PROCEDURE [dbo].[Insert_ContainerLegDocument]
@RouteKey		INT,
@DocumentKey	VARCHAR(100)
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
	FROM ContainerLegDocuments CLD 
		INNER JOIN dbo.Document D ON D.DocumentKey=CLD.DocumentKey 
	WHERE D.IsDeleted=0 AND CLD.RouteKey=@RouteKey;

	
	INSERT INTO dbo.ContainerLegDocuments(RouteKey, Documentkey)
	SELECT @RouteKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );
END

CREATE PRoc [dbo].[Get_ContainerAllDocuments_V2] -- Get_ContainerAllDocuments 49
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
	
)
as
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	
	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter missing';
	END

	SET @Status=1;
	SET @Reason='SUCCESS';

	DECLARE @OrderDetailKey int = 13

	SELECT @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderDetailKey			INT	'$.OrderDetailKey'
		 )

	SELECT CD.DocumentKey,CD.OriginalFileName, CD.OriginalFileType ,CD.FileSizeinMB,
			CD.DocType, CD.DocumentTypeKey, CD.OrderDetailKey, CD.Levl,
			CD.LegID, CD.LegTypeID, CD.LegNo,
			CD.CreateDate, CD.LinkTo, CD.StoragePath, CD.OrderNo,
			CD.ROUTEKEY as RouteKey, CD.OrderKey, CD.DocumentUserKey,
			CD.DocumentWithPath ,	U.UserName, DD.DocSource
	FROM vContainerDocuments_V2 CD
	INNER JOIN [User] U ON (U.UserKey=CD.DocumentUserKey)
	LEFT JOIN DriverDocuments DD WITH (NOLOCK) ON DD.DocumentKey=CD.DocumentKey
	WHERE OrderDetailKey = @OrderDetailKey
	ORDER BY CreateDate DESC
	FOR JSON PATH;

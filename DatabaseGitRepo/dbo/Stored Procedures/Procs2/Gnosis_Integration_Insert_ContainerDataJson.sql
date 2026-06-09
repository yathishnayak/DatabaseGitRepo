
CREATE PROCEDURE [dbo].[Gnosis_Integration_Insert_ContainerDataJson]
(
	 @RecordID			VARCHAR(50)
	,@PageNo			INT
	,@ContainerDataJson	NVARCHAR(MAX)
)

AS

BEGIN
	DECLARE @RecordKey INT
	INSERT INTO Gnosis_Integration_ContainerDataJson
				(GroupRecordID,PageNo,ContainerDataJson,CreatedDate)
	SELECT		@RecordID,@PageNo,@ContainerDataJson,GETUTCDATE()

	SET @Recordkey = @@IDENTITY

	SELECT ISNULL(@Recordkey,0) AS RecordKey 

END

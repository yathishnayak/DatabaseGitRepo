CREATE PROC [dbo].[Gnosis_Integration_Insert_ImportDrayageDetails](
	@JsonString NVARCHAR(MAX)
)AS BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON

	IF(LEFT(LTRIM(@JsonString), 1) = '{')
	BEGIN
		SET @JsonString = CONCAT('[',@JsonString,']')
	END

	INSERT INTO Gnosis_Integration_ImportDrayageDetails(
		UUID,
		DrayageUUID,
		ContainerNo,
		BOL,
		DrayageType,
		IsProcessed,
		EmptyDate,
		CreatedDate
	)
	SELECT
		j_UUID,
		j_DrayageUUID,
		j_ContainerNo,
		j_BOL,
		j_DrayageType,
		j_IsProcessed,
		j_EmptyDate,
		GETDATE()
	FROM
		OPENJSON(@JsonString)
		WITH(
			j_UUID						VARCHAR(100)	'$.UUID',
			j_DrayageUUID				VARCHAR(100)	'$.DrayageUUID',
			j_ContainerNo				VARCHAR(50)		'$.ContainerNo',
			j_BOL						VARCHAR(50)		'$.MBLNumber',
			j_DrayageType				VARCHAR(20)		'$.DrayageType',
			j_IsProcessed				BIT				'$.IsProcessed',
			j_EmptyDate					DATETIME		'$.EmptyDate'
		)
END
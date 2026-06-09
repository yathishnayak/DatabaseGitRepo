CREATE PROC [dbo].[MelroseIntegrate_UPdateIsSentToMelrose]  
-- MelroseIntegrate_UPdateIsSentToMelrose '[{"DataKey":1,"IsSent":false},{"DataKey":2,"IsSent":false},{"DataKey":3,"IsSent":true}]'
(
	@JsonString NVARCHAR(MAX) = ''
)

AS

BEGIN
	CREATE TABLE #TMP
	(
		DataKey		INT,
		IsSent		BIT
	)

	INSERT INTO #TMP( DataKey,IsSent)
	SELECT		Datakey,IsSent
	FROM		OPENJSON(@JsonString, '$')
				WITH (
						Datakey		INT			'$.DataKey',
						IsSent		VARCHAR(10)	'$.IsSent'
					)

	UPDATE		RD SET IsDataSenttoMelrose = 1, SentToMelroseDate = GETDATE()
	FROM		#TMP T
	INNER JOIN	MelroseIntegrate_RouteDateUpdates RD WITH (NOLOCK) ON T.DataKey >= RD.Datakey
	WHERE		ISNULL(IsDataSenttoMelrose,0) = 0 AND T.IsSent = 1

	DROP TABLE	#TMP

END

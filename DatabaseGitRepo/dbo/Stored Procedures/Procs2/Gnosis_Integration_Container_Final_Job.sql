
CREATE PROCEDURE [dbo].[Gnosis_Integration_Container_Final_Job]
AS

DECLARE			@DataKey INT,
				@UUID	VARCHAR(50)
DECLARE			_Cursor CURSOR LOCAL FOR
SELECT			DataKey, C.UUID 
FROM			(SELECT		DataKey, UUID 
				FROM		(SELECT		ROW_NUMBER() OVER(PARTITION BY  UUID ORDER BY Updated_dt DESC ) Sl, DataKey, UUID 
							FROM Gnosis_Integration_Container WITH (NOLOCK)) A
				WHERE		Sl = 1) C 
LEFT JOIN		Gnosis_Integration_Container_Final CF WITH (NOLOCK)   ON C.DataKey = CF.LastDataKey   AND C.UUID = CF.UUID
WHERE			CF.LastDataKey IS NULL
OPEN			_Cursor
FETCH NEXT FROM _Cursor INTO @DataKey, @UUID
WHILE		@@FETCH_STATUS = 0
	BEGIN
		EXEC	Gnosis_Integration_InsertDataToFinal @uuid, @Datakey
		FETCH NEXT FROM _Cursor INTO @DataKey, @UUID
	END
CLOSE		_Cursor
DEALLOCATE	_Cursor
--EXEC Gnosis_Update_PortOutGateDate_FromTMS
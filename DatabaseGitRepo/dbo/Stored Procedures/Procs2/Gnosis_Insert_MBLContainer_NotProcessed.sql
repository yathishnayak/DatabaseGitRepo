

CREATE PROCEDURE [dbo].[Gnosis_Insert_MBLContainer_NotProcessed]
(
	@JsonDate	NVARCHAR(MAX) = '[{"track_all_containers_under_mbl":false,"submitted_mbl":"VIC-FULLETON-VIC","containers":[{"container_number":"TRAI0000002","OrderDetailKey":62026},{"container_number":"TRIA0000001","OrderDetailKey":62027},{"container_number":"TRAI0000003","OrderDetailKey":62025}]}]'
)

AS

BEGIN

CREATE TABLE #Container
(
		MBL				VARCHAR(50),
		containersJson	NVARCHAR(MAX)
)


INSERT INTO	#Container (MBL,containersJson)	
SELECT		MBL,containers
FROM		OPENJSON(@JsonDate, '$')
					WITH (
						MBL						VARCHAR(50)		'$.submitted_mbl',
						containers				NVARCHAR(MAX)	'$.containers' AS JSON)

DECLARE @containersJson NVARCHAR(MAX), @MBL VARCHAR(50)
(SELECT @containersJson = containersJson, @MBL = MBL FROM #Container) 

SELECT		@MBL MBL,container_number,OrderDetailKey, GETDATE() CreatedDate
INTO		#TMPData
FROM		OPENJSON(@containersJson, '$')
					WITH (
						container_number			VARCHAR(50)		'$.container_number',
						OrderDetailKey				VARCHAR(50)		'$.OrderDetailKey' )

INSERT INTO		Gnosis_MBLContainer_NotProcessed
SELECT			TD.*
FROM			#TMPData TD 
LEFT JOIN		Gnosis_MBLContainer_NotProcessed NP  WITH (NOLOCK) ON NP.OrderDetailKey = TD.OrderDetailKey
WHERE			NP.OrderDetailKey IS NULL

END


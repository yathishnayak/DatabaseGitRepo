

CREATE PROCEDURE [dbo].[Gnosis_Integration_GetInitialData]
AS

SELECT			DataCount,		dateadd(d, -0, isnull(LastDataPullDate, Getdate())) LastDataPullDate
FROm			(SELECt			COUNT(*) DataCount
				FROM			Gnosis_Integration_Container WITH (NOLOCK) ) A
INNER JOIN		(SELECT			DISTINCT MIN(A.CreatedDate)  LastDataPullDate
				FROM			Gnosis_Integration_ContainerDataJson A WITH (NOLOCK)
				INNER JOIN		(SELECT GroupRecordID FROM Gnosis_Integration_ContainerDataJson A WITH (NOLOCK)
								INNER JOIN (SELECT MAX(CreatedDate)CreatedDate FROM Gnosis_Integration_ContainerDataJson WITH (NOLOCK)) B ON A.CreatedDate = B.CreatedDate ) B
								ON A.GroupRecordID = B.GroupRecordID ) B ON 1 = 1
				FOR JSON PATH , WITHOUT_ARRAY_WRAPPER

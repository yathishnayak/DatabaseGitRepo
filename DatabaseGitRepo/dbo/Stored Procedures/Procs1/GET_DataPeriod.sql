CREATE PROCEDURE [dbo].[GET_DataPeriod]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF 

	SELECT PeriodKey,[Description],IsDefault 
	FROM [DataPeriod] A 
		INNER JOIN [Status] S ON S.Statuskey=A.StatusKey
	WHERE S.StatusName='Active'
END

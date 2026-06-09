


CREATE PROCEDURE [dbo].[COST_GetFileUploadStatus]

AS


BEGIN
	
	 -- SELECT * FROM COST_FileProcessInfo

	UPDATE				FP
	SET					FileLink = FE.FileLink, IsRecordUpdated =  CASE WHEN DiffMinutes > 5 OR FE.IsfileDownloaded = 1 THEN 1 ELSE 0 END
	FROm				COST_VGetFileErrorFileCreateStatus FE
	INNER JOIN			COST_FileProcessInfo FP ON FE.FileProcessKey = FP.FileProcessKey

	SELECT				FileProcessKey,FileName,DateUploaded,MarketLocation,FileUploadStatus,FileProcessStatus,IsEmailSent, ISNULL(Isfiledownloaded,0)Isfiledownloaded , U.UserName AS UserName
						, ISNULL(FileLink,'')FileLink, '' AS FileURL
	FROM				COST_FileProcessInfo F
	LEft join			[User] U on F.UserKey = U.UserKey
	ORDER BY			FileProcessKey DESC

END



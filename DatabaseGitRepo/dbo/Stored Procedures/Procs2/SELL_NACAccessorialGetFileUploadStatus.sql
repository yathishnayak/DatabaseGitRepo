
CREATE PROCEDURE [dbo].[SELL_NACAccessorialGetFileUploadStatus]

AS


BEGIN
	
	 -- SELECT * FROM SELL_NAC_Accessorial_FileProcessInfo

	SELECT				FileProcessKey,FileName,DateUploaded,CustName,FileUploadStatus,FileProcessStatus,IsEmailSent, ISNULL(Isfiledownloaded,0)Isfiledownloaded , U.UserName AS UserName
						, ISNULL(FileLink,'')FileLink, '' AS FileURL
	FROM				SELL_NAC_Accessorial_FileProcessInfo F
	LEft join			[User] U on F.UserKey = U.UserKey
	LEFT JOIN			Customer C WITH (NOLOCK) ON (C.CustKey=F.CustKey)
	ORDER BY			FileProcessKey DESC

END



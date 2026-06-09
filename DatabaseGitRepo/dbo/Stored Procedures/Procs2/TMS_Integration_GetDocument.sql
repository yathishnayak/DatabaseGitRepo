

CREATE PROC [dbo].[TMS_Integration_GetDocument] -- TMS_Integration_GetDocument 65387, 645999, 'Flexport'
(
	@DataKey		INT,
	@TMS_routeKey	INT,
	@SiteId			VARCHAR(20)
)
AS
BEGIN
	CREATE TABLE #Temp_GetDoc
	(
		shortcode	varchar(5)
	)
	if(@SiteId = 'DHL')
	BEGIN
		--INSERT INTo #Temp_GetDoc values ('POD'),('ING'),('OTG')
		INSERT INTO #Temp_GetDoc values ('POD') 
	END
	ELSE
	BEGIN
		INSERT INTO #Temp_GetDoc values ('POD')
	END
	SELECT			top 1 IC.DataKey, IC.ContainerKey, IC.TMS_OrderDetailKey, ODC.ROUTEKEY, IC.SiteID,
					D.DocumentKey, replace(D.FilePath,'/','\') as FilePath, D.OriginalFileName, D.OriginalFileType, DT.Shortcode
	FROM			OrderDetail od
	INNER JOIN		TMS_INTEGRATION_CONTAINER IC ON OD.OrderDetailKey = IC.TMS_OrderDetailKey
	INNER JOIN		ContainerDocuments ODC ON od.OrderDetailKey = ODC.OrderDetailKey
	INNER JOIN		Document D ON ODC.DocumentKey = D.DocumentKey
	INNER JOIN		DocumenType DT ON D.DocumentType = DT.DocumentTypeKey
	INNER JOIN		#Temp_GetDoc T on DT.Shortcode = T.shortcode
	--WHERE			IC.SiteID = @SiteId and Shortcode in ('POD','ING','ORG') and IC.DataKey = @DataKey and ODC.ROUTEKEY = @TMS_routeKey
	WHERE			IC.SiteID = @SiteId -- and Shortcode in  ('POD','ING', 'OTG' ) 
					and IC.DataKey = @DataKey and ODC.ROUTEKEY = @TMS_routeKey
	ORDER BY		DocumentKey desc
	For JSON path, without_array_wrapper
	Drop Table #Temp_GetDoc
END

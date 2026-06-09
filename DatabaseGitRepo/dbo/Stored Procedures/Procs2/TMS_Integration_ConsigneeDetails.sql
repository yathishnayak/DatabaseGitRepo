


CREATE Proc [dbo].[TMS_Integration_ConsigneeDetails]
AS

SELECT	* FROM vGetConsigneeDetails
ORDER BY ConsigneeKey 
FOR		JSON PATH







-- Drop table TestDataMel
-- SELECT * FROM TestDataMel
CREATE Proc [dbo].[TMS_Integration_CustomerDetails]
AS


-- SELECT TOp 10 * INTO TestDataMel FROM  Customer

SELECT * FROM vGetCustomerDetails
ORDER BY	CustName
FOR JSON PATH


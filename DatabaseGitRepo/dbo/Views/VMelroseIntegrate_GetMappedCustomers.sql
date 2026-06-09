




CREATE	VIEW	[dbo].[VMelroseIntegrate_GetMappedCustomers] -- SELECT * FROM VMelroseIntegrate_GetMappedCustomers
AS


	SELECT		CD.CustKey, CustName, CAST(CASE WHEN MC.CustKey  IS NOT NULL AND  ISNULL(IsDeleted,0) = 0 THEN 1 ELSE 0 END AS BIT) AS IsMapped
	FROM		vGetCustomerDetails CD
	LEFT JOIN	MelroseIntegrate_MappedCustomers MC ON CD.CustKey = MC.CustKey
	--LEFT JOIN	Integration_JCB.dbo.VGetEDICustomers ED ON CD.CustKey = ED.CustKey
	WHERE		IsActive = 1 -- AND ED.CustKey IS NULL
	-- ORDER BY	CASE WHEN MC.CustKey IS NOT NULL THEN 1 ELSE 0 END DESC, CustName 


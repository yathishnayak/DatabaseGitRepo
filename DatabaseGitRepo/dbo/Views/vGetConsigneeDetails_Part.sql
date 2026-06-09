
CREATE VIEW [vGetConsigneeDetails_Part]
AS
SELECT		C.Custkey, C.AddrKey ConsigneeKey, c.ConsigneeID, CT.CustName ConsigneeName, C.AddrKey
			,A.AddrName, A.Address1, A.Address2,  A.City, A.State, A.ZipCode
			, CASE WHEN CT.StatusKey = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsActive 
			, CASE WHEN CT.StatusKey = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsDelete
FROM		Consignee c WITH (NOLOCK)
INNER JOIN	Customer  CT WITH (NOLOCK) ON C.CustKey = CT.CustKey
INNER JOIN  Address A WITH (NOLOCK) ON C.AddrKey = A.AddrKey
-- WHERE		ISNULL(CT.IsActive,0) = 1
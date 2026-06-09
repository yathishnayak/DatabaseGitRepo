

CREATE VIEW [dbo].[vGetCustomerDetails]
AS
SELECT		c.CustKey CustKey, c.CustID CustID, C.CustName, S.StatusKey,StatusName
			, CASE WHEN S.StatusKey = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsActive 
			, CASE WHEN S.StatusKey = 2 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsInactive 
			, CASE WHEN S.StatusKey = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsDelete
			, CreditCheck, CreditLimit
			, CreditStatus, Ach_Required, PaymentTermsKey, C.AddrKey
			,A.AddrName, A.Address1, A.Address2,  A.City, A.State, A.ZipCode, C.BillToAddrKey, A1.AddrName BTAddrName, A1.Address1 BTAddress1, A1.Address2 BTAddress2, A1.City BTCity, A1.State BTState, A1.ZipCode BTZipCode
FROM		Customer c with (nolock)
INNER JOIN	Status S with (nolock) on C.StatusKey = S.StatusKey
INNER JOIN	Address A with (nolock) on c.AddrKey = A.AddrKey
INNER JOIN	Address A1 with (nolock) on c.BillToAddrKey = A1.AddrKey
--WHERE		ISNULL(C.IsActive,0) = 1



CREATE PROCEDURE [dbo].[Get_SingleCustomerContact] -- [Get_SingleCustomerContact] 1150
(
	@CustKey int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT	
	isnull(z.AddrKey,0) as AddrKey,
		 C.Custkey, C.Custid, C.CustName,
		 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
		 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'')AS State,
		 ISNULL(Z.ZipCode,'') AS ZipCode
		 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
		 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax,
		 S.StatusName, C.StatusKey,  ISNULL(C.CustName,'') AS  CustAddrName ,
		 CA.AddrType as AddressType,
		 ISNULL(C.CreditLimit,0) AS CreditLimit, C.CreditStatus, ISNULL(C.Ach_Required,0) AS Ach_Required,ISNULL(C.CreditCheck,0)	AS CreditCheck
	FROM dbo.Customer C 
		INNER JOIN CustomerAddress CA ON CA.CustKey=C.CustKey
		INNER JOIN [Address] Z ON Z.AddrKey=CA.AddrKey
		INNER JOIN [Status] S ON S.Statuskey=C.StatusKey 
		WHERE C.CustKey = @CustKey and  S.StatusName='Active'  	
	ORDER BY CustName,AddrName;
END;

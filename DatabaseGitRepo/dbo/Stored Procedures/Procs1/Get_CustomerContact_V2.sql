/**
DECLARE 
	@UserKey INT,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT=0, 
	@IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec [Get_CustomerContact_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_CustomerContact_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--SELECT C.CustKey INTO #MultCustAdd
	--FROM Customer C 
	--INNER JOIN CustomerAddress CA ON C.CustKey=CA.CustKey
	--WHERE CA.AddrType IS NULL	
	--GROUP BY C.CustKey
	--HAVING COUNT(CA.AddrKey)>1

	--SELECT	
	--	 C.Custkey, C.Custid, C.CustName,
	--	 isnull(z.AddrKey,0) as AddrKey,
	--	 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
	--	 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'')AS State,
	--	 ISNULL(Z.ZipCode,'') AS ZipCode
	--	 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
	--	 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax,
	--	 S.StatusName, C.StatusKey,
	--	 CASE WHEN M.CustKey IS NULL THEN C.CustName ELSE C.CustName+' - '+  ISNULL(Z.Address1,'') END AS CustAddrName,
	--	 ISNULL(C.CreditLimit,0) AS CreditLimit, C.CreditStatus, ISNULL(C.Ach_Required,0) AS Ach_Required,ISNULL(C.CreditCheck,0)	AS CreditCheck
	--FROM dbo.Customer C 
	--	 INNER JOIN CustomerAddress CA ON CA.CustKey=C.CustKey
	--	INNER JOIN [Address] Z ON Z.AddrKey=CA.AddrKey
	--	INNER JOIN [Status] S ON S.Statuskey=C.StatusKey 
	--	LEFT JOIN [PaymentTerms] PT on C.PaymentTermsKey = PT.PaymentTermsKey
	--	LEFT JOIN #MultCustAdd M ON M.CustKey=C.CustKey
	--	WHERE S.StatusName='Active' AND CA.AddrType IS NULL	
	--ORDER BY CustName,AddrName;

	SELECT	
		 C.Custkey, C.Custid, C.CustName,
		 isnull(z.AddrKey,0) as AddrKey,
		 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
		 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'')AS State,
		 ISNULL(Z.ZipCode,'') AS ZipCode
		 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
		 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax,
		 S.StatusName, C.StatusKey,  ISNULL(C.CustName,'') AS  CustAddrName ,
		 --CASE WHEN CA.CustKey IS NULL THEN C.CustName ELSE C.CustName+' - '+  ISNULL(Z.Address1,'') END AS CustAddrName,
		 ISNULL(C.CreditLimit,0) AS CreditLimit, C.CreditStatus, ISNULL(C.Ach_Required,0) AS Ach_Required,ISNULL(C.CreditCheck,0)	AS CreditCheck,
		 isnull(C.IsFactored,0) as IsFactored
	FROM dbo.Customer C WITH(NOLOCK)
		-- INNER JOIN CustomerAddress CA ON CA.CustKey=C.CustKey
		INNER JOIN [Address] Z WITH(NOLOCK) ON Z.AddrKey=C.AddrKey
		INNER JOIN [Status] S WITH(NOLOCK) ON S.Statuskey=C.StatusKey 
		LEFT JOIN [PaymentTerms] PT WITH(NOLOCK) on C.PaymentTermsKey = PT.PaymentTermsKey
		
		WHERE S.StatusName='Active' --AND CA.AddrType IS NULL	
	ORDER BY CustName,AddrName
FOR JSON PATH;


	SET @Status = 1
	SET @Reason = 'Success'
END;

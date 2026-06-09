CREATE PROCEDURE [dbo].[Get_IntegrationAPICallLog]
(
	@CustKey	INT=0,
	@SiteID		VARCHAR(20)=''
)
AS
BEGIN
	SELECT IA.CustKey, C.CustID + ' - '+C.CustName As CustName, 
	(ISNULL(A.AddrName,'') +CHAR(10)+CHAR(13) +ISNULL(A.Address1,'') + CHAR(10)+CHAR(13)+ISNULL(A.Address2,'')
	+CHAR(10)+CHAR(13)+ISNULL(City,'')+CHAR(10)+CHAR(13)+ISNULL(ZipCode,'')+CHAR(10)+CHAR(13)+ISNULL([State],'')+CHAR(10)+CHAR(13)+ISNULL(Country,'') ) AS FullAddress,
		   AddressKey, RequestString, RepsonseString, ExceptionString, RequestSentAt,
		   ResponseReceivedAt, ExceptionOccuredAt, SiteID, IsAddrUpdate, IsCustomer, IA.UserKey,U.UserName
	FROM IntegrationApiCall_Log IA
	LEFT JOIN Customer C WITH (NOLOCK) ON C.CustKey=IA.CustKey
	LEFT JOIN Address A WITH (NOLOCK) ON A.AddrKey=IA.AddressKey
	LEFT JOIN [User] U WITH (NOLOCK) ON IA.UserKey=U.UserKey
	WHERE (ISNULL(@CustKey,0)=0 OR IA.CustKey=@CustKey) 
		  AND (ISNULL(@SiteID,'')='' OR SiteID=@SiteID)
	ORDER BY RequestSentAt DESC
END

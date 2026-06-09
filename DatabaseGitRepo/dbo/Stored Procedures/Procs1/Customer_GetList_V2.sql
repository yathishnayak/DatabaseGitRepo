/*
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [Customer_GetList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[Customer_GetList_V2]
(
	@UserKey    INT = 0,
	@JSONString NVARCHAR(MAX) = '',
	@Status     BIT = 0 OUTPUT,
	@Reason     VARCHAR(1000) = '' OUTPUT

)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

	--DECLARE @MarketLocationKey	INT=0
	--SELECT  @MarketLocationKey = Marketlocationkey
	--FROM OPENJSON(@JSONString,'$')
	--WITH (
	--	Marketlocationkey		INT		'$.Marketlocationkey'
	--	)

   Select
	c.CustKey CustomerKey, CustID AS CustId, CustName, c.AddrKey, C.CreateDate, CustomerGroup, S.StatusName, Ach_Required,
	BillToAddrKey, C.Notes, C.PaymentTermsKey,C.StatusKey, C.IsActive, C.IsDelete
	,c.StatusDate, CreditCheck, CreditLimit, CreditStatus,P.PaymentTermsID AS paymenttermsDescription, IsFactored,
	C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey,
	a1.AddrName as A1_AddrName,
	a1.Address1 A1_Address1,
	a1.Address2 A1_Address2,
	a1.City A1_City,
	a1.State A1_State ,
	a1.ZipCode A1_ZipCode,
	a1.Country A1_Country,
	a1.Website A1_Website,
	a1.Phone A1_Phone,
	a1.Email A1_Email,
	a1.Fax A1_Fax,
	a1.Phone2 A1_Phone2,
	a1.Email2 A1_Email2,
	a1.CityKey A1_CityKey, 
	Ca1.AddrType A1_AddrType,
	a2.AddrName as A2_AddrName,
	a2.Address1 A2_Address1,
	a2.Address2 A2_Address2,
	a2.City A2_City,
	a2.State A2_State ,
	a2.ZipCode A2_ZipCode,
	a2.Country A2_Country,
	a2.Website A2_Website,
	a2.Phone A2_Phone,
	a2.Email A2_Email,
	a2.Fax A2_Fax,
	a2.Phone2 A2_Phone2,
	a2.Email2 A2_Email2,
	a2.CityKey A2_CityKey, 
	Ca2.AddrType A2_AddrType,
	C.MarketLocationKey,
	ML.MarketLocation,
	ISNULL(C.MasterCustKey,0) MasterCustKey,
	C.IsMaster,MasterCustID=(SELECT ISNULL(CustID,'N/A') FROM Customer WITH (NOLOCK) WHERE CustKey=ISNULL(C.MasterCustKey,0))
	FROM dbo.Customer C  with ( NOLOCK) 
	LEFT JOIN PaymentTerms P  with ( NOLOCK)  ON P.PaymentTermsKey=C.PaymentTermsKey
	LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
	LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
	Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
	Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
	LEft join Address A1 WITH (NOLOCK) ON C.AddrKey = A1.AddrKey
	leFT JOIN CustomerAddress CA1 with (nolock) on C.AddrKey = CA1.AddrKey and C.CustKey = CA1.CustKey
	LEft join Address A2 WITH (NOLOCK) ON C.AddrKey = A2.AddrKey
	leFT JOIN CustomerAddress CA2 with (nolock) on C.AddrKey = CA2.AddrKey and C.CustKey = CA2.CustKey
	LEFT join MarketLocation ML WITH (NOLOCK) ON C.MarketLocationKey = ML.MarketLocationKey
	WHERE ISNULL(C.IsActive,1)=1 AND ISNULL(C.IsDelete,0)=0 
	--AND	(@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.MarketLocationKey,0) END = @marketLocationKey)
	--AND ISNULL(C.MarketLocationKey,0)=0
	ORDER BY CustName

	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';

END

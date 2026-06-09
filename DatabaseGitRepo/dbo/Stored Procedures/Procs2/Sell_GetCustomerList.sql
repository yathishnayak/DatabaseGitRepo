CREATE PROCEDURE [dbo].[Sell_GetCustomerList]
(
	@Type	VARCHAR(100)=''
)
AS
BEGIN
	IF(@Type='1')
	BEGIN
		SELECT Distinct ISNULL(C.CustId,'') CustId,A.CustName, ISNULL(C.CustKey,0) CustKey  
		FROM SELL_NAC_Accessorial_FinalDataOutput A
		LEFT JOIN Customer C WITH (NOLOCK) ON A.CustName=C.CustName
		FOR JSON PATH
	END
	ELSE
	BEGIN
		SELECT Distinct ISNULL(C.CustId,'') CustId,A.CustName, ISNULL(C.CustKey,0) CustKey 
		FROM SELL_NAC_DrayBase_FinalDataOutput A
		LEFT JOIN Customer C WITH (NOLOCK) ON A.CustName=C.CustName
		FOR JSON PATH
	END
END

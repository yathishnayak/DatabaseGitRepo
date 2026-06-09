CREATE PROCEDURE [dbo].[Get_PickDelAdressByOrderDetailKey]
@OrderDetailKey	INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT 
		SR.AddrKey AS S_AddressKey,SR.AddrName AS S_AddrName,SR.Address1 AS S_Address1,SR.City AS S_City,SR.[State] AS S_State,SR.ZipCode AS S_ZipCode,SR.Country AS S_Country,
		DT.AddrKey AS D_AddressKey ,DT.AddrName AS D_AddrName,DT.Address1 AS D_Address1,DT.City AS D_City,DT.[State] AS D_State,DT.ZipCode AS D_ZipCode,DT.Country AS D_Country
	FROM dbo.OrderDetail OD 
		INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=OD.OrderKey
		LEFT JOIN dbo.[Address] SR ON SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN dbo.[Address] DT ON DT.AddrKey=OH.DestinationAddrKey
	WHERE OrderDetailKey= @OrderDetailKey;
END

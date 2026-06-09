
CREATE PROCEDURE [dbo].[GetBillNonBill]
AS
BEGIN
	SELECT BillNonBillKey,BillNaonBillValue FROM SellDB_BillNonBill FOR JSON PATH;
END

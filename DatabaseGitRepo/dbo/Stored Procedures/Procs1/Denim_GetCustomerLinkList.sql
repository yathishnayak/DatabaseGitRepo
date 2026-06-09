CREATE PROCEDURE [dbo].[Denim_GetCustomerLinkList]
(
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET @Status =1
	SET @Reason ='Success' 

	SELECT Cust.CustID, Cust.CustName,Cust.CustKey, DCD.FromDate, DCD.PaymentMethod,
	addr.AddrName, addr.Address1, addr.Address2, addr.City, addr.State, addr.Country, addr.ZipCode, addr.Phone , addr.email, addr.Website
	FROM Denim_CustLinkDetails DCD WITH (NOLOCK)
	INNER JOIN Customer cust on cust.CustKey = DCD.CustKey
	INNER JOIN address addr on addr.AddrKey = cust.BillToAddrKey
	WHERE ISNULL(cust.IsFactored, 0) = 1
	
	FOR JSON PATH
END

--select  top 3 * from customer
--select top 3 * from address



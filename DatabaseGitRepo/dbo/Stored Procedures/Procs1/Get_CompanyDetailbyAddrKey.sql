CREATE PROCEDURE [dbo].[Get_CompanyDetailbyAddrKey]
@AddrKey INT
AS
BEGIN 
	SELECT Companykey,CompanyID,CompanyName,AddrKey
	FROM Company WHERE AddrKey=@AddrKey
END

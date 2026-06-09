CREATE PROCEDURE [dbo].[Get_CustomerBaseRate]
@CustKey INT
As
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Custkey,BaseRate,EffectiveDate 
	FROM CustomerBaseRate 
	WHERE Custkey=@CustKey AND IsActive=1
END

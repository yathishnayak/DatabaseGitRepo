CREATE PROCEDURE [dbo].[Get_LocationForCustomer] -- [Get_LocationForCustomer] 15
(
	@CustKey	int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Country,[State],City, ZipCode, A.CityKey, isnull(convert(varchar, R.effectiveDate,101),'NA') as effectiveDate
	FROM dbo.LocationData A 
		INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
		LEft join Customer C on C.CustKey = @CustKey
		LEft join 
		(Select Customerkey, CityKey, MAX(effectiveDate) as effectiveDate 
		 from  CustomerItemRate
		 where CustomerKey = @CustKey
		 group by Customerkey, CityKey
		) R on R.CustomerKey = @CustKey and A.CityKey = R.CityKey
	WHERE S.StatusName='Active';
END

CREATE PROCEDURE [dbo].[Get_DriverDetail]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DriverKey, DriverID, FirstName, LastName, AddrKey, CarrierKey, DrivingLicenseNo
		,DrivingLicenseExpiryDate, D.CreateDate, S.StatusName, VendKey
		,CAST(LEFT(DriverID,charindex('-',DriverID)-1) AS INT) AS DriverID1 INTO #tempDriver
	FROM dbo.Driver D 
		LEFT JOIN [Status] S ON S.StatusKey=D.StatusKey
	WHERE S.StatusName='ACTIVE';

	SELECT DriverKey,DriverID, FirstName, LastName, AddrKey, CarrierKey, DrivingLicenseNo
		  ,DrivingLicenseExpiryDate, CreateDate, StatusName, VendKey
	FROM #tempDriver
	ORDER BY DriverID1;
END;


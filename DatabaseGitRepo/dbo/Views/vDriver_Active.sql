CREATE VIEW vDriver_Active
AS
SELECT * FROM (
select DriverKey, StatusKey,PayTypeKey,DriverID,CompanyKey,CreateDate,FirstName,LastName, 
AddrKey,IsActive,IsDelete,CarrierKey,DrivingLicenseNo,DrivingLicenseExpiryDate,
StatusDate,VendKey,HireDate,Plate,YearMake,VINId,RFID,ContactNo,OrgName,OrgZipCode,
FuelCardNo,OrgCity,OrgState,OrgCountry,TruckTypeKey,MarketLocationKey,
ROW_NUMBER() OVER(Partition by cellnumber Order by DriverKey) as Row_num from driver d 
where ISNULL(D.IsActive,1)=1 AND ISNULL(D.IsDelete,0)=0 and statuskey=1 --and CellNumber='310-803-6714'
)A WHERE Row_num=1
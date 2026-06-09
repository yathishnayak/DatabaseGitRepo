
CREATE Procedure [dbo].[Get_DriverVoucherDeduction]
@DriverVocherKey int 
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Select  DVD.DriverVoucherKey, DVD.DriverVoucherNumber, DVD.DriverVoucherdate, DVD.WeekNumber, 
		DVD.DriverKey,
		D.DriverID, isnull(D.FirstName,'') + ' '+ isnull(D.LastName,'') as [Name],  
		DVD.DriverVoucherAmount, D.DrivingLicenseNo, D.DrivingLicenseExpiryDate,
		DVD.PaymentApprover, DVD.CreateUser, DVD.UpdateUser,
		ISNULL(IsRecurring,0) as IsRecurring
	from DriverVoucherDeduction DVD
	Left Join Driver D on D.DriverKey = DVD.DriverKey
	Where DVD.DriverVoucherKey = @DriverVocherKey
END

/**
DECLARE @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 
exec [DA_GetDevicePendingApproval] @UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
select @JSONOutput
**/
CREATE PROCEDURE [dbo].[DA_GetDevicePendingApproval]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS 
BEGIN
	SET @Status=1;
	SET @Reason='SUCCESS';
	SET @JSONOutput = (
		SELECT 
			Dri.CellNumber											AS MobileNo,
			U.UserName												AS UserName,
			Dri.DriverID											AS DriverID,
			ISNULL(Dri.FirstName,'')+' '+ISNULL(Dri.LastName,'')	AS DriverName,
			D.CreatedDate											AS CreatedDate,
			CASE 
				WHEN DD.SystemName = 'IOS' THEN DD.SystemName 
				ELSE DD.Brand 
			END														AS DeviceInfo,
			D.IsApproved											AS IsApproved,
			D.UserKey												AS UserKey,
			D.DeviceKey												AS DeviceKey,
			DeviceDetails = (
				SELECT 
					--Dinfo.DeviceKey,
					Dinfo.UniqueID,
					Dinfo.Model,
					Dinfo.DeviceName,
					Dinfo.Brand,
					Dinfo.HardWare,
					Dinfo.DeviceProduct,
					Dinfo.DeviceVersion,
					Dinfo.Manufacturer,
					Dinfo.AndroidSDK,
					Dinfo.Machine,
					Dinfo.SystemName,
					Dinfo.LocalizedModel,
					Dinfo.CreatedDate
				FROM DA_DeviceDetails Dinfo  WITH (NOLOCK)
				WHERE D.DeviceKey = Dinfo.DeviceKey 
				FOR JSON PATH 
			)
		FROM DA_UserDeviceDetails D WITH (NOLOCK)
			INNER JOIN [User] U		WITH (NOLOCK) ON U.UserKey = D.UserKey
			INNER JOIN Driver Dri	WITH (NOLOCK) ON Dri.DriverKey = D.DriverKey
			INNER JOIN DA_DeviceDetails DD WITH (NOLOCK) ON D.DeviceKey = DD.DeviceKey
		--WHERE D.IsApproved = 0
		FOR JSON PATH
	)
	SELECT ISNULL(@JSONOutput,'')
END
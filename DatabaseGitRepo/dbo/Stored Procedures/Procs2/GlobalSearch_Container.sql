/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"ContainerNo":"CMAU5359390"}]' 
Exec GlobalSearch_Container @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[GlobalSearch_Container]
(
	@UserKey	 INT = 0,
	@JSONString  NVARCHAR(MAX) = '',
	@Status      BIT = 0 OUTPUT,
	@Reason		 VARCHAR(100) = '' OUTPUT,
	@IsDebug     BIT = 0
)AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @ContainerNo VARCHAR(50);

	IF(@IsDebug = 1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	END

	SELECT @ContainerNo = ContainerNo
	FROM OPENJSON(@JSONString, '$')
	WITH ( ContainerNo	VARCHAR(50)	 '$.ContainerNo' )
	  
	IF(ISNULL(@ContainerNo, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'filter is null'
		Print @Reason
	  RETURN
	END
	
	SELECT  OH.OrderKey,OH.OrderNo,OD.OrderDetailKey,ContainerNo,OD.[Weight],CS.[Description] AS ContainerSize,OD.LinkedContainerNo,CU.UserName AS CreatedUsedName,OD.CreateDate,
	       CsrName,CustName,SL.LineName AS SteamShipLine,MB.MBL_number, 
		   CAST(ISNULL(GI.Vessel_eta_dt,Gnosis_vessel_eta_dt) AS DATETIME)Vessel_eta_dt,
		   CAST(GI.Vessel_ata_dt  AS DATETIME)Vessel_ata_dt,
		   CAST(GI.Last_free_demurrage_day_dt AS DATETIME) Last_free_demurrage_day_dt,
		   CAST(GI.Available_dt AS DATETIME) Available_dt,
	        
	       STUFF((
				SELECT ',' + CT.TypeID
				FROM ContainerTypesLink	CTL	WITH (NOLOCK)	
							LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
							WHERE OD.OrderDetailKey = CTL.OrderDetailKey
						 
				FOR XML PATH('')
               ), 1, 1, '') AS Properties,
		VoucherInfo =(
			SELECT VH.VoucherKey,VoucherNo
					FROM [Routes] R WITH (NOLOCK)
					INNER JOIN RouteVouchers RV WITH (NOLOCK) ON RV.RouteKey=R.RouteKey
					INNER JOIN  VoucherHeader VH WITH(NOLOCK)  ON VH.Voucherkey = RV.VoucherKey							
					WHERE OD.OrderDetailKey = R.OrderDetailKey
					FOR JSON PATH
	    ) , 
	   InvoiceInfo =(
			SELECT IH.InvoiceKey,InvoiceNo
		    FROM  InvoiceHeader IH WITH (NOLOCK)						
			WHERE  IH.OrderKey =  OH.OrderKey
			FOR JSON PATH
	   ),
	StopInfo=(
		SELECT OrderDetailKey,ODS.StopTypeKey,SM.StopTypeName,ODS.ActualPickupDate,ActualDeliveryDate,SM.StopTypeShortcode,ODS.LocationType,AddrName,Address1,City,State,ZipCode
		FROM OrderDetailStops ODS WITH (NOLOCK)
		LEFT JOIN Address A WITH(NOLOCK) ON A.AddrKey = ODS.StopAddrKey
		LEFT JOIN StopsMaster SM WITH(NOLOCK) ON SM.StopTypeKey = ODS.StopTypeKey
		WHERE ODS.OrderDetailKey =  OD.OrderDetailKey --AND SM.StopTypeKey IN(1,3,5)    
		FOR JSON PATH
		),
	--RoutesInfo =(
	--	SELECT RouteKey,CarrierAssignedBy,UserName AS Dispatchers,ChassisNo
	--	FROM [Routes] RT 
	--	LEFT JOIN  [User] CA WITH(NOLOCK) ON CA.UserKey = CarrierAssignedBy
	--	WHERE  OD.OrderDetailKey= RT.OrderDetailKey
	--    FOR JSON PATH
	--),

	ChassisInfo =(
		SELECT distinct ChassisNo
		FROM [Routes] RT WITH (NOLOCK) 		
		WHERE  OD.OrderDetailKey= RT.OrderDetailKey
	    FOR JSON PATH
	),
	DispatcherInfo =(
		SELECT distinct UserName AS Dispatchers
		FROM [Routes] RT WITH (NOLOCK) 
		LEFT JOIN  [User] CA WITH(NOLOCK) ON CA.UserKey = CarrierAssignedBy
		WHERE  OD.OrderDetailKey= RT.OrderDetailKey
	    FOR JSON PATH
	)
	FROM  OrderDetail  OD WITH (NOLOCK)  
	INNER JOIN OrderHeader OH WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
	LEFT JOIN Gnosis_Integration_Container_Final GI WITH(NOLOCK) ON GI.OrderDetailKey = OD.OrderDetailKey
	LEFT JOIN Gnosis_Integration_MBL_FINAL MB  WITH (NOLOCK) ON GI.UUID = MB.UUID
	LEFT JOIN ContainerSize CS WITH(NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey
	LEFT JOIN CSR C WITH(NOLOCK) ON C.CsrKey = OH.CsrKey
	LEFT JOIN Customer CT WITH(NOLOCK) ON CT.CustKey = OH.CustKey
	LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON  SL.LineKey = OH.SteamShipLinekey
	LEFT JOIN [User] CU WITH(NOLOCK) ON CU.UserKey = OD.CreateUserKey  
	WHERE OD.ContainerNo LIKE '%' + @ContainerNo + '%'
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END

--SELECT * FROM OrderDetailStops WHERE OrderDetailKey = 168685
--SELECT * FROM StopsMaster
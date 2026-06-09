/*
declare @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 ,
	@Reason			varchar(1000) = '' 
	exec Denim_GetInvoicedetailsForSending @UserKey,@JsonString,@Status output,@Reason Output
	select @Status, @Reason
	*/

CREATE PROCEDURE [dbo].[Denim_GetInvoicedetailsForSending]
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

	SELECT  top 1
    IH.InvoiceKey,
    IH.InvoiceNo,
    IH.CustKey,
    IH.InvoiceDate,
	IH.DueDate,
	OD.Weight,
	--ISNULL(WU.WeightUnit,'') WeightUnit,
    InvoiceItem = (
        SELECT I.ItemId,I.Description [Type],I.InvoiceItemDesc,ExtAmt,ID.Description
        FROM  
		(SELECT IDI.ItemKey,IDI.Description,IDI.ExtAmt
		FROM Invoicedetail IDI WITH (NOLOCK) WHERE IDI.InvoiceKey = IH.InvoiceKey) ID 
		INNER JOIN Item I ON I.ItemKey=ID.ItemKey        
        FOR JSON PATH
    ),
	Documents = (
        SELECT OriginalFileName,OriginalFileType,FilePath
        FROM (SELECT DocumentKey FROM OrderDetailDocuments ODDI WHERE ODDI.OrderDetailKey=ID.OrderDetailKey) ODD 
			LEFT JOIN Document D ON D.DocumentKey=ODD.DocumentKey AND D.DocumentType in (2,15,16)
			--WHERE ODD.OrderDetailKey=ID.OrderDetailKey
        FOR JSON PATH
    ),
	ODS_StpP.ActualPickupDate,
	ODS_StpP.SchedulePickupDate,
	ODS_StpP.SchedulePickupDateTo,
	ODS_StpD.ActualDeliveryDate,
	ODS_StpD.ScheduleDeliveryDate,
	ODS_StpD.ScheduleDeliveryDateTo,

	ODS_StpP.LocationType PickupLocation,
	ODS_StpD.LocationType DeliveryLocation,

	PA.AddrName PickupAddress, PA.Address1 PickupAddress1,
	PA.Address2 PickupAddress2,PA.City PickupCity,PA.State  PickupState,PA.Country  PickupCountry,PA.ZipCode  PickupZip,

	DA.AddrName  DeliveryAddress, DA.Address1 DeliveryAddress1,
	DA.Address2 DeliveryAddress2,DA.City DeliveryCity,DA.State DeliveryState,DA.Country DeliveryCountry,DA.ZipCode DeliveryZip

	FROM dbo.InvoiceHeader IH WITH (NOLOCK)
	OUTER APPLY (
						SELECT TOP 1 Orderdetailkey
						FROM Invoicedetail IDI WITH (NOLOCK)
						WHERE IDI.InvoiceKey = IH.InvoiceKey
						) ID 
	OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODS WITH (NOLOCK)
						WHERE ODS.OrderDetailKey = ID.OrderDetailKey
						  AND ODS.StopTypeKey = 1 AND ISNULL(ISDRYRUNPort,0)=0 AND ISNULL(ISDRYRUNCustomer,0)=0 
						) ODS_StpP 
	OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODS WITH (NOLOCK)
						WHERE ODS.OrderDetailKey = ID.OrderDetailKey
						  AND ODS.StopTypeKey = 3 AND ISNULL(ISDRYRUNPort,0)=0 AND ISNULL(ISDRYRUNCustomer,0)=0 
						) ODS_StpD 
	INNER JOIN Address PA ON PA.AddrKey=ODS_StpP.StopAddrKey
	INNER JOIN Address DA ON DA.AddrKey=ODS_StpP.StopAddrKey
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=ID.OrderDetailKey AND ISNUMERIC(OD.WeightUnit)=1
	LEFT JOIN weighunit WU ON WU.WeightUnitKey=OD.WeightUnit 
	WHERE 
    IsInvoiceApproved = 1
    AND DATEDIFF(MINUTE, InvoiceApprovedDate, GETDATE()) >= 30	
	FOR JSON PATH

END



	

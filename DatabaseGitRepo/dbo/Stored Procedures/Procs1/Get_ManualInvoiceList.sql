CREATE Proc [dbo].[Get_ManualInvoiceList] -- exec [Get_ManualInvoiceList] @MInvoiceNo = 'M-1234', @ContainerNo = 'AAAA1234567'
(
	@CustomerKey	int = 0,
	@MInvoiceNo		varchar(50) = '',
	@StatusKey			int = 0, -- // 0 : All, 1 : Open, 2: Send, 3 : Confirmed
	@DateFrom		datetime = '2000-01-01',
	@DateTo			Datetime = '2050-12-31',
	@ContainerNo	varchar(20) = '',
	@SteamShipLineKey	int = 0, 
	@SteamShipLineRef	varchar(100) = '',
	@UserKey			int = 0
)
AS
BEGIN
	Select * from (
	Select H.MInvoiceKey,
		MInvoiceNo,
		MInvoiceDate, 
		MInvoiceAmount, 
		CustomerKey, 
		BillToAddressKey, 
		H.OrderKey,
		MInvoiceSentDate, 
		MInvoiceConfirmDate, 
		isnull(U.UserName,'NA') UserName,
		C.CustName,
		C.CustID,
		A.AddrName,
		A.City,
		A.State, 
		A.ZipCode,
		A.Country,
		h.OrderNo,
		OH.OrderDate,
		isnull(H.StatusKey,1) StatusKey,
		Case when  isnull(H.statusKey,0) = 1 then 'Open'
			 when H.StatusKey = 2 then 'Sent'
			 when H.StatusKey = 3 then 'Confirmed' 
			 when H.StatusKey = 4 then 'Void'
			 else '' end as StatusName,
		H.InternalNotes,
		H.CustomerNotes,
		H.BrokerRef,
		UV.UserName AS VoidUser,
		h.VoidedDate as VoidDate,
		IsFound,
		H.SteamShipLineKey, SteamShipLineRef, SL.LineName AS SteamShipLineName,
		isnull(H.UpdatedUserKey,H.CreatedUserKey) as LastUpdatedUser,
		isnull(UU.UserName,'') as LastUpdatedUserName,
		h.OriginalInvoiceNo,ContainerNo

	from ManualInvoiceHeader H WITH (NOLOCK) 
	LEft join OrderHeader OH WITH (Nolock) on H.orderKey = OH.orderKey
	--LEft join [User] U WITH (NOLOCK)  on isnull(H.UpdatedUserKey,H.CreatedUserKey) = U.UserKey
	LEft join [User] U WITH (NOLOCK)  on H.CreatedUserKey = U.UserKey
	Left join [User] UV with (NOLOCK) ON ISNULL(h.VoidedUserKey,0) = UV.UserKey
	Left join [User] UU with (NOLOCK) ON ISNULL(h.UpdatedUserKey,0) = UU.UserKey--added for updated username
	LEFT join [Customer] C WITH (NOLOCK)  on H.CustomerKey = C.CustKey
	Left join [Address] A WITH (NOLOCK)  on H.BillToAddressKey = A.AddrKey
	Left join [SteamShipLine] SL WITH (NOLOCK) ON H.SteamShipLineKey = SL.LineKey
	Left Join (
		select distinct IH.MInvoiceKey,ContainerNo= STUFF(
                 (SELECT ',' + ContainerNo FROM ManualInvoiceDetail MID
				 WHERE MID.MInvoiceKey=IH.MInvoiceKey
				 FOR XML PATH ('')), 1, 1, ''
               ),
			   case when ContainerNo like '%' + @ContainerNo + '%' then 1 else 0 end as IsFound  
		from ManualInvoiceDetail ID with (nolock)
		inner join ManualInvoiceHeader IH with (nolock) on  id.MInvoiceKey = ih.MInvoiceKey
		where ContainerNo like '%' + @ContainerNo + '%'
		GROUP BY IH.MInvoiceKey,ContainerNo
		) CO on H.MInvoiceKey = CO.MInvoiceKey
	) A
	where 
		(isnull(@CustomerKey,0) = 0 OR CustomerKey = @CustomerKey  ) and
		(isnull(@MInvoiceNo,'') = '' OR MInvoiceNo = @MInvoiceNo) and
		--(isnull(@StatusKey,0) = 0 OR A.StatusKey = @StatusKey ) and
		(ISNULL(@DateFrom,convert(date, '2022-01-01')) = convert(date, '2022-01-01') OR @DateFrom <= MInvoiceDate) AND
		(ISNULL(@DateTo, convert(date, '2050-12-31')) = convert(Date, '2050-12-31') OR @DateTo >= MInvoiceDate ) AND
		(isnull(@ContainerNo,'') = '' OR IsFound = 1 ) and
		(isnull(@SteamShipLineKey,0) = 0 or A.SteamShipLineKey = @SteamShipLineKey) and
		(isnull(@SteamShipLineRef,'') = '' OR A.SteamShipLineRef like '%' + @SteamShipLineRef + '%') and
		(isnull(@UserKey,0) = 0 OR  A.LastUpdatedUser = @UserKey)
END

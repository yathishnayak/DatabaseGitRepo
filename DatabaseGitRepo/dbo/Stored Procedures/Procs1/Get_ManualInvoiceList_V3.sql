/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX)= '{"CustKey" : 0, "MInvoiceNo" : "", "StatusKey" : 1, "DateFrom" : "2000-01-01T00:00:00.000Z", "DateTo" : "2050-12-31T00:00:00.000Z", "ContainerNo" : "", "SteamShipLineKey" : 21, "SteamShipLineRef" : ""}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ManualInvoiceList_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX)= '{"SteamShipLineKey" : 31, "StatusKey" : 1}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ManualInvoiceList_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[Get_ManualInvoiceList_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@CustomerKey		INT = 0,
		@MInvoiceNo			VARCHAR(50) = '',
		@StatusKey			INT = 0, -- // 0 : All, 1 : Open, 2: Send, 3 : Confirmed
		@DateFrom			DATETIME = '2000-01-01',
		@DateTo				DATETIME = '2050-12-31',
		@ContainerNo		VARCHAR(20) = '',
		@SteamShipLineKey	INT = 0, 
		@SteamShipLineRef	VARCHAR(100) = '',
		@SelectedUserKey	INT	= 0

	SELECT 
		@CustomerKey		= CustomerKey		,
		@MInvoiceNo			= MInvoiceNo		,	
		@StatusKey			= StatusKey			,	
		@DateFrom			= DateFrom			,	
		@DateTo				= DateTo			,	
		@ContainerNo		= ContainerNo		,
		@SteamShipLineKey	= SteamShipLineKey	,	
		@SteamShipLineRef	= SteamShipLineRef	,
		@SelectedUserKey	= SelectedUserKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustomerKey			INT				'$.CustKey'				,
		MInvoiceNo			VARCHAR(50)		'$.MInvoiceNo'			,	
		StatusKey			INT				'$.StatusKey'			,	
		DateFrom			DATETIME		'$.DateFrom'			,
		DateTo				DATETIME		'$.DateTo'				,	
		ContainerNo			VARCHAR(20)		'$.ContainerNo'			,
		SteamShipLineKey	INT				'$.SteamShipLineKey'	,
		SteamShipLineRef	VARCHAR(100)	'$.SteamShipLineRef'	,
		SelectedUserKey		INT				'$.UserKey'
	)

	SELECT 
		@CustomerKey		= ISNULL(@CustomerKey, 0),
		@MInvoiceNo			= ISNULL(@MInvoiceNo, ''),
		@StatusKey			= ISNULL(@StatusKey, 0),
		@DateFrom			= ISNULL(@DateFrom, '2000-01-01'),
		@DateTo				= ISNULL(@DateTo, '2050-12-31'),
		@ContainerNo		= ISNULL(@ContainerNo, ''),
		@SteamShipLineKey	= ISNULL(@SteamShipLineKey, 0),
		@SteamShipLineRef	= ISNULL(@SteamShipLineRef, ''),
		@SelectedUserKey	= ISNULL(@SelectedUserKey, 0)

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
	LEft join [User] U WITH (NOLOCK) on H.CreatedUserKey = U.UserKey
	Left join [User] UV with (NOLOCK) ON ISNULL(h.VoidedUserKey,0) = UV.UserKey
	Left join [User] UU with (NOLOCK) ON ISNULL(h.UpdatedUserKey,0) = UU.UserKey
	LEFT join [Customer] C WITH (NOLOCK) on H.CustomerKey = C.CustKey
	Left join [Address] A WITH (NOLOCK) on H.BillToAddressKey = A.AddrKey
	Left join [SteamShipLine] SL WITH (NOLOCK) ON H.SteamShipLineKey = SL.LineKey
	Left Join (
		select distinct IH.MInvoiceKey,ContainerNo= STUFF(
                 (SELECT ',' + ContainerNo FROM ManualInvoiceDetail MID
				 WHERE MID.MInvoiceKey=IH.MInvoiceKey
				 FOR XML PATH ('')), 1, 1, ''
               ),
			   case when ContainerNo like '%' + @ContainerNo + '%' then 1 else 0 end as IsFound  
		from ManualInvoiceDetail ID with (nolock)
		inner join ManualInvoiceHeader IH with (nolock) on id.MInvoiceKey = ih.MInvoiceKey
		where ContainerNo like '%' + @ContainerNo + '%'
		GROUP BY IH.MInvoiceKey,ContainerNo
		) CO on H.MInvoiceKey = CO.MInvoiceKey
	) A
	where 
		(isnull(@CustomerKey,0) = 0 OR CustomerKey = @CustomerKey) and
		(isnull(@MInvoiceNo,'') = '' OR MInvoiceNo = @MInvoiceNo) and
		-- (isnull(@StatusKey,0) = 0 OR A.StatusKey = @StatusKey) and
		(ISNULL(@DateFrom,convert(date, '2022-01-01')) = convert(date, '2022-01-01') OR @DateFrom <= MInvoiceDate) AND
		(ISNULL(@DateTo, convert(date, '2050-12-31')) = convert(Date, '2050-12-31') OR @DateTo >= MInvoiceDate) AND
		(isnull(@ContainerNo,'') = '' OR IsFound = 1) and
		(isnull(@SteamShipLineKey,0) = 0 or A.SteamShipLineKey = @SteamShipLineKey) and
		(isnull(@SteamShipLineRef,'') = '' OR A.SteamShipLineRef like '%' + @SteamShipLineRef + '%') AND
		(isnull(@SelectedUserKey,0) = 0 OR A.LastUpdatedUser = @SelectedUserKey)
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END
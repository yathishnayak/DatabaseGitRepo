/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustKey" : 0, "StatusKey" : 0, "DateFrom" : "2022-01-31T18:30:00.000Z", "DateTo" : "2026-03-31T07:23:29.365Z"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_PrepayInvoiceList_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_PrepayInvoiceList_V3]
(
	@UserKey		INT = 1144,
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
		@CustomerKey	int = 0,
		@StatusKey			int = 0, -- // 0 : All, 1 : Open, 2: Send, 3 : Confirmed
		@DateFrom		datetime = '2022-01-01',
		@DateTo			Datetime = '2050-12-31'

	SELECT 
		@CustomerKey		=	CustomerKey,
		@StatusKey			=	StatusKey,	
		@DateFrom			=	DateFrom,	
		@DateTo				=	DateTo
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustomerKey			INT				'$.CustKey',
		StatusKey			INT				'$.StatusKey',	
		DateFrom			DATETIME		'$.DateFrom',	
		DateTo				DATETIME		'$.DateTo'
	)

	Select * from (
	Select PPInvoiceKey,
		PPInvoiceNo,
		PPInvoiceDate, 
		PPInvoiceAmount, 
		CustomerKey as CustKey, 
		BillToAddressKey, 
		H.OrderKey,
		PPInvoiceSentDate, 
		PPInvoiceConfirmDate, 
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
			 when H.StatusKey = 3 then 'Confirmed' else '' end as StatusName,
		H.InternalNotes,
		H.CustomerNotes
	from PrepayInvoiceHeader H WITH (NOLOCK) 
	LEft join OrderHeader OH WITH (Nolock) on H.orderKey = OH.orderKey
	LEft join [User] U WITH (NOLOCK)  on isnull(H.UpdatedUserKey,H.CreatedUserKey) = U.UserKey
	LEFT join [Customer] C WITH (NOLOCK)  on H.CustomerKey = C.CustKey
	Left join [Address] A WITH (NOLOCK)  on H.BillToAddressKey = A.AddrKey
	) A
	where 
		(isnull(@CustomerKey,0) = 0 OR CustKey = @CustomerKey  ) and
		--(isnull(@StatusKey,0) = 0 OR A.StatusKey = @StatusKey ) and
		(ISNULL(@DateFrom,convert(date, '2022-01-01')) = convert(date, '2022-01-01') OR @DateFrom <= PPInvoiceDate) AND
		(ISNULL(@DateTo, convert(date, '2050-12-31')) = convert(Date, '2050-12-31') OR @DateTo >= PPInvoiceDate )
	FOR JSON PATH
	SET @Status=1
	SET @Reason = 'Success'
END
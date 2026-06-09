/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"StatusCodeKey" : 0, "CustKey" : 2867, "DateFrom" : "2022-01-01", "DateTo" : "2023-09-16", "DestinationCity" : "", "InvoicerKey" : 159575, "CustomerType" : 2, "BillingCompanyKey" : null, "OrderNo" : "" , "OrderDateFrom" : "", "OrderDateTo" : "", "DeliveryDateFrom" : "", "DeliveryDateTo" : "", "ContainerNo" : "", "InvoiceNo" : "", "BOL" : "", "MarketLocationKey" :null , "SearchText" : ""}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CollectionQueue_GetList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CollectionRecordKey":0," CustKey" : 2123, "InvoiceNo":"6933","InvoiceDate":"2023-12-22T00:00:00","CustomerType":false,"ContainerCount":1,"DestinationCity":"Lynwood","BrokerRefNo":"JCB DID NOT TENDER","InvoiceAmount":75,"Payments":75,"Balance":0,"InvoiceKey":45404,"StatusCodeKey":1,"InvoicerKey":331,"IsRevise":false,"Containers":"CMAU4985717"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CollectionQueue_GetList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

-- [CollectionQueue_GetList]  @StatusCodeKey=0 , @DATEFROM = '2022-01-01', @CustomerKey = 0, @DateTo='2023-09-16' ,@CustomerType=2

CREATE PROCEDURE [dbo].[CollectionQueue_GetList_V2] 
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
 BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
		@StatusCodeKey		INT = 0,
		@CustomerKey		INT = 0,
		@DateFrom		    DATETIME = null,
		@DateTo				DATETIME = null,
		@DestinationCity	VARCHAR(100) = '',
		@InvoicerKey        INT = 0,
		@CustomerType       INT = 0,
		@BillingCompanyKey  INT = 0,
		@OrderNo			VARCHAR(100)='',
		@OrderDateFrom		DATETIME = '2020-01-01',
		@OrderDateTo		DATETIME = '2020-01-01',
		@DeliveryDateFrom	DATETIME = '2020-01-01',
		@DeliveryDateTo		DATETIME = '2020-01-01',
		@ContainerNo		VARCHAR(100)='',
		@InvoiceNo			VARCHAR(100)='',
		@BOL				VARCHAR(100)='',
		@MarketLocationKey  INT = 0,
		@SearchText			VARCHAR(100)=''

	SELECT 
		@StatusCodeKey			=		StatusCodeKey		,
		@CustomerKey			=		CustomerKey			,
		@DateFrom		    	=		DateFrom		    ,
		@DateTo					=		DateTo				,
		@DestinationCity		=		DestinationCity		,
		@InvoicerKey        	=		InvoicerKey        	,
		@CustomerType       	=		CustomerType       	,
		@BillingCompanyKey  	=		BillingCompanyKey  	,
		@OrderNo				=		OrderNo				,
		@OrderDateFrom			=		OrderDateFrom		,
		@OrderDateTo			=		OrderDateTo			,
		@DeliveryDateFrom		=		DeliveryDateFrom	,
		@DeliveryDateTo			=		DeliveryDateTo		,
		@ContainerNo			=		ContainerNo			,
		@InvoiceNo				=		InvoiceNo			,
		@BOL					=		BOL					,
		@MarketLocationKey  	=		MarketLocationKey  	,
		@SearchText				=		SearchText			
	FROM OPENJSON(@JSONString)
	WITH
	(
		StatusCodeKey			INT					'$.StatusCodeKey',		
		CustomerKey				INT					'$.CustKey',		
		DateFrom		    	DATETIME			'$.DateFrom',		    
		DateTo					DATETIME			'$.DateTo',				
		DestinationCity			VARCHAR(100)		'$.DestinationCity',	
		InvoicerKey        		INT					'$.InvoicerKey',        
		CustomerType       		INT					'$.CustomerType',       
		BillingCompanyKey  		INT					'$.BillingCompanyKey',  
		OrderNo					VARCHAR(100)		'$.OrderNo',			
		OrderDateFrom			DATETIME			'$.OrderDateFrom',		
		OrderDateTo				DATETIME			'$.OrderDateTo',		
		DeliveryDateFrom		DATETIME			'$.DeliveryDateFrom',	
		DeliveryDateTo			DATETIME			'$.DeliveryDateTo',		
		ContainerNo				VARCHAR(100)		'$.ContainerNo',		
		InvoiceNo				VARCHAR(100)		'$.InvoiceNo',			
		BOL						VARCHAR(100)		'$.BOL',				
		MarketLocationKey  		INT					'$.MarketLocationKey',  
		SearchText				VARCHAR(100)		'$.SearchText'
	)

	--SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateFrom = ISNULL(@DateFrom,'2023-12-01')
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo,GETDATE()))

	DECLARE @IsFactored BIT, @OpenCount INT=0, @ReviewCount INT=0, @PendingCount INT=0, @DeniedCount INT=0, @ApprovedCount INT=0 ,@RevisedCount INT = 0

	IF @CustomerType = 0
		BEGIN
			SET @IsFactored = 0
		END
	IF @CustomerType = 1
		BEGIN
			SET @IsFactored = 1
		END


  IF(@StatusCodeKey = 0 )
   BEGIN
   --PRINT '1'
		SELECT Top 400 CAST(0 AS INT)CollectionRecordKey,H.InvoiceKey,H.InvoiceNo,H.InvoiceDate,c.CustID,c.CustName,
		     c.IsFactored AS CustomerType,ContainerCount,DestinationCity,H.BrokerRefNo,H.InvoiceAmount,
              Payments,Balance,Containers,U.UserName InvoicerName,H.CreateUserKey,	cast(0 as int )StatusCodeKey,
			  H.CreateUserKey as InvoicerKey, c.CustKey AS CustKey,oh.BookingNo,
			  @OpenCount OpenCount, @ReviewCount ReviewCount,@PendingCount PendingCount,
			  @DeniedCount DeniedCount,@ApprovedCount ApprovedCount , @RevisedCount RevisedCount,IRC.ReasonCode
		FROM Data_InvoiceReport  H WITH(NOLOCK)
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = H.CustKey
		INNER JOIN [User] U ON U.UserKey=H.CreateUserKey	
		INNER JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.InvoiceKey=H.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = IH.OrderKey
		LEFT JOIN InvoiceReasonCode IRC WITH (NOLOCK) ON IRC.ReasoncodeKey=IH.ReasoncodeKey
		--INNER JOIN OrderDetail D ON D.OrderKey = OH.OrderKey
		--INNER JOIN OrderDetailStatus OS ON OS.[Status]  =D.[Status]

		WHERE 	
		
		(ISNULL(@CustomerKey,0) = 0 OR H.CustKey =@CustomerKey) AND
		h.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,0) = 0 OR h.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoiceNo,0) = 0 OR h.InvoiceNo = @InvoiceNo) AND 
		--(ISNULL(@CustomerType,2) = 2 OR c.IsFactored = @IsFactored) AND
		(ISNULL(@BillingCompanyKey,0) = 0 OR ih.InvoiceCompanyKey = @BillingCompanyKey) 	AND
		H.InvoiceKey NOT IN (SELECT InvoiceKey FROM CollectionQueue WITH(NOLOCK)) AND   --  WHERE StatusCodeKey<>1
		(ISNULL(@ContainerNo,'') ='' OR @ContainerNo in(H.Containers)) AND
		(ISNULL(@OrderNo,'')='' OR H.OrderNo=@OrderNo) AND
		(ISNULL(@BOL,'')='' OR OH.BillOfLading=@BOL)AND
		(ISNULL(@MarketLocationKey,0)=0 OR OH.MarketLocationKey=@MarketLocationKey)--AND
		--(OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		FOR JSON PATH 
	END

  ELSE 
   BEGIN
		SELECT TOP 400  CollectionRecordKey,Q.InvoiceKey,Q.InvoiceNo,Q.InvoiceDate,C.CustID,C.CustName,C.IsFactored AS CustomerType,ContainerCount,DestinationCity,
		Q.BrokerRefNo,Q.InvoiceAmount,
              Payments,Balance,Containers AS Containers,U.UserName AS InvoicerName,Q.StatusCodeKey,Q.OrderDetailKey,InvoicerKey, C.CustKey AS CustKey,
			  @OpenCount OpenCount, @ReviewCount ReviewCount,@PendingCount PendingCount, OH.BookingNo,
			  @DeniedCount DeniedCount,@ApprovedCount ApprovedCount, @RevisedCount RevisedCount,IRC.ReasonCode
		
		FROM CollectionQueue  Q WITH(NOLOCK) 

		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey
		--LEFT JOIN OrderDetail O WITH(NOLOCK) ON O.OrderDetailKey = Q.OrderDetailKey
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 		LEFT JOIN InvoiceReasonCode IRC WITH (NOLOCK) ON IRC.ReasoncodeKey=H.ReasoncodeKey
		WHERE 
		(ISNULL(@StatusCodeKey,0) = 0 OR S.StatusCodeKey = @StatusCodeKey) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,0) = 0 OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@InvoiceNo,'') = '' OR Q.InvoiceNo = @InvoiceNo) AND 
		--(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND
		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey)AND
		(ISNULL(@ContainerNo,0) = 0 OR @ContainerNo in(Q.Containers)) AND
		(ISNULL(@OrderNo,'')='' OR OH.OrderNo=@OrderNo) AND
		(ISNULL(@BOL,'')='' OR OH.BillOfLading=@BOL)AND
		(ISNULL(@MarketLocationKey,0)=0 OR OH.MarketLocationKey=@MarketLocationKey)--AND
		--(OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		--ORDER BY 
  --  CASE 
  --      WHEN Q.StatusCodeKey = 0 THEN 0 
  --      ELSE 1 
  --  END,
  --  Q.StatusCodeKey
		FOR JSON PATH 
	END
	SET @Status = 1
	SET @Reason = 'Success'
 END

 --SELECT *FROM Data_InvoiceReport
 --select *from CUSTOMER
 --select *from OrderDetail where ContainerNo = 'ASDF0123456' 
 --select *from InvoiceHeader
 --select * from CollectionQueue
--select * from  OrderDetailStatus
--select * from InvoiceStatus
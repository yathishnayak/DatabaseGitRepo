/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"StatusCodeKey" : 1, "CustKey" : 0, "DateFrom" : "", "DateTo" : "", "DestinationCity" : "", "InvoicerKey" : null, "CustomerType" : 2, "BillingCompanyKey" : null}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CollectionQueue_GetCount_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[CollectionQueue_GetCount_V2] -- [CollectionQueue_GetCount]  @StatusCodeKey=1 ,  @CustomerKey = 0, @CustomerType=2
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@StatusCodeKey		INT = 0,
	@CustomerKey		INT = 0,
	@DateFrom		    DATETIME = '2020-01-01',
	@DateTo				DATETIME = '2050-12-31',
	@DestinationCity	VARCHAR(100) = '',
	@InvoicerKey        INT = 0,
	@CustomerType       INT = 0,
	@BillingCompanyKey  INT = 0

	SELECT 
	@StatusCodeKey			=	StatusCodeKey		,
	@CustomerKey			=	CustomerKey			,
	@DateFrom		   		=	DateFrom		   	,
	@DateTo					=	DateTo				,
	@DestinationCity		=	DestinationCity		,
	@InvoicerKey       		=	InvoicerKey       	,
	@CustomerType      		=	CustomerType      	,
	@BillingCompanyKey 		=	BillingCompanyKey 
	FROM OPENJSON(@JSONString)
	WITH
	(
	StatusCodeKey		INT					'$.StatusCodeKey',		
	CustomerKey			INT					'$.CustKey',		
	DateFrom		   	DATETIME			'$.DateFrom',	   
	DateTo				DATETIME			'$.DateTo',				
	DestinationCity		VARCHAR(100)		'$.DestinationCity',	
	InvoicerKey       	INT					'$.InvoicerKey',       
	CustomerType      	INT					'$.CustomerType',      
	BillingCompanyKey 	INT					'$.BillingCompanyKey'
	)


	--SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateFrom = ISNULL(@DateFrom,'2023-12-01')
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo,GETDATE()))

	DECLARE @IsFactored BIT, @OpenCount INT=0, @ReviewCount INT=0, @PendingCount INT=0, @DeniedCount INT=0, @ApprovedCount INT=0 , @RevisedCount INT=0

	IF @CustomerType = 0
		BEGIN
			SET @IsFactored = 0
		END
	IF @CustomerType = 1
		BEGIN
			SET @IsFactored = 1
		END

	SET @OpenCount=(SELECT COUNT(H.InvoiceKey) FROM Data_InvoiceReport  H 
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = H.CustKey
		INNER JOIN [User] U ON U.UserKey=H.CreateUserKey
		INNER JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.InvoiceKey=H.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = IH.OrderKey
	--	INNER JOIN OrderDetail D ON D.OrderKey = OH.OrderKey
	--	INNER JOIN OrderDetailStatus OS ON OS.[Status]  =D.[Status]

		WHERE 	
		--(H.StatusKey IN (1,2,3) OR --H.Description ='Approved' and
		--h.Status in(6,10,12,13,14) )and 
		(ISNULL(@CustomerKey,0) = 0 OR H.CustKey =@CustomerKey) AND
		(h.InvoiceDate BETWEEN @DateFrom AND @DateTo) AND
		(ISNULL(@DestinationCity,'') = '' OR h.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR h.CreateUserKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR c.IsFactored = @IsFactored) AND
		(ISNULL(@BillingCompanyKey,0) = 0 OR ih.InvoiceCompanyKey = @BillingCompanyKey) 	AND
		H.InvoiceKey NOT IN (SELECT InvoiceKey FROM CollectionQueue) )
		
	SET @ReviewCount=(SELECT COUNT(Q.CollectionRecordKey) FROM CollectionQueue  Q 

		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey		
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 	
		WHERE 
		(S.StatusCodeKey = 1) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,'') = '' OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey))

	SET @PendingCount=(SELECT COUNT(Q.CollectionRecordKey) FROM CollectionQueue  Q 

		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey	
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 	
		WHERE 
		(S.StatusCodeKey = 2) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,'') = '' OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey))

	SET @DeniedCount=(SELECT COUNT(Q.CollectionRecordKey) FROM CollectionQueue  Q 

		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey		
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 	
		WHERE 
		(S.StatusCodeKey = 3) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,'') = '' OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND
		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey))

	SET @ApprovedCount=(SELECT COUNT(Q.CollectionRecordKey) FROM CollectionQueue  Q 

		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 	
		WHERE 
		(S.StatusCodeKey = 4) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,'') = '' OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND
		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey))

	SET @RevisedCount = (SELECT COUNT(Q.CollectionRecordKey) FROM CollectionQueue Q

	    INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey		
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
 	
		WHERE 
		(S.StatusCodeKey = 5) AND
		(ISNULL(@CustomerKey,0) = 0 OR Q.CustomerKey =@CustomerKey) AND
		Q.InvoiceDate BETWEEN @DateFrom AND @DateTo AND
		(ISNULL(@DestinationCity,'') = '' OR Q.DestinationCity= @DestinationCity) AND
		(ISNULL(@InvoicerKey,0) = 0 OR Q.InvoicerKey = @InvoicerKey) AND 
		(ISNULL(@CustomerType,2) = 2 OR Q.CustomerType = @IsFactored) AND
		
		(ISNULL(@BillingCompanyKey,0) = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey))


	SELECT @OpenCount OpenCount, @ReviewCount ReviewCount, @PendingCount PendingCount, @DeniedCount DeniedCount, @ApprovedCount ApprovedCount ,@RevisedCount RevisedCount
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status=1
	SET @Reason = 'Success'
  
 END

/*
declare @CollectionRecordKey   INT = 0 ,	@CollectionData		   NVARCHAR(MAX) = '',	@UserKey 	INT = 486,	@OutPut      BIT = 0 
set @CollectionData ='{
						"InvoiceKey": 0,
						"InvoiceNo": "M-12344",
						"InvoiceDate": "2022-10-17 00:00:00.000",
						"CustomerKey": 15,
						"CustomerTypeKey": 1,
						"ContainerCount": 1,
						"DestinationCity": "Rancho Dominguez",
						"BrokerRefNo": "33232",
						"InvoiceAmount": 200.0000,
						"Payments": 0.00,
						"Balance": 200.00,						
						"StatusCodeKey": 3,
						"OrderDetailKey": 340,
						"InvoicerKey": 488
						
					
					}'
					
 exec CollectionQueue_InsertUpdate
@CollectionRecordKey output,
@CollectionData,
@UserKey,
@OutPut output
select @CollectionRecordKey,@OutPut
*/
CREATE PROCEDURE [dbo].[CollectionQueue_InsertUpdate] 
(
	@CollectionRecordKey   INT = 0 OUTPUT,
	@CollectionData		   NVARCHAR(MAX) = '',
	@IsRevise			   BIT=0,
	@UserKey			   INT = 0,
	@OutPut                BIT = 0 OUTPUT

)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	IF(@IsRevise=1)
		BEGIN
			UPDATE CollectionQueue SET StatusCodeKey=1  WHERE CollectionRecordKey=@CollectionRecordKey
		END
	ELSE
	BEGIN
		CREATE TABLE #CollectionQueue_temp
		(
			CollectionRecordKey		INT,
			InvoiceKey              INT,
			InvoiceNo				VARCHAR(50),
			InvoiceDate				DATETIME,
			CustomerKey				INT,
			CustomerType			BIT,
			ContainerCount			INT,
			DestinationCity			VARCHAR(100),
			BrokerRefNo				VARCHAR(30),		
			InvoiceAmount           DECIMAL,
			Payments				DECIMAL,
			Balance					DECIMAL,		
			StatusCodeKey			INT,	
			OrderDetailKey			INT,
			InvoicerKey				INT,
			Containers				VARCHAR(300),
			BookingNo               VARCHAR(50)
		)

		INSERT INTO #CollectionQueue_temp(CollectionRecordKey,InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
										  Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,Containers,BookingNo)
		SELECT @CollectionRecordKey,InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
			   Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,Containers,BookingNo
		FROM OPENJSON(@CollectionData,'$')
		WITH
		(
			InvoiceKey              INT         '$.InvoiceKey',
			InvoiceNo				VARCHAR(50)	'$.InvoiceNo',
			InvoiceDate				DATETIME    '$.InvoiceDate',
			CustomerKey				INT         '$.CustomerKey',
			CustomerType			BIT         '$.CustomerType',
			ContainerCount			INT         '$.ContainerCount',
			DestinationCity			VARCHAR(100) '$.DestinationCity',
			BrokerRefNo				VARCHAR(30) '$.BrokerRefNo',		
			InvoiceAmount           DECIMAL     '$.InvoiceAmount',
			Payments				DECIMAL     '$.Payments',
			Balance					DECIMAL     '$.Balance',		
			StatusCodeKey			INT         '$.StatusCodeKey',	
			OrderDetailKey			INT         '$.OrderDetailKey',
			InvoicerKey				INT         '$.InvoicerKey',
			Containers				VARCHAR(300)	'$.Containers',
			BookingNo               VARCHAR(50)  '$.BookingNo'
		);

		IF ISNULL(@CollectionRecordKey,0) = 0
		 BEGIN
			 INSERT INTO CollectionQueue(InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
										 Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,CreatedUser, CreatedDate, Containers,BookingNo)
			 SELECT InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
				   Payments,Balance,1,OrderDetailKey,InvoicerKey,@UserKey,GETDATE(), Containers,BookingNo
			 FROM #CollectionQueue_temp 
			 SET @CollectionRecordKey = SCOPE_IDENTITY()

			 INSERT INTO CollectionAuditLog (CollectionRecordKey,StatusCodeKey,DateCreated,CreateUser,Comments)
			 VALUES(@CollectionRecordKey,1,GETDATE(),@UserKey,'Move to under review')
		 END
		ELSE
		 BEGIN
			--DECLARE @PreviousStatusKey INT =0
			--SET @PreviousStatusKey =(SELECT StatusCodeKey FROM CollectionQueue WHERE CollectionRecordKey=(SELECT CollectionRecordKey FROM #CollectionQueue_temp))
			 UPDATE A
			 SET   A.StatusCodeKey		=  B.StatusCodeKey ,
				   --A.PreviousStatusKey  =  @PreviousStatusKey,
				   A.UpdatedUser        =  @UserKey,
				   A.UpdatedDate        =  GETDATE()
			 FROM CollectionQueue A
			 JOIN #CollectionQueue_temp B ON A.CollectionRecordKey = B.CollectionRecordKey

			 DECLARE @comments VARCHAR(300)
			 SET @comments = (SELECT StatusCodeName FROM CollectionStatuCode WHERE StatusCodeKey = (SELECT StatusCodeKey FROM #CollectionQueue_temp) )

			  INSERT INTO CollectionAuditLog (CollectionRecordKey,StatusCodeKey,DateCreated,CreateUser,Comments)
			 VALUES(@CollectionRecordKey,(SELECT StatusCodeKey FROM #CollectionQueue_temp),GETDATE(),@UserKey,'Move to '+ @comments)
		 END
		SET @OutPut = 1
	END
END

 --SELECT * FROM CollectionQueue  

--SELECT GETDATE()


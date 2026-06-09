/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CollectionRecordKey":0,"InvoiceNo":"5062","InvoiceDate":"2023-12-27T00:00:00","CustomerType":false,"ContainerCount":1,"DestinationCity":"Long Beach","BrokerRefNo":"JCB DID NOT TENDER- ","InvoiceAmount":100,"Payments":100,"Balance":0,"InvoiceKey":43525,"StatusCodeKey":1,"InvoicerKey":294,"IsRevise":true,"Containers":"TGBU4289221"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CollectionQueue_InsertUpdate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CollectionRecordKey":0,"InvoiceNo":"28069", "CustKey" : 3024,"InvoiceDate":"2023-12-01T00:00:00","CustomerType":true,"ContainerCount":1,"DestinationCity":"Fontana","BrokerRefNo":"SMISOS00196376","InvoiceAmount":1353.4,"Payments":1353.4,"Balance":0,"InvoiceKey":66640,"StatusCodeKey":1,"InvoicerKey":295,"IsRevise":false,"Containers":"MRSU5516906"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CollectionQueue_InsertUpdate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[CollectionQueue_InsertUpdate_V2] 
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
	@CollectionRecordKey   INT = 0,
	@IsRevise			   BIT = 0

	SET @CollectionRecordKey = JSON_VALUE(@JSONString, '$.CollectionRecordKey')
	SET @IsRevise = JSON_VALUE(@JSONString, '$.IsRevise')

	IF(@IsRevise=1)
		BEGIN
			UPDATE CollectionQueue SET StatusCodeKey=1  WHERE CollectionRecordKey=@CollectionRecordKey

			    SET @Status = 1
    SET @Reason = 'Revised Successfully'
    RETURN

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
			BookingNo               VARCHAR(50),
			IsRevise				BIT
		)

		INSERT INTO #CollectionQueue_temp(CollectionRecordKey,InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
										  Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,Containers,BookingNo, IsRevise)
		SELECT @CollectionRecordKey,InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
			   Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,Containers,BookingNo, IsRevise
		FROM OPENJSON(@JSONString,'$')
		WITH
		(
			CollectionRecordKey		INT			'$.CollectionRecordKey',
			InvoiceKey              INT         '$.InvoiceKey',
			InvoiceNo				VARCHAR(50)	'$.InvoiceNo',
			InvoiceDate				DATETIME    '$.InvoiceDate',
			CustomerKey				INT         '$.CustKey',
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
			BookingNo               VARCHAR(50)  '$.BookingNo',
			IsRevise				BIT			 '$.IsRevise'
		);

		IF ISNULL(@CollectionRecordKey,0) = 0
		 BEGIN
			 INSERT INTO CollectionQueue(InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
										 Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,CreatedUser, CreatedDate, Containers,BookingNo)
			 SELECT InvoiceKey,InvoiceNo,InvoiceDate,CustomerKey,CustomerType,ContainerCount,DestinationCity,BrokerRefNo,InvoiceAmount,
				   Payments,Balance,StatusCodeKey,OrderDetailKey,InvoicerKey,@UserKey,GETDATE(), Containers,BookingNo
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
			 FROM CollectionQueue A WITH(NOLOCK)
			 JOIN #CollectionQueue_temp B ON A.CollectionRecordKey = B.CollectionRecordKey

			 DECLARE @comments VARCHAR(300)
			 SET @comments = (SELECT StatusCodeName FROM CollectionStatuCode WHERE StatusCodeKey = (SELECT StatusCodeKey FROM #CollectionQueue_temp) )

			  INSERT INTO CollectionAuditLog (CollectionRecordKey,StatusCodeKey,DateCreated,CreateUser,Comments)
			 VALUES(@CollectionRecordKey,(SELECT StatusCodeKey FROM #CollectionQueue_temp),GETDATE(),@UserKey,'Move to '+ @comments)
		 END
		SET @Status = 1
		SET @Reason = 'Success'
	END
END

 --SELECT * FROM CollectionQueue  

--SELECT GETDATE()
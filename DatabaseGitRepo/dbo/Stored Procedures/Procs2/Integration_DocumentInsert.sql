

/*

exec Integration_DocumentInsert '[{"ContainerNo":"HLBU1284040","OrderKey":0,"OrderDetailKey":0,"StopKey":107798,"DocumentType":"PROOF_OF_DELIVERY","Id":"doc_01jw68b478few98gsgyqm81yh1","IsSuccess":true,"RequestSent":{"name":"Test Document 1","container_number":"HLBU1284040","filepath":"C:\\Users\\Shravana\\Downloads\\dummy.pdf","document_type":"PROOF_OF_DELIVERY"},"ResponseReceived":"{\"message\":\"Document created successfully\",\"document\":{\"id\":\"doc_01jw68b478few98gsgyqm81yh1\",\"created_at\":\"2025-05-26T12:16:09.448Z\",\"created_by\":\"usr_01hvqq057kffjshwvx1em8gbr2\",\"description\":null,\"document_type\":\"proof_of_delivery\",\"file_url\":\"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBOWloQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--c23e89f9ddf74f27a015592814638a7d5b546b7c/Test%20Document%201\",\"name\":\"Test Document 1\",\"updated_at\":\"2025-05-26T12:16:09.460Z\"}}"},{"ContainerNo":"FCIU6299537","OrderKey":0,"OrderDetailKey":0,"StopKey":107693,"DocumentType":"PROOF_OF_DELIVERY","Id":"doc_01jw68b4n6fgkadx34k629xw26","IsSuccess":true,"RequestSent":{"name":"Test Document 2","container_number":"FCIU6299537","filepath":"C:\\Users\\Shravana\\Downloads\\dummy.pdf","document_type":"PROOF_OF_DELIVERY"},"ResponseReceived":"{\"message\":\"Document created successfully\",\"document\":{\"id\":\"doc_01jw68b4n6fgkadx34k629xw26\",\"created_at\":\"2025-05-26T12:16:09.894Z\",\"created_by\":\"usr_01hvqq057kffjshwvx1em8gbr2\",\"description\":null,\"document_type\":\"proof_of_delivery\",\"file_url\":\"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBOXFoQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--7a9bcfec8060191e4ca8bc4e3e771e671d513542/Test%20Document%202\",\"name\":\"Test Document 2\",\"updated_at\":\"2025-05-26T12:16:09.904Z\"}}"},{"ContainerNo":"NYKU4364144","OrderKey":0,"OrderDetailKey":0,"StopKey":107561,"DocumentType":"PROOF_OF_DELIVERY","Id":"doc_01jw68b52af79antrsh0xf3ahk","IsSuccess":true,"RequestSent":{"name":"Test Document 3","container_number":"NYKU4364144","filepath":"C:\\Users\\Shravana\\Downloads\\dummy.pdf","document_type":"PROOF_OF_DELIVERY"},"ResponseReceived":"{\"message\":\"Document created successfully\",\"document\":{\"id\":\"doc_01jw68b52af79antrsh0xf3ahk\",\"created_at\":\"2025-05-26T12:16:10.314Z\",\"created_by\":\"usr_01hvqq057kffjshwvx1em8gbr2\",\"description\":null,\"document_type\":\"proof_of_delivery\",\"file_url\":\"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBOTJoQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--04469eb94e30e65816d1f97fc20bf0f50fdf41f7/Test%20Document%203\",\"name\":\"Test Document 3\",\"updated_at\":\"2025-05-26T12:16:10.325Z\"}}"},{"ContainerNo":"JXLU6458602","OrderKey":0,"OrderDetailKey":0,"StopKey":107460,"DocumentType":"PROOF_OF_DELIVERY","Id":"doc_01jw68b5gfetk95r0dk5j0y6r1","IsSuccess":true,"RequestSent":{"name":"Test Document 4","container_number":"JXLU6458602","filepath":"C:\\Users\\Shravana\\Downloads\\dummy.pdf","document_type":"PROOF_OF_DELIVERY"},"ResponseReceived":"{\"message\":\"Document created successfully\",\"document\":{\"id\":\"doc_01jw68b5gfetk95r0dk5j0y6r1\",\"created_at\":\"2025-05-26T12:16:10.767Z\",\"created_by\":\"usr_01hvqq057kffjshwvx1em8gbr2\",\"description\":null,\"document_type\":\"proof_of_delivery\",\"file_url\":\"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBK0NoQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--c18b78dfaaf3821a497fe6feef9573f9f9e193ad/Test%20Document%204\",\"name\":\"Test Document 4\",\"updated_at\":\"2025-05-26T12:16:10.778Z\"}}"},{"ContainerNo":"JXLU6458602","OrderKey":0,"OrderDetailKey":0,"StopKey":107461,"DocumentType":"PROOF_OF_DELIVERY","Id":"doc_01jw68b5z5f3zrwxzgd6acn8d5","IsSuccess":true,"RequestSent":{"name":"Test Document 5","container_number":"JXLU6458602","filepath":"C:\\Users\\Shravana\\Downloads\\dummy.pdf","document_type":"PROOF_OF_DELIVERY"},"ResponseReceived":"{\"message\":\"Document created successfully\",\"document\":{\"id\":\"doc_01jw68b5z5f3zrwxzgd6acn8d5\",\"created_at\":\"2025-05-26T12:16:11.237Z\",\"created_by\":\"usr_01hvqq057kffjshwvx1em8gbr2\",\"description\":null,\"document_type\":\"proof_of_delivery\",\"file_url\":\"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBK09oQVE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--9d6e92c2cc3658327ecfebe4dbda858077eb778a/Test%20Document%205\",\"name\":\"Test Document 5\",\"updated_at\":\"2025-05-26T12:16:11.245Z\"}}"}]'

*/


CREATE PROC [dbo].[Integration_DocumentInsert](
	@JsonString NVARCHAR(MAX)
) AS
BEGIN
	
	SET FMTONLY OFF
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY


		CREATE TABLE #temp(
			ContainerNo			VARCHAR(50),
			OrderKey			INT,
			OrderDetailKey		INT,
			StopKey				INT,
			DocumentKey			INT,
			DocumentType		VARCHAR(30),
			Id					VARCHAR(200),
			IsSuccess			BIT,
			RequestSent			NVARCHAR(MAX),
			ResponseReceived	NVARCHAR(MAX),
		)

		INSERT INTO #temp
			(ContainerNo,OrderKey,OrderDetailKey,StopKey,DocumentKey,DocumentType,Id,IsSuccess,RequestSent,ResponseReceived)
		SELECT
			t_ContainerNo,t_OrderKey,t_OrderDetailKey,t_StopKey,t_DocumentKey,t_DocumentType,t_Id,t_IsSuccess,t_RequestSent,t_ResponseReceived
		FROM 
			OPENJSON(@JsonString)
			WITH(
				t_ContainerNo		VARCHAR(50)		'$.ContainerNo'			,
				t_OrderKey			INT				'$.OrderKey	'			,
				t_OrderDetailKey	INT				'$.OrderDetailKey'		,
				t_StopKey			INT				'$.StopKey'				,
				t_DocumentKey		INT				'$.DocumentKey'			,
				t_DocumentType		VARCHAR(30)		'$.DocumentType'		,
				t_Id				VARCHAR(200)	'$.Id'					,
				t_IsSuccess			BIT				'$.IsSuccess'			,
				t_RequestSent		NVARCHAR(MAX)	'$.RequestSent'			,
				t_ResponseReceived	NVARCHAR(MAX)	'$.ResponseReceived'
			)


		INSERT INTO Integration_DocumentUpload
			(ContainerNo,OrderKey,OrderDetailKey,StopKey,TMSDocumentKey,DocumentType,Id,IsSuccess,RequestSent,ResponseReceived,CreatedDate)
		SELECT
			ContainerNo,OrderKey,OrderDetailKey,StopKey,DocumentKey,DocumentType,Id,IsSuccess,RequestSent,ResponseReceived,GETDATE()
		FROM
			#temp
			
		SELECT ''

	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

	ROLLBACK TRANSACTION
	
	END CATCH

END

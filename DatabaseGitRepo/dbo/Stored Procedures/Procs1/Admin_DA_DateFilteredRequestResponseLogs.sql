
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"FromDate":"2026-03-07T05:26:47.040Z","ToDate":"2026-03-17T05:26:47.040Z","LogUserKey":0,"Logkey":0}'
SET	@IsDebug  = 0

EXEC [Admin_DA_DateFilteredRequestResponseLogs] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT
, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PRocEDURE [dbo].[Admin_DA_DateFilteredRequestResponseLogs] --		
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
	SET ARITHABORT ON;
		DECLARE
			@FromDate	Datetime,
			@ToDate		Datetime,
			@LogUserKey	INT,
			@ExcludeNotification BIT = 0

		DECLARE		@GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator; '
		DECLARE		@InternalError	VARCHAR(1000) = '', @Logkey INT	
		SET			@Status = 1

		IF (ISNULL(@JSONString,'') = '')
		BEGIN
			SET	@Status = 0
			SET @InternalError = 'JSON String Cannot be Blank; '
		END
		ELSE
		BEGIN
			SELECT
				@FromDate = CASE WHEN ISNULL(FromDate, '') = '' THEN NULL ELSE FromDate END,
                @ToDate = CASE WHEN ISNULL(ToDate, '') = '' THEN NULL ELSE ToDate END,
				@Logkey = Logkey,
				@LogUserKey = LogUserKey, @ExcludeNotification = ExcludeNotification
			FROM OPENJSON(@JSONString, '$')
			WITH (
					FromDate	Datetime	'$.FromDate',
					ToDate		Datetime	'$.ToDate',
					Logkey		INT			'$.Logkey',
					LogUserKey	INT			'$.LogUserKey',
					ExcludeNotification	BIT			'$.ExcludeNotification'
				)
		END

		IF(@IsDebug = 1)
			BEGIN
				SELECT @FromDate,@ToDate,@Logkey
			END

		IF(ISNULL(@Logkey,0) <> 0)
			BEGIN
				SET @FromDate = '2024-01-01 00:00:00.000'
				SET @ToDate = GETDATE()
			END
		ELSE IF @FromDate IS NULL AND @ToDate IS NULL
			BEGIN
			    SET @FromDate = GETDATE() - 2  
			    SET @ToDate = GETDATE()
			END
        ELSE IF @FromDate IS NULL
			BEGIN
			    SET @FromDate = GETDATE() - 1
			END
        ELSE IF @ToDate IS NULL
			BEGIN
			    SET @ToDate = GETDATE()  -- Default to the current date
			END
		ELSE IF(@FromDate = @ToDate)
			BEGIN
				SET @ToDate = @ToDate + 1
			END

		IF(@Status = 0)
			BEGIN
				SET		@IntMessage = @InternalError
				SET		@ExtMessage = @GenError
			END
		ELSE
			BEGIN
				
				SELECT		*
				INTO		#UserDetails
				FROM		(SELECT		0 UserKey,'--ALL--' UserName
							UNION ALL
							SELECT		U.UserKey, U.UserName
							FROM		[USER] U WITH (NOLOCK)
							INNER JOIN	(SELECT DISTINCT Userkey FROM DA_RequestResponseLogs WHERE UserKey <> 0) RR 
										ON U.UserKey = RR.UserKey)A
				Order By CASE WHEN UserKey = 0 THEN 0 ELSE 1 END, UserName

				-- SET @ExcludeNotification = 1

				SELECT		 LogKey,ProcedureName,DA.UserKey, U.UserName AS UserName
							,CASE WHEN @Logkey = 0 THEN '' ELSE RequestJSONString END RequestJSONString
							,IsDebug,OutputStatus,OutputInternalError,OutputExternallError
							,CASE WHEN @Logkey = 0 THEN '' ELSE ISNULL(ReponseJSONString,'') END ReponseJSONString
							,CreatedDate,UpdatedDate,DA.FirebaseID AS FirebaseID, 0 AS IsLogout
							,0 AS DriverKey, DA.UserKey AS LogUserKey 
				INTO		#LogDetails
				FROM		DA_RequestResponseLogs DA WITH (NOLOCK)
				INNER JOIN	[USER] U WITH (NOLOCK) ON DA.UserKey = U.UserKey
				WHERE		(DA.UserKey = @LogUserKey OR ISNULL(@LogUserKey,0)  = 0) AND CreatedDate BETWEEN @FromDate AND @ToDate 
							AND CASE WHEN @Logkey = 0 THEN  0 ELSE  DA.LogKey END = @Logkey
							AND CASE WHEN @ExcludeNotification = 1 THEN ProcedureName ELSE '' END <>  'DA_InsertNotification'
				Order By	LogKey DESC

				--hardcoded for testing
				SELECT UserKey=714,UserName='Roshan',MobileNo='9880814814',FilePath='https://daapi.jctransports.com/LogFiles/'
				INTO #LogFiles


				IF(@IsDebug = 1)
					BEGIN
						SELECT * FROM #UserDetails
						SELECT * FROM #LogDetails
						SELECT * FROM #LogFiles
					END

				DECLARE @JSON NVARCHAR(MAX)	
				SET @JSON = (SELECT		
								UserDetails = (SELECT * FROM #UserDetails FOR JSON PATH),
								LogDetails = (SELECT * FROM #LogDetails FOR JSON PATH),
								LogFiles = (SELECT * FROM #LogFiles FOR JSON PATH)
								FOR JSON PATH
							) 

				SELECT @JSON AS JSONResult

				SET		@IntMessage = 'Success'
				SET		@ExtMessage = 'Success'
			END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET		@Status = 0
		SET		@IntMessage = 'Procedure Name : ' + ERROR_PROCEDURE() + '. Error Message : ' +  ERROR_MESSAGE()+ '. JSON String : ' + @JSONString
		SET		@ExtMessage = 'Data Exception Error'
	END CATCH
END


/* 
DECLARE 
	@UserKey INT=951,
	@JSONString NVARCHAR(MAX)= '{"RouteKeys":"682348:627469","OrderDetailKeys":"208275:191803","DispatcherKey":57,"DriverKey":0}',
	@Status	BIT=0, @IsDebug	BIT=1, @Reason VARCHAR(100)=''
	EXEC AddUpdate_DispatchBulkActions @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[AddUpdate_DispatchBulkActions]
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
	SET ARITHABORT ON

	DECLARE @RouteKeys			 VARCHAR(MAX),
			@OrderDetailKeys	 VARCHAR(MAX),
			@DispatcherKey		 INT,
			@DriverKey			 INT,
			@TabStatus			 INT

	BEGIN TRY
		
		IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
			BEGIN
				SET		@Status = 0
				SET		@Reason = 'JsonString not found'
				RETURN
			END	
			
		IF (@IsDebug = 1)
			BEGIN
				SET		@Status = 0
				SET		@Reason = 'In Debug Mode'
			END	

		SELECT 
			@RouteKeys			=   RouteKeys,
			@OrderDetailKeys	=	OrderDetailKeys,
			@DispatcherKey		=   DispatcherKey,
			@DriverKey			=	DriverKey,
			@TabStatus			=	TabStatus

		FROM 
			OPENJSON(@JsonString, '$')
		WITH (
			RouteKeys			VARCHAR(MAX)		'$.RouteKeys',
			OrderDetailKeys		VARCHAR(MAX)		'$.OrderDetailKeys',
			DispatcherKey		INT					'$.DispatcherKey',
			DriverKey			INT					'$.DriverKey',
			TabStatus			INT					'$.TabStatus'
		)

		IF (ISNULL(@RouteKeys,'') <> '')
		SELECT CAST([Value] as INT) AS RouteKey
        INTO #RouteKeys
        FROM Fn_SplitParamCol(@RouteKeys)

		IF (ISNULL(@OrderDetailKeys,'') <> '')
		SELECT CAST([Value] as INT) AS OrderDetailKey
        INTO #OrderDetailKeys
        FROM Fn_SplitParamCol(@OrderDetailKeys)

		BEGIN TRANSACTION;

		-------------------------------------------------------
		-- Call AddUpdate_Dispatcher for each OrderDetailKey
		-------------------------------------------------------
		IF ISNULL(@DispatcherKey,0) > 0 AND OBJECT_ID('tempdb..#OrderDetailKeys') IS NOT NULL
		BEGIN
			DECLARE @OrderDetailKey INT;
			DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR
				SELECT OrderDetailKey FROM #OrderDetailKeys;

			OPEN OrderCursor;
			FETCH NEXT FROM OrderCursor INTO @OrderDetailKey;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @JSONString = (SELECT @OrderDetailKey OrderDetailKey, @DispatcherKey Dispatcher, @TabStatus TabStatus FOR JSON PATH)

				EXEC [dbo].[AddUpdate_Dispatcher] @UserKey, @JSONString, @Status, @Reason, @IsDebug

				FETCH NEXT FROM OrderCursor INTO @OrderDetailKey;
			END

			CLOSE OrderCursor;
			DEALLOCATE OrderCursor;
		END

		-----------------------------------------------------------
		-- Call Update_DispatchActionData_Driver for each RouteKey
		-----------------------------------------------------------
		IF ISNULL(@DriverKey,0) > 0 AND OBJECT_ID('tempdb..#RouteKeys') IS NOT NULL
		BEGIN
			DECLARE @RouteKey INT;
			DECLARE RouteCursor CURSOR LOCAL FAST_FORWARD FOR
				SELECT RouteKey FROM #RouteKeys;

			OPEN RouteCursor;
			FETCH NEXT FROM RouteCursor INTO @RouteKey;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC [dbo].[Update_DispatchActionData_Driver_V2] @UserKey, @JSONString, @Status, @Reason, @IsDebug	

				FETCH NEXT FROM RouteCursor INTO @RouteKey;
			END

			CLOSE RouteCursor;
			DEALLOCATE RouteCursor;
		END

		SET ARITHABORT OFF;
		COMMIT TRANSACTION;

		SET @Status = 1
		SET @Reason = 'Success'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END CATCH
END


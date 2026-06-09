CREATE PROCEDURE [dbo].[Dispatch_SaveStopDetails]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	DECLARE @OrderDetailKey INT =	0,@ShipFromData  NVARCHAR(MAX),@ShipToData  NVARCHAR(MAX),@ReturnToData  NVARCHAR(MAX),
			@AFStopOffData	NVARCHAR(MAX), @ATStopOffData	NVARCHAR(MAX),@IsConfirm  BIT=0

	SELECT @OrderDetailKey = OrderDetailKey,@ShipFromData=ShipFromData,
		   @ShipToData=ShipToData,@ReturnToData=ReturnToData,@AFStopOffData=AFStopOffData,
		   @ATStopOffData=ATStopOffData,@IsConfirm=IsConfirm
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey				INT				'$.OrderDetailKey',
			ShipFromData				NVARCHAR(MAX)	'$.ShipFromData' AS JSON,
			ShipToData					NVARCHAR(MAX)	'$.ShipToData' AS JSON,
			ReturnToData				NVARCHAR(MAX)	'$.ReturnToData' AS JSON,
			AFStopOffData				NVARCHAR(MAX)	'$.AFStopOffData' AS JSON,
			ATStopOffData				NVARCHAR(MAX)	'$.ATStopOffData' AS JSON,
			IsConfirm					BIT				'$.IsConfirm'
		)
	BEGIN TRAN
	BEGIN TRY
	IF(ISNULL(@ShipFromData,'')<>'')
		BEGIN
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipFromData,0,@Status,@Reason
		END
		IF(ISNULL(@ShipToData,'')<>'')
		BEGIN
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipToData,0,@Status,@Reason
		END
		IF(ISNULL(@ReturnToData,'')<>'')
		BEGIN
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ReturnToData,0,@Status,@Reason
		END
		IF(ISNULL(@AFStopOffData,'')<>'')
		BEGIN
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@AFStopOffData,0,@Status,@Reason
		END
		IF(ISNULL(@ATStopOffData,'')<>'')
		BEGIN
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ATStopOffData,0,@Status,@Reason
		END
		SET @Status=1;
		SET @Reason='Success';
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		print error_message();
		SET @Status=0;
		SET @Reason='Failed to save data';
		ROLLBACK TRAN;
	END CATCH
END

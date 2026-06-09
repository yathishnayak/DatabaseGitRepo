/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverVoucherKey":5,"DriverVoucherNumber":"D-0005","DriverVoucherdate":"2023-05-14T00:00:00","DriverKey":895,"DriverID":"15-AMERICAN DREAM TR","DriverName":"JUAN  GARCIA","DriverVoucherAmount":647.35,"DrivingLicenseNo":null,"DrivingLicenseExpiryDate":null,"CreateUser":"291","UpdateUser":null,"IsRecurring":false,"DeductionDetails":[{"DriverVoucherLineKey":533,"DriverVoucherKey":5,"ItemKey":188,"Description":"DED - Fuel","UnitCost":597.35,"Qty":1,"ExtCost":597.35,"CreateUser":null,"UpdateUser":null},{"ItemKey":34,"Description":"DRIVER PAY","UnitCost":10,"Qty":5,"ExtCost":50,"IsEditMode":false}]}'
	EXEC [InsertUpdate_DriverVoucherDeduction_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverVoucherKey":461,"DriverVoucherNumber":"D-000461","DriverVoucherdate":"2026-04-16T00:00:00","DriverKey":1814,"DriverID":"Amrutha","DriverName":"Amrutha V  Nayak","DriverVoucherAmount":1000,"DrivingLicenseNo":null,"DrivingLicenseExpiryDate":null,"CreateUser":"1133","UpdateUser":null,"IsRecurring":false,"DeductionDetails":[{"DriverVoucherLineKey":528,"DriverVoucherKey":461,"ItemKey":164,"Description":"Dry Run- Customer","UnitCost":20,"Qty":20,"ExtCost":400,"CreateUser":null,"UpdateUser":null},{"ItemKey":"373","Description":"Bonded Fee","UnitCost":30,"Qty":20,"ExtCost":600,"IsEditMode":false}]}'
	EXEC [InsertUpdate_DriverVoucherDeduction_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[InsertUpdate_DriverVoucherDeduction_V2]
(
    @UserKey        INT = 1144,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0 
)
AS 
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0
        SET @Reason = 'Parameters not found'
        RETURN
    END    

    DECLARE 
        @DriverVoucherKey INT,
        @DriverVoucherdate DATETIME,
        @DriverVoucherAmount DECIMAL(18,2),
        @DriverKey INT

    SELECT 
        @DriverVoucherKey = DriverVoucherKey,
        @DriverVoucherdate = DriverVoucherdate,
        @DriverVoucherAmount = DriverVoucherAmount,
        @DriverKey = DriverKey
    FROM OPENJSON(@JSONString)
    WITH
    (
        DriverVoucherKey     INT             '$.DriverVoucherKey',
        DriverVoucherdate    DATETIME        '$.DriverVoucherDate',
        DriverVoucherAmount  DECIMAL(18,2)   '$.DriverVoucherAmount',
        DriverKey            INT             '$.DriverKey'
    )

    SET @DriverVoucherdate = ISNULL(@DriverVoucherdate, GETDATE())

    IF (@DriverKey = 0)
    BEGIN
        SET @Status = 0
        SET @Reason = 'DriverKey is required'
        RETURN
    END

    DECLARE @WeekNumber INT
    SET @WeekNumber = DATEPART(ISO_WEEK, @DriverVoucherdate)

    BEGIN TRY
        BEGIN TRAN

        IF ISNULL(@DriverVoucherKey, 0) = 0
        BEGIN
            INSERT INTO DriverVoucherDeduction
            (
                DriverVoucherdate,
                DriverVoucherAmount,
                DriverKey,
                CreateUser,
                CreateDate
            )
            VALUES
            (
                @DriverVoucherdate,
                @DriverVoucherAmount,
                @DriverKey,
                @UserKey,
                GETDATE()
            )

            SET @DriverVoucherKey = SCOPE_IDENTITY()

            DECLARE @DriverVoucherNumber VARCHAR(50)
            SET @DriverVoucherNumber = 'D-000' + CAST(@DriverVoucherKey AS VARCHAR)

            UPDATE DriverVoucherDeduction
            SET WeekNumber = @WeekNumber,
                DriverVoucherNumber = @DriverVoucherNumber
            WHERE DriverVoucherKey = @DriverVoucherKey
        END
        ELSE
        BEGIN
            UPDATE DriverVoucherDeduction
            SET DriverVoucherdate = @DriverVoucherdate,
                DriverVoucherAmount = @DriverVoucherAmount,
                DriverKey = @DriverKey,
                UpdateDate = GETDATE(),
                UpdateUser = @UserKey,
                WeekNumber = @WeekNumber
            WHERE DriverVoucherKey = @DriverVoucherKey
        END

     IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString, '$.DeductionDetails'))
     BEGIN
        DECLARE @DetailRow NVARCHAR(MAX)

        DECLARE DetailCursor CURSOR FOR
        SELECT value 
        FROM OPENJSON(@JSONString, '$.DeductionDetails')

        OPEN DetailCursor
        FETCH NEXT FROM DetailCursor INTO @DetailRow

        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'Processing: ' + @DetailRow 

            SET @DetailRow = JSON_MODIFY(@DetailRow, '$.DriverVoucherKey', @DriverVoucherKey)

            DECLARE @DetailStatus BIT = 0
            DECLARE @DetailReason VARCHAR(1000)

            EXEC dbo.InsertUpdate_DriverVoucherDeductionDetail_V2
                @UserKey    = @UserKey,
                @JSONString = @DetailRow,
                @Status     = @DetailStatus OUTPUT,
                @Reason     = @DetailReason OUTPUT,
                @IsDebug    = @IsDebug

        IF @DetailStatus = 0
        BEGIN
            CLOSE DetailCursor
            DEALLOCATE DetailCursor

            ROLLBACK TRAN
            SET @Status = 0
            SET @Reason = @DetailReason
            RETURN
        END

        FETCH NEXT FROM DetailCursor INTO @DetailRow
    END

    CLOSE DetailCursor
    DEALLOCATE DetailCursor
END
        COMMIT TRAN

        SET @Status = 1
        SET @Reason = 'Success'

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN
        SET @Status = 0
        SET @Reason = ERROR_MESSAGE()
    END CATCH
END
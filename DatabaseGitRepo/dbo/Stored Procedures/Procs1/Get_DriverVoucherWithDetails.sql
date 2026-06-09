/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"DriverVoucherKey":4}'
		EXEC [Get_DriverVoucherWithDetails] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
		SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_DriverVoucherWithDetails]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT OUTPUT,
	@Reason			VARCHAR(1000) OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@JSONString,'') = ''
	BEGIN
		SET @Status = 0
		SET @Reason = 'JSON should not be empty'
		RETURN
	END

    DECLARE 
        @DriverVoucherKey INT

    SELECT 
        @DriverVoucherKey 	 = 	DriverVoucherKey
    FROM OPENJSON(@JSONString)
    WITH
    (
        DriverVoucherKey 		INT		'$.DriverVoucherKey'
    )

   IF ISNULL(@DriverVoucherKey,0) = 0
    BEGIN
        SET @Status = 0
        SET @Reason = 'DriverVoucherKey should not be empty'
        RETURN
    END

    SELECT 
        DVD.DriverVoucherKey,
        DVD.DriverVoucherNumber,
        DVD.DriverVoucherdate as DriverVoucherDate,
        DVD.DriverKey,
        D.DriverID,
        LTRIM(RTRIM(D.FirstName + ' ' + D.LastName)) AS DriverName,
        DVD.DriverVoucherAmount,
        D.DrivingLicenseNo,
        D.DrivingLicenseExpiryDate,
        DVD.CreateUser,
        DVD.UpdateUser,
        ISNULL(DVD.IsRecurring, 0) AS IsRecurring,
        JSON_QUERY(
            (
                SELECT
                    DDD.DriverVoucherLineKey,
                    DDD.DriverVoucherKey,
                    DDD.ItemKey,
                    I.Description,
                    DDD.UnitCost,
                    DDD.Qty,
                    DDD.ExtCost,
                    DDD.CreateUser,
                    DDD.UpdateUser
                FROM DriverVoucherDeductionDetail DDD WITH (NOLOCK)
                INNER JOIN Item I WITH (NOLOCK)
                    ON DDD.ItemKey = I.ItemKey
                WHERE DDD.DriverVoucherKey = DVD.DriverVoucherKey
                FOR JSON PATH, INCLUDE_NULL_VALUES
            )
        ) AS DeductionDetails

    FROM DriverVoucherDeduction DVD WITH (NOLOCK)
    LEFT JOIN Driver D WITH (NOLOCK)
        ON D.DriverKey = DVD.DriverKey
    WHERE DVD.DriverVoucherKey = @DriverVoucherKey
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES

    SET @Status = 1
    SET @Reason = 'Success'
END
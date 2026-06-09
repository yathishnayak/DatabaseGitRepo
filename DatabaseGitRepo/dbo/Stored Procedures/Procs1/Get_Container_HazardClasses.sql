/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"OrderDetailKey":0}'
 
EXEC [Get_Container_HazardClasses] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_Container_HazardClasses]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ClassKey INT,
			@OrderDetailKey	INT;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	IF(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	BEGIN
		SET @OrderDetailKey = 0
	END
	ELSE
	BEGIN
		SELECT @OrderDetailKey =  OrderDetailKey
		FROM OpenJSON(@JSONString, '$')
		WITH (
			OrderDetailKey			INT				'$.OrderDetailKey'
		)
	END
 
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult = (
		SELECT
            (SELECT 
                HC.ClassKey,
                HC.Description,
                HC.IsActive,
                HC.IsDeleted
             FROM Container_HazardClasses HC WITH (NOLOCK)
             WHERE HC.IsActive = 1
             ORDER BY HC.ClassKey
             FOR JSON PATH
            ) AS HazardClasses

            --(CASE 
            --    WHEN @OrderDetailKey = 0 THEN '[]'
            --    ELSE (
            --        SELECT HCL.OrderDetailKey, HCL.ClassKey
            --        FROM HazardClassesLink HCL WITH (NOLOCK)
            --        WHERE HCL.OrderDetailKey = @OrderDetailKey
            --        ORDER BY HCL.OrderDetailKey
            --        FOR JSON PATH
            --    )
            -- END) AS HazardClassesSelected
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	);
 
	SELECT @JSONResult AS JSONResult

	SET @Status = 1;
	SET @Reason = 'Success';

END
/*
Declare @UserKey INT = 952, @JsonString NVARCHAR(MAX) = '', @IsDebug BIT = 0, @Status BIT = 0, @Reason VARCHAR(100) = ''
Set @JsonString = '{"SearchText":"IMPT2511722,IMPT2512070,MSKU9996443,TEST0000443,,MSKU0009955","ScreenKey":6,"SearchCriteriaKey":1}' 
Exec SearchHistory_Insert @UserKey, @JsonString, @IsDebug, @Status output, @Reason output
Select @Status Status, @Reason Reason
*/

/*
DECLARE 
	@UserKey INT=1144,
	@JSONString NVARCHAR(MAX)='{"SearchText":"226655","ScreenKey":4,"SearchCriteriaKey":1}',
	@Status BIT=0, 
	@IsDebug INT = 1,
	@Reason VARCHAR(100)=''
EXEC SearchHistory_Insert @UserKey,@JSONString, @IsDebug, @Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[SearchHistory_Insert]
(    
    @UserKey       INT,    
    @JsonString    VARCHAR(MAX),    
    @IsDebug       BIT = 0,    
    @Status        BIT = 0 OUTPUT,    
    @Reason        NVARCHAR(1000) = '' OUTPUT    
)    
AS    
BEGIN    
    SET NOCOUNT ON;    
    SET XACT_ABORT ON;

    -- Validate inputs
    IF @UserKey IS NULL OR @UserKey <= 0
    BEGIN    
        SET @Status = 0;    
        SET @Reason = 'Invalid UserKey';    
        RETURN;    
    END

    IF(ISNULL(@JsonString,'')='')    
    BEGIN    
        SET @Status = 0;    
        SET @Reason = 'Parameter not found';    
        RETURN;    
    END

    DECLARE
        @SearchText             NVARCHAR(MAX),
        @SearchCriteriaKey      INT,
        @ScreenKey              INT,
        @TotalSearchValues      INT,
        @FoundValues            INT,
        @MissingValues          NVARCHAR(MAX);
    
    -- Parse JSON
    SELECT 
        @SearchText = SearchText, 
        @SearchCriteriaKey = SearchCriteriaKey, 
        @ScreenKey = ScreenKey
    FROM OPENJSON(@JsonString, '$')
    WITH(
        SearchText              NVARCHAR(MAX)   '$.SearchText',
        SearchCriteriaKey       INT             '$.SearchCriteriaKey',
        ScreenKey               INT             '$.ScreenKey'
    );  

    -- Validate parsed values
    IF @SearchText IS NULL OR LEN(@SearchText) <= 2
    BEGIN
        SET @Status = 0;
        SET @Reason = 'SearchText must be longer than 2 characters';
        RETURN;
    END

    IF @SearchCriteriaKey IS NULL OR @ScreenKey IS NULL
    BEGIN
        SET @Status = 0;
        SET @Reason = 'SearchCriteriaKey and ScreenKey are required';
        RETURN;
    END

    -- Validate SearchCriteriaKey range
    IF @SearchCriteriaKey NOT IN (1, 2, 3, 4, 5, 6)
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid SearchCriteriaKey. Allowed values: 1, 2, 3, 5, 6';
        RETURN;
    END

    IF @IsDebug = 1
    BEGIN
        PRINT '@SearchCriteriaKey: ' + CAST(@SearchCriteriaKey AS VARCHAR(10));
        PRINT '@SearchText: ' + @SearchText;
    END

    -- Get total count of search values
    SELECT @TotalSearchValues = COUNT(*) 
    FROM fn_splitparam(@SearchText);

    -- Validate that ALL search values exist in database
    SELECT @FoundValues = COUNT(DISTINCT SearchValue)
    FROM (
        -- SearchCriteriaKey = 1: Container Numbers
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        INNER JOIN OrderDetail od ON sv.VALUE = od.ContainerNo
        WHERE @SearchCriteriaKey = 1
        
        UNION ALL
        
        -- SearchCriteriaKey = 2: Order Numbers
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        INNER JOIN OrderHeader oh ON sv.VALUE = oh.OrderNo
        WHERE @SearchCriteriaKey = 2
        
        UNION ALL
        
        -- SearchCriteriaKey = 3: Bill of Lading
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        WHERE @SearchCriteriaKey = 3
          AND EXISTS (
              SELECT 1 
              FROM OrderDetail od
              INNER JOIN OrderHeader oh ON od.OrderKey = oh.OrderKey
              WHERE sv.VALUE IN (od.BillOfLadding, oh.BillOfLading)
          )

        UNION ALL
        
        -- SearchCriteriaKey = 4: InvoiceKey
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        JOIN InvoiceHeader IH WITH (NOLOCK) ON sv.VALUE = IH.InvoiceNo
        WHERE @SearchCriteriaKey = 4          
        
        UNION ALL
        
        -- SearchCriteriaKey = 5: VoucherNo
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        WHERE @SearchCriteriaKey = 5
          AND EXISTS (
              SELECT 1 
              FROM OrderDetail od
              INNER JOIN OrderHeader oh ON od.OrderKey = oh.OrderKey
              WHERE sv.VALUE IN (od.CustRefNo, oh.BrokerRefNo)
          )

        UNION ALL

        -- SearchCriteriaKey = 6: Customer/Broker Reference
        SELECT sv.VALUE AS SearchValue
        FROM fn_splitparam(@SearchText) sv
        INNER JOIN VoucherHeader VH ON sv.VALUE = VH.VoucherNo
        WHERE @SearchCriteriaKey = 6

    ) AS ValidationResults;     
    print '2'
    -- Check if ALL values were found
    IF @FoundValues <> @TotalSearchValues OR @FoundValues = 0
    BEGIN
        -- Optional: Find which values are missing
        SELECT @MissingValues = STRING_AGG(sv.VALUE, ', ')
        FROM fn_splitparam(@SearchText) sv
        WHERE NOT EXISTS (
            SELECT 1
            FROM (
                -- All possible matches based on criteria
                SELECT ContainerNo AS Value
                FROM OrderDetail
                WHERE @SearchCriteriaKey = 1
                
                UNION
                
                SELECT OrderNo AS Value
                FROM OrderHeader
                WHERE @SearchCriteriaKey = 2
                
                UNION
                
                SELECT od.BillOfLadding AS Value
                FROM OrderDetail od
                WHERE @SearchCriteriaKey = 3 AND od.BillOfLadding IS NOT NULL
                
                UNION
                
                SELECT oh.BillOfLading AS Value
                FROM OrderHeader oh
                WHERE @SearchCriteriaKey = 3 AND oh.BillOfLading IS NOT NULL
                
                UNION
                
                SELECT od.CustRefNo AS Value
                FROM OrderDetail od
                WHERE @SearchCriteriaKey = 5 AND od.CustRefNo IS NOT NULL
                
                UNION

                SELECT InvoiceNo AS VALUE
                FROM InvoiceHeader IH
                WHERE @SearchCriteriaKey = 4

                UNION
                
                SELECT oh.BrokerRefNo AS Value
                FROM OrderHeader oh
                WHERE @SearchCriteriaKey = 5 AND oh.BrokerRefNo IS NOT NULL

                UNION

                SELECT VoucherNo AS VALUE
                FROM VoucherHeader VH
                WHERE @SearchCriteriaKey = 6

            ) AS AllValues
            WHERE AllValues.Value = sv.VALUE
        );
        print '1'
        SET @Status = 0;
        SET @Reason = 'Data not found in Database. Missing values: ' + ISNULL(@MissingValues, 'Unknown');
        
        IF @IsDebug = 1
        BEGIN
            PRINT 'Found Values: ' + CAST(@FoundValues AS VARCHAR(10));
            PRINT 'Total Values: ' + CAST(@TotalSearchValues AS VARCHAR(10));
            PRINT 'Missing: ' + ISNULL(@MissingValues, 'None');
        END
        
        RETURN;
    END

    -- All validations passed, proceed with insert
    BEGIN TRY
        BEGIN TRAN        
            -- Delete existing entry to avoid duplicates
            DELETE 
            FROM SearchHistoryList
            WHERE SearchText = @SearchText 
              AND SearchCriteriaKey = @SearchCriteriaKey
              AND ScreenKey = @ScreenKey
              AND UserKey = @UserKey;

            -- Insert new search history
            INSERT INTO SearchHistoryList(SearchText, CreateDate, UserKey, SearchCriteriaKey, ScreenKey)
            VALUES(@SearchText, GETDATE(), @UserKey, @SearchCriteriaKey, @ScreenKey);

            SET @Status = 1;    
            SET @Reason = 'Success'; 
            
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        -- Roll back transaction if active
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        SET @Status = 0;    
        SET @Reason = ERROR_MESSAGE();

        -- Debug information
        IF @IsDebug = 1
        BEGIN
            PRINT 'Error Message: ' + ERROR_MESSAGE();    
            PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));  
            PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        END
    END CATCH

END
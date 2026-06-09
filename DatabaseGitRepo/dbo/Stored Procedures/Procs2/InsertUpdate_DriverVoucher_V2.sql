/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"DeductionDetails":[{"IsEditMode":false,"ItemKey":"143","Description":"FLATBED  TARP AND  UN-TARP","UnitCost":12,"Qty":1,"ExtCost":12}],"DriverKey":"1163","DriverID":"821-LR","DriverName":"Lino Rodriguez ","DriverVoucherdate":"2026-02-05T00:00:00.000Z","ContainerNo":"CAAU8524385","RouteKey":"547865","DriverVoucherAmount":12}',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@isDebug BIT=1
EXEC [InsertUpdate_DriverVoucher_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT, @isDebug
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_DriverVoucher_V2]
(
    @UserKey      INT = 512,
    @JSONString   NVARCHAR(MAX) = '',
    @JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
    @Status       BIT = 0 OUTPUT,
    @Reason       VARCHAR(1000) = '' OUTPUT,
    @isDebug      BIT = 0
)
AS
SET NOCOUNT ON;
SET ARITHABORT ON;
BEGIN
    -- Initialize outputs
    SET @Status = 0;
    SET @Reason = 'Failure';
    SET @JSONOutput = '';

    -- Validate required parameters
    IF (@JSONString = '' OR @JSONString IS NULL OR ISJSON(@JSONString) != 1)
    BEGIN
        SET @Reason = 'Invalid or missing JSON parameter';
        RETURN;
    END

    DECLARE @RetroPaySuffix VARCHAR(10)='-R', @RetroVoucherCount INT=0;

    -- Declare variables for JSON parsing
    DECLARE @DriverVoucherKey      INT = 0,
            @DriverVoucherdate     DATETIME,
            @DriverVoucherAmount   DECIMAL(18,2),
            @DriverKey             INT,
            @ContainerNo           NVARCHAR(50),
            @CreateUser            NVARCHAR(50),
            @DeductionDetails      NVARCHAR(MAX),
            @RouteKey              INT,
            @ReturnedVoucherKey    INT = 0,
            @IsRetroPay            BIT;

    -- Parse main JSON object
    BEGIN TRY
        SELECT  
            @DriverVoucherKey    = ISNULL(DriverVoucherKey, 0), 
            @DriverVoucherdate   = DriverVoucherdate, 
            @DriverVoucherAmount = DriverVoucherAmount, 
            @DriverKey           = DriverKey, 
            @ContainerNo         = ContainerNo, 
            @CreateUser          = CreateUser,
            @DeductionDetails    = DeductionDetails,
            @RouteKey            = RouteKey,
            @IsRetroPay          = IsRetroPay
        FROM OPENJSON(@JSONString, '$')
        WITH (
            DriverVoucherKey     INT             '$.DriverVoucherKey',          
            DriverVoucherdate    DATETIME        '$.DriverVoucherdate',
            DriverVoucherAmount  DECIMAL(18,2)   '$.DriverVoucherAmount',
            DriverKey            INT             '$.DriverKey',
            ContainerNo          NVARCHAR(50)    '$.ContainerNo',
            CreateUser           NVARCHAR(50)    '$.CreateUser',
            DeductionDetails     NVARCHAR(MAX)   '$.DeductionDetails' AS JSON,
            RouteKey             INT             '$.RouteKey',
            IsRetroPay		     BIT			 '$.IsRetroPay'
        );
    END TRY
    BEGIN CATCH
        SET @Reason = 'Error parsing JSON: ' + ERROR_MESSAGE();
        RETURN;
    END CATCH

    -- Validate required fields
    IF (@DriverKey IS NULL OR @DriverKey = 0)
    BEGIN
        SET @Reason = 'Driver is required';
        RETURN;
    END

    IF (@DriverVoucherdate IS NULL)
    BEGIN
        SET @DriverVoucherdate = GETDATE();
    END

    -- Set CreateUser from UserKey
    SET @CreateUser = @UserKey;

    -- Calculate week number
    DECLARE @WeekNumber INT = DATEPART(ISO_WEEK, ISNULL(@DriverVoucherdate, GETDATE()));

    -- Create temp table for deduction details
    CREATE TABLE #tempDeduction (
        DriverVoucherLineKey    INT,
        ItemKey                 INT,
        UnitCost                DECIMAL(18,2),
        Qty                     DECIMAL(18,2),
        Remarks                 NVARCHAR(200),
        RowNum                  INT IDENTITY(1,1) -- For ordering if needed
    );

    -- Parse deduction details JSON
    BEGIN TRY
        INSERT INTO #tempDeduction (DriverVoucherLineKey, ItemKey, UnitCost, Qty, Remarks)
        SELECT 
            DriverVoucherLineKey,
            ItemKey,
            UnitCost,
            Qty,
            Remarks
        FROM OPENJSON(@DeductionDetails, '$')
        WITH (
            DriverVoucherLineKey    INT             '$.DriverVoucherLineKey',         
            ItemKey                 INT             '$.ItemKey',
            UnitCost                DECIMAL(18,2)   '$.UnitCost',
            Qty                     DECIMAL(18,2)   '$.Qty',
            Remarks                 NVARCHAR(200)   '$.Remarks'
        );
    END TRY
    BEGIN CATCH
        SET @Reason = 'Error parsing deduction details JSON: ' + ERROR_MESSAGE();
        DROP TABLE #tempDeduction;
        RETURN;
    END CATCH

    -- Debug output
    IF @isDebug = 1
    BEGIN
        SELECT 'Debug - Parsed Data' AS Info, 
               @DriverVoucherKey AS DriverVoucherKey,
               @DriverKey AS DriverKey,
               @DriverVoucherdate AS VoucherDate;
        
        SELECT * FROM #tempDeduction;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert or Update main DriverVoucher record
        IF @DriverVoucherKey = 0
        BEGIN
            -- Insert new voucher
            INSERT INTO DriverVoucher (
                DriverVoucherdate, 
                DriverVoucherAmount, 
                DriverKey, 
                CreateUser, 
                CreateDate, 
                ContainerNo,
                WeekNumber,
                RouteKey,
                IsRetroPay
            )
            VALUES (
                @DriverVoucherdate, 
                @DriverVoucherAmount, 
                @DriverKey, 
                @CreateUser, 
                GETDATE(), 
                @ContainerNo,
                @WeekNumber,
                @RouteKey,
                @IsRetroPay
            );

            SET @DriverVoucherKey = SCOPE_IDENTITY();

            -- Generate voucher number
            DECLARE @DriverVoucherNumber VARCHAR(50) = 'M-000' + CONVERT(VARCHAR(50), @DriverVoucherKey);

            --added for retro pay
            IF(@IsRetroPay=1)
            BEGIN
                SET @RetroVoucherCount=(
                                        SELECT COUNT(1) FROM DriverVoucher 
                                        WHERE ContainerNo=@ContainerNo AND RouteKey=@RouteKey 
                                        AND DriverKey=@DriverKey AND ISNULL(IsRetroPay,0)=1
                                        )
                SET @RetroPaySuffix=@RetroPaySuffix+CAST(@RetroVoucherCount AS VARCHAR)
                SELECT @DriverVoucherNumber= ISNULL(DriverVoucherNumber,'') FROM DriverVoucher 
                                             WHERE ContainerNo=@ContainerNo AND RouteKey=@RouteKey 
                                             AND DriverKey=@DriverKey AND ISNULL(IsRetroPay,0)=0
                SET @DriverVoucherNumber=@DriverVoucherNumber+@RetroPaySuffix
            END
            --end
            
            UPDATE DriverVoucher
            SET DriverVoucherNumber = @DriverVoucherNumber
            WHERE DriverVoucherKey = @DriverVoucherKey;

            
            --added for create voucher
            DECLARE @VoucherOutPUT BIT=0,
            --@ReturnedVoucherKey INt=0,
            @VoucherNo VARCHAR(20),
            @VoucherStatus INt

            SET @VoucherNo =( SELECT ISNULL(MAX(CAST(VoucherNo AS INT)),0)+1  FROM  dbo.VoucherHeader );
            SET @VoucherStatus= ( SELECT StatusKey FROM dbo.VoucherStatus WHERE [Description]='Pending' )

            INSERT INTO [dbo].VoucherHeader( [VoucherNo],[VoucherDate], [BillToAddrKey], [VoucherAmount], [DueDate], 
                                            [IsPaymentApproved], [CompanyKey], [StatusKey],CreateDate,CreateUserKey,
                                            PmtApprovedUser,DriverNote,InternalNote )
			SELECT DISTINCT                 @VoucherNo,GETDATE(),AD.AddrKey,0,NULL,
                                            0,1,@VoucherStatus,	GETDATE(),@UserKey,
                                            NULL,'',''
			FROM [Routes] RT 
				INNER JOIN  dbo.OrderHeader OH	ON OH.OrderKey=RT.OrderKey
				INNER JOIN  dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
				INNER JOIN  dbo.[Address] AD	ON AD.AddrKey=DR.AddrKey			
			WHERE RT.DriverKey = @DriverKey;
            SET @ReturnedVoucherKey=( SELECT SCOPE_IDENTITY() ) ;             

            Update DriverVoucher SET LinkedVoucherKey=@ReturnedVoucherKey WHERE DriverVoucherKey=@DriverVoucherKey
            INSERT INTO RouteVouchers
            VALUES(@RouteKey,@ReturnedVoucherKey)
            --end          

			--AUDITLOG FOR INSERT
			DECLARE @UserName varchar(100), @Comments varchar(500),@OrderDetailKey varchar(100);
			
			SELECT  TOP 1 @OrderDetailKey=OrderDetailKey from OrderDetail where ContainerNo=@ContainerNo;

			SELECT @UserName=UserName from [User] where UserKey=@CreateUser;
			SET @Comments = 'Driver Voucher Entry ' + @DriverVoucherNumber  + ' created by '  +  @UserName;

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			VALUES (GETDATE(),@UserName,'DriverVoucher',@ContainerNo, @OrderDetailKey,NULL,'Text', @Comments);

        END
        ELSE
        BEGIN
            SELECT @ReturnedVoucherKey = LinkedVoucherKey
            FROM DriverVoucher
            WHERE DriverVoucherKey = @DriverVoucherKey;

            IF @ReturnedVoucherKey = NULL
            BEGIN 
                Set @Status = 0;
                set @Reason = '@ReturnedVoucherKey is null';
            END

            -- Update existing voucher
            UPDATE DriverVoucher
            SET 
                DriverVoucherdate   = @DriverVoucherdate,
                ContainerNo         = @ContainerNo,
                DriverVoucherAmount = @DriverVoucherAmount,
                DriverKey           = @DriverKey,
                UpdateDate          = GETDATE(),
                UpdateUser          = @CreateUser,
                WeekNumber          = @WeekNumber
            WHERE DriverVoucherKey = @DriverVoucherKey;

			---AUDITLOG FOR UPDATE
			SELECT  TOP 1 @OrderDetailKey=OrderDetailKey from OrderDetail where ContainerNo=@ContainerNo;
				
			SELECT @UserName = UserName FROM [User] WHERE UserKey = @CreateUser;

			SELECT @DriverVoucherNumber = DriverVoucherNumber FROM DriverVoucher WHERE DriverVoucherKey = @DriverVoucherKey;

			SET @Comments = 'Driver Voucher Entry  ' + @DriverVoucherNumber + ' updated by ' + @UserName;

			INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			VALUES( GETDATE(), @UserName, 'DriverVoucher', @ContainerNo, @OrderDetailKey, NULL, 'Text', @Comments);

            -- Verify update affected rows
            IF @@ROWCOUNT = 0
            BEGIN
                SET @Reason = 'Driver voucher not found for update';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

		--SELECT '#tempTable'
                --,*  -- Calculate ExtCost during insert
            --FROM #tempDeduction 
            --WHERE ISNULL(DriverVoucherLineKey,0) = 0;

        -- Process deduction details if we have a valid voucher key
        IF (@DriverVoucherKey > 0 AND EXISTS(SELECT 1 FROM #tempDeduction))
        BEGIN
            -- Insert new deduction records
            INSERT INTO DriverVoucherDetail (
                DriverVoucherKey, 
                ItemKey, 
                UnitCost, 
                Qty, 
                Remarks, 
                CreateUser, 
                CreateDate,
                ExtCost
            )
            SELECT 
                @DriverVoucherKey,
                ItemKey,
                UnitCost,
                Qty,
                Remarks,
                @UserKey,
                GETDATE(),
                UnitCost * Qty  -- Calculate ExtCost during insert
            FROM #tempDeduction 
            WHERE ISNULL(DriverVoucherLineKey,0) = 0;

            -- Update existing deduction records
            UPDATE dvd
            SET 
                ItemKey = tmp.ItemKey,
                UnitCost = tmp.UnitCost,
                Qty = tmp.Qty,
                Remarks = tmp.Remarks,
                ExtCost = tmp.UnitCost * tmp.Qty,  -- Recalculate ExtCost
                UpdateDate = GETDATE(),
                UpdateUser = @UserKey
            FROM DriverVoucherDetail dvd
            INNER JOIN #tempDeduction tmp ON dvd.DriverVoucherLineKey = tmp.DriverVoucherLineKey
            WHERE tmp.DriverVoucherLineKey > 0
            AND dvd.DriverVoucherKey = @DriverVoucherKey;

            
            --added for driver voucher voucher link
            INSERT INTO [dbo].[VoucherDetail]([Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost],RouteKey,Remarks,CreateDate,CreateUserKey,driverpay)
	        SELECT  @ReturnedVoucherKey,DVD.ItemKey,I.[Description],DVD.UnitCost,Qty,(Qty*DVD.UnitCost),@RouteKey, '',GETDATE(),@UserKey ,'P'
                FROM DriverVoucherDetail DVD
                INNER JOIN Item I ON I.ItemKey=DVD.ItemKey
                WHERE DriverVoucherKey=@DriverVoucherKey AND DVD.ItemKey Not IN (SELECT ItemKey FROM VoucherDetail WHERE VoucherKey=@ReturnedVoucherKey)

	        UPDATE dbo.VoucherHeader
	        SET VoucherAmount=(  SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WHERE VoucherKey=@ReturnedVoucherKey ),
	        UpdateuserKey=@UserKey
	        WHERE VoucherKey= @ReturnedVoucherKey
            --end
            

            -- Recalculate total voucher amount
            DECLARE @TotalAmount DECIMAL(18,2);
            
            SELECT @TotalAmount = SUM(ExtCost)
            FROM DriverVoucherDetail 
            WHERE DriverVoucherKey = @DriverVoucherKey;

            -- Update main voucher with calculated total
            UPDATE DriverVoucher
            SET DriverVoucherAmount = ISNULL(@TotalAmount, 0)
            WHERE DriverVoucherKey = @DriverVoucherKey;

            -- Debug output for deductions
            IF @isDebug = 1
            BEGIN
                SELECT 'Debug - After Processing' AS Info, 
                       @DriverVoucherKey AS DriverVoucherKey,
                       @TotalAmount AS CalculatedTotal;
                
                SELECT * FROM DriverVoucherDetail 
                WHERE DriverVoucherKey = @DriverVoucherKey;
            END
        END

        -- Set success status
        SET @Status = 1;
        SET @Reason = 'Success';

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = 'Transaction failed: ' + ERROR_MESSAGE();

        -- Optional: Log error details
        IF @isDebug = 1
        BEGIN
            SELECT 
                ERROR_NUMBER() AS ErrorNumber,
                ERROR_SEVERITY() AS ErrorSeverity,
                ERROR_STATE() AS ErrorState,
                ERROR_PROCEDURE() AS ErrorProcedure,
                ERROR_LINE() AS ErrorLine,
                ERROR_MESSAGE() AS ErrorMessage;
        END
    END CATCH

    -- Cleanup
    IF OBJECT_ID('tempdb..#tempDeduction') IS NOT NULL
        DROP TABLE #tempDeduction;

END
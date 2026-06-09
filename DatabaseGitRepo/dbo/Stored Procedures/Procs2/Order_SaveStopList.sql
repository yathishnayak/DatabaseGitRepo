/*
Create a proc to save the OrderWise Stops. Proc Name: Order_SaveStopList
Standard json input and output 
Check whether orderstopkey exists. IF exists, update, otherwise create.
*/
/*

DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='',@Status BIT=0,@IsDebug		BIT = 1, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
set @JSONString = '[{"StopTypeKey":1,"StopTypeName":"Ship From","StopTypeShortcode":"SF","StopName":"UNK---","StopAddrKey":25573,"StopAddress":"UNK---","AddressLine1":".","AddressLine2":"","City":"","State":"","ZipCode":"","Country":"   ","StopNumber":1,"LocationType":"Consignee","StatusKey":1,"IsFoundationStop":true,"OrderBy":1,"CreateDate":"2024-12-26T06:21:47.660","OrderKey":142791,"CreateUserName":"Shiva Prasad","OrderStopKey":100341},{"StopTypeKey":2,"StopTypeName":"Added Stops","StopTypeShortcode":"AF","IsFoundationStop":false,"OrderBy":2,"OrderKey":142791,"CreateUserName":"Shiva Prasad"},{"StopTypeKey":3,"StopTypeName":"Ship To","StopTypeShortcode":"ST","StopName":"WESTERN GROUP PACKAGING","StopAddrKey":42274,"StopAddress":"WESTERN GROUP PACKAGING","AddressLine1":"3010 E Alexander Rd","AddressLine2":"","City":"Las Vegas","State":"NV","ZipCode":"89115","Country":"USA","StopNumber":2,"LocationType":"Consignee","StatusKey":1,"IsFoundationStop":true,"OrderBy":3,"CreateDate":"2024-12-26T06:37:17.193","OrderKey":142791,"CreateUserName":"Shiva Prasad","OrderStopKey":200923},{"StopTypeKey":4,"StopTypeName":"Added Stops","StopTypeShortcode":"AT","IsFoundationStop":false,"OrderBy":4,"OrderKey":142791,"CreateUserName":"Shiva Prasad"},{"StopTypeKey":5,"StopTypeName":"Return To","StopTypeShortcode":"RT","IsFoundationStop":true,"OrderBy":5,"OrderKey":142791,"CreateUserName":"Shiva Prasad","StopName":"PACIFIC PACKAGING MACHINERY200 River Rd","City":"Corona","State":"CA","Country":"USA","StopAddrKey":34524}]'
Exec Order_SaveStopList @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Order_SaveStopList]
(
    @UserKey INT,
    @JSONString NVARCHAR(MAX) = '',
    @JsonOutput NVARCHAR(MAX) = '' OUTPUT,
    @Status BIT = 0 OUTPUT,
    @Reason VARCHAR(500) = '' OUTPUT,
    @IsDebug BIT = 0
)
AS
BEGIN
    BEGIN TRY
        -- Validate input
        IF ISNULL(@JSONString, '') = ''
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Invalid JSON input';
            RETURN;
        END;

        DECLARE 
            @OrderStopKey BIGINT,
            @OrderKey INT,
            @StopTypeKey SMALLINT,
            @StopName VARCHAR(100),
            @StopAddrKey INT,
            @StopNumber SMALLINT,
            @LocationType VARCHAR(20),
            @StatusKey SMALLINT,
            @CreateDate DATETIME,
            @CreateUserKey INT,
            @UpdateDate DATETIME,
            @UpdateUserKey INT,
            @IsDeleted BIT,
            @DeleteUserKey INT,
            @DeleteDate DATETIME;

        -- Parse JSON into a temporary table
        SELECT OrderStopKey, OrderKey, StopTypeKey, StopName, StopAddrKey, StopNumber,
               LocationType, StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey,
               IsDeleted, DeleteUserKey, DeleteDate
        INTO #Temp
        FROM OPENJSON(@JSONString)
        WITH (
            OrderStopKey	BIGINT			'$.OrderStopKey',
            OrderKey		INT				'$.OrderKey',
            StopTypeKey		SMALLINT		'$.StopTypeKey',
            StopName		VARCHAR(100)	'$.StopName',
            StopAddrKey		INT				'$.StopAddrKey',
            StopNumber		SMALLINT		'$.StopNumber',
            LocationType	VARCHAR(20)		'$.LocationType',
            StatusKey		SMALLINT		'$.StatusKey',
            CreateDate		DATETIME		'$.CreateDate',
            CreateUserKey	INT				'$.CreateUserKey',
            UpdateDate		DATETIME		'$.UpdateDate',
            UpdateUserKey	INT				'$.UpdateUserKey',
            IsDeleted		BIT				'$.IsDeleted',
            DeleteUserKey	INT				'$.DeleteUserKey',
            DeleteDate		DATETIME		'$.DeleteDate'
        );

		if (@IsDebug = 1)
		BEGIN
		SELECT * from #Temp
		END

        -- Cursor to iterate over parsed data
        DECLARE cur CURSOR FOR
        SELECT OrderStopKey, OrderKey, StopTypeKey, StopName,StopAddrKey,  StopNumber,
               LocationType, StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey,
               IsDeleted, DeleteUserKey, DeleteDate
        FROM #Temp;

        OPEN cur;

        FETCH NEXT FROM cur INTO @OrderStopKey, @OrderKey, @StopTypeKey, @StopName, @StopAddrKey,
                                     @StopNumber, @LocationType, @StatusKey, @CreateDate, @CreateUserKey,
                                     @UpdateDate, @UpdateUserKey, @IsDeleted, @DeleteUserKey, @DeleteDate;

		if (@IsDebug = 1)
		BEGIN
			SELECT @OrderStopKey as OrderStopKey
		END

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS (SELECT 1 FROM OrderStops WHERE OrderStopKey = @OrderStopKey)
            BEGIN
                -- Update existing record
                UPDATE OrderStops
                SET OrderKey = @OrderKey, StopTypeKey = @StopTypeKey, StopName = @StopName,
                    StopAddrKey = @StopAddrKey, StopNumber = @StopNumber,
                    LocationType = @LocationType, StatusKey = @StatusKey,
                    UpdateDate = GETDATE(), UpdateUserKey = @UserKey,
                    IsDeleted = @IsDeleted, DeleteUserKey = @DeleteUserKey, DeleteDate = @DeleteDate
                WHERE OrderStopKey = @OrderStopKey;

			Print '--------------Updated'
            END
            ELSE
            BEGIN
				if(isnull(@StopName ,'') <> '')
				Begin
					-- Insert new record
					INSERT INTO OrderStops ( OrderKey, StopTypeKey, StopName, StopAddrKey, StopNumber,
											LocationType, StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey,
											IsDeleted, DeleteUserKey, DeleteDate)
					VALUES ( @OrderKey, @StopTypeKey, @StopName, @StopAddrKey, @StopNumber,
							@LocationType, @StatusKey, GETDATE(), @UserKey, GETDATE(), @UserKey,
							@IsDeleted, @DeleteUserKey, @DeleteDate);
				END

			Print '--------------Inserted'
            END;

            FETCH NEXT FROM cur INTO @OrderStopKey, @OrderKey, @StopTypeKey, @StopName, @StopAddrKey,
                                     @StopNumber, @LocationType, @StatusKey, @CreateDate, @CreateUserKey,
                                     @UpdateDate, @UpdateUserKey, @IsDeleted, @DeleteUserKey, @DeleteDate;
        END;

		SET @JsonOutput = (
			    SELECT OrderStopKey, OrderKey, StopTypeKey, StopName, StopAddrKey, StopNumber,
			           LocationType, StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey,
			           IsDeleted, DeleteUserKey, DeleteDate
			    FROM OrderStops
			    WHERE OrderStopKey = @OrderStopKey
			    FOR JSON PATH
			);

        CLOSE cur;
        DEALLOCATE cur;

        DROP TABLE #Temp;

        -- Success status
        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        -- Error handling
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

		print ERROR_MESSAGE();

        IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
            DROP TABLE #Temp;

        IF CURSOR_STATUS('GLOBAL', 'cur') >= 0
        BEGIN
            CLOSE cur;
            DEALLOCATE cur;
        END;
    END CATCH;
END;

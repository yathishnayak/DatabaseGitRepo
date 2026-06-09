
/*
DECLARE @UserKey  INT=1144,  
	@JsonString  NVARCHAR(MAX)='{"OrderDetailKey":224307,"RouteKey":722334}',  
	@IsDebug        BIT = 1,  
	@Status         BIT = 0 ,  
	@Reason         VARCHAR(1000) = '' 

EXEC [Dispatch_DeleteInvalidRoute_V2] @UserKey,@JsonString,@IsDebug,@Status output,@Reason output
SELECT @Status AS Status, @Reason AS Reason 
	*/
CREATE PROCEDURE [dbo].[Dispatch_DeleteInvalidRoute_V2]
(
    @UserKey      INT = 0,
    @JsonString   NVARCHAR(MAX) = '',
    @IsDebug      BIT = 1,
    @Status       BIT = 0 OUTPUT,
    @Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF ISNULL(@JsonString, '') = ''
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Parameter not found';
            RETURN;
        END

        DECLARE 
            @OrderDetailKey      INT = 0,
            @RouteKey            INT = 0,
            @FromLocation        NVARCHAR(100) = '',
            @ToLocation          NVARCHAR(100) = '',
            @MappingRouteKey     INT = 0,
            @UserName            VARCHAR(100),
            @Comment             VARCHAR(500) = '',
            @ContainerNo         NVARCHAR(20) = '',
            @ExpenseCount        INT = 0;

        SELECT  
            @OrderDetailKey = OrderDetailKey,
            @RouteKey = RouteKey
        FROM OPENJSON(@JsonString)
        WITH(
            OrderDetailKey INT,
            RouteKey INT
        );

        IF NOT EXISTS (SELECT 1 FROM Routes WHERE RouteKey = @RouteKey)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Route does not exist';
            RETURN;
        END

        SELECT @ExpenseCount = COUNT(*) 
        FROM OrderExpense 
        WHERE RouteKey = @RouteKey;

        SELECT @UserName = ISNULL(UserName, '') 
        FROM [User] WITH(NOLOCK) 
        WHERE UserKey = @UserKey;

        SELECT @ContainerNo = ISNULL(ContainerNo, '') 
        FROM OrderDetail WITH(NOLOCK) 
        WHERE OrderDetailKey = @OrderDetailKey;

        SELECT 
            @FromLocation = L.FromLocation,
            @ToLocation = L.ToLocation
        FROM Leg L WITH(NOLOCK)
        INNER JOIN Routes RT WITH(NOLOCK) 
            ON RT.LegKey = L.LegKey
        WHERE RT.RouteKey = @RouteKey;

        BEGIN TRANSACTION;

        IF @ExpenseCount > 0
        BEGIN
            SELECT TOP 1 @MappingRouteKey = RT.RouteKey
            FROM Leg L WITH(NOLOCK)
            INNER JOIN Routes RT WITH(NOLOCK)
                ON RT.LegKey = L.LegKey
            WHERE RT.RouteKey <> @RouteKey
              AND L.FromLocation = @FromLocation
              AND L.ToLocation = @ToLocation
              AND RT.OrderDetailKey = @OrderDetailKey
            ORDER BY RT.RouteKey DESC;

            IF ISNULL(@MappingRouteKey, 0) = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SET @Status = 0;
                SET @Reason = 'No mapping route found. Cannot delete route with expenses.';
                RETURN;
            END

            UPDATE OrderExpense
            SET RouteKey = @MappingRouteKey
            WHERE RouteKey = @RouteKey;
        END

        SET @Comment = 'Leg ' + ISNULL(@FromLocation,'') + 
                       ' To ' + ISNULL(@ToLocation,'') + ' Deleted';

        INSERT INTO AuditLogDetail
        (
            DateCreated, CreateUser, RefType, RefId,
            RefKey, Stage, CommentType, Comments
        )
        VALUES
        (
            GETDATE(), @UserName, 'Container', @ContainerNo,
            @OrderDetailKey, 'Leg', 'Text', @Comment
        );

        DELETE FROM Routes 
        WHERE RouteKey = @RouteKey;

        COMMIT TRANSACTION;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END

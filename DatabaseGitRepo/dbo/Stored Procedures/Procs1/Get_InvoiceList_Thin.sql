

CREATE   PROCEDURE [dbo].[Get_InvoiceList_Thin]
(
    @UserKey INT = 714,
    @JSONString NVARCHAR(MAX),
    @Status BIT OUTPUT,
    @Reason VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@JSONString,'') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    DECLARE
        @StatusKey INT = 0,
        @OrderKey INT = 0,
        @CustomerKey VARCHAR(MAX) = '',
        @InvoiceNo VARCHAR(50) = '',
        @SearchText VARCHAR(50) = '',
        @PageNo INT = 1,
        @PageSize INT = 10,
        @SortField VARCHAR(50) = 'TerminationDate',
        @IsAscending BIT = 1;

    SELECT *
    FROM OPENJSON(@JSONString)
    WITH (
        StatusKey INT '$.StatusKey',
        OrderKey INT '$.OrderKey',
        CustomerKey VARCHAR(MAX) '$.CustomerKey',
        InvoiceNo VARCHAR(50) '$.InvoiceNo',
        SearchText VARCHAR(50) '$.SearchText',
        PageNo INT '$.PageNo',
        PageSize INT '$.PageSize',
        SortField VARCHAR(50) '$.SortField',
        IsAscending BIT '$.IsAscending'
    );

    ;WITH Filtered AS (
        SELECT *
        FROM dbo.vw_InvoiceBaseData V
        WHERE
            (@OrderKey = 0 OR V.OrderKey = @OrderKey)
        AND (@StatusKey = 0 OR V.StatusKey = @StatusKey)
        AND (@InvoiceNo = '' OR V.InvoiceNo LIKE @InvoiceNo + '%')
        AND (@CustomerKey = '' OR EXISTS (
                SELECT 1
                FROM STRING_SPLIT(@CustomerKey, ',') s
                WHERE TRY_CAST(s.value AS INT) = V.CustKey
            ))
        AND (@SearchText = '' OR
             V.OrderNo LIKE '%' + @SearchText + '%' OR
             V.ContainerNo LIKE '%' + @SearchText + '%' OR
             V.InvoiceNo LIKE '%' + @SearchText + '%' OR
             V.CustName LIKE '%' + @SearchText + '%')
    )
    SELECT
        InvoiceList = (
            SELECT *
            FROM (
                SELECT *,
                       COUNT(*) OVER() AS RecCount,
                       ROW_NUMBER() OVER (
                         ORDER BY
                           CASE WHEN @SortField='TerminationDate' AND @IsAscending=1 THEN TerminationDate END ASC,
                           CASE WHEN @SortField='TerminationDate' AND @IsAscending=0 THEN TerminationDate END DESC,
                           OrderNo
                       ) AS RowNum
                FROM Filtered
            ) X
            WHERE RowNum BETWEEN ((@PageNo-1)*@PageSize+1) AND (@PageNo*@PageSize)
            FOR JSON PATH
        )
    FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';
END

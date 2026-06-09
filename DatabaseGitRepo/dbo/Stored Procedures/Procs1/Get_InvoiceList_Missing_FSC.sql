/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_InvoiceList_Missing_FSC] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_InvoiceList_Missing_FSC]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        ;WITH InvoiceBase AS (
            SELECT IH.InvoiceKey, IH.InvoiceNo, IH.StatusKey, IH.InvoiceDate,
                (SELECT TOP 1 ID.OrderDetailKey FROM dbo.InvoiceDetail ID WHERE ID.InvoiceKey = IH.InvoiceKey) AS OrderDetailKey
            FROM dbo.InvoiceHeader IH
            WHERE IH.StatusKey = 1  -- In progress
        )

        SELECT *
        FROM (
            SELECT 
                IH.InvoiceKey,
                IH.InvoiceNo,
                IH.StatusKey,
                IH.InvoiceDate,
                OD.OrderDetailKey,

                -- Has Dray Base
                CASE WHEN EXISTS (
                    SELECT 1 FROM dbo.InvoiceDetail ID WHERE ID.InvoiceKey = IH.InvoiceKey AND ID.ItemKey = 18
                ) THEN 1 ELSE 0 END AS HasDrayBase,

                -- Has FSC
                CASE WHEN EXISTS (
                    SELECT 1 FROM dbo.InvoiceDetail ID WHERE ID.InvoiceKey = IH.InvoiceKey AND ID.ItemKey = 17
                ) THEN 1 ELSE 0 END AS HasFSC,

                -- Has OTR
                CASE WHEN EXISTS (
                    SELECT 1 FROM dbo.InvoiceContainers IC
                    INNER JOIN dbo.vContainerType VCT ON VCT.OrderDetailKey = IC.OrderDetailsKey
                    WHERE IC.InvoiceKey = IH.InvoiceKey AND VCT.ContainerTypeKey = 9
                ) THEN 1 ELSE 0 END AS HasOTR

            FROM InvoiceBase IH

            OUTER APPLY (
                SELECT TOP 1 ID.OrderDetailKey
                FROM dbo.InvoiceDetail ID
                WHERE ID.InvoiceKey = IH.InvoiceKey
            ) OD

            WHERE (
                -- Condition 1: Has DrayBase (18), NOT Has FSC (17) and NOT OTR
                EXISTS(SELECT 1 FROM dbo.InvoiceDetail ID WHERE ID.InvoiceKey = IH.InvoiceKey AND ID.ItemKey = 18)
                AND NOT EXISTS(SELECT 1 FROM dbo.InvoiceDetail ID2 WHERE ID2.InvoiceKey = IH.InvoiceKey AND ID2.ItemKey = 17)
                AND NOT EXISTS(
                    SELECT 1 FROM dbo.InvoiceContainers IC
                    INNER JOIN dbo.vContainerType VCT ON VCT.OrderDetailKey = IC.OrderDetailsKey
                    WHERE IC.InvoiceKey = IH.InvoiceKey AND VCT.ContainerTypeKey = 9
                )
            )
            OR (
                -- Condition 2: Has DrayBase (18), NOT Has FSC (17) and HAS OTR (9)
                EXISTS(SELECT 1 FROM dbo.InvoiceDetail ID WHERE ID.InvoiceKey = IH.InvoiceKey AND ID.ItemKey = 18)
                AND NOT EXISTS(SELECT 1 FROM dbo.InvoiceDetail ID2 WHERE ID2.InvoiceKey = IH.InvoiceKey AND ID2.ItemKey = 17)
                AND EXISTS(
                    SELECT 1 FROM dbo.InvoiceContainers IC
                    INNER JOIN dbo.vContainerType VCT ON VCT.OrderDetailKey = IC.OrderDetailsKey
                    WHERE IC.InvoiceKey = IH.InvoiceKey AND VCT.ContainerTypeKey = 9
                )
            )
        ) A
        ORDER BY A.InvoiceNo
        FOR JSON PATH;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END

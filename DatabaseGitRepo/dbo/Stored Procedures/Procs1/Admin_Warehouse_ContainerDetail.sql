
/*
DECLARE 
	@UserKey INT = 897,
	@JSONString NVARCHAR(MAX) = '{"ContainerNo":"ZMOU8851717"}',
	@Status BIT = 0, 
	@Reason VARCHAR(100) = '',
	@JSONOutput NVARCHAR(MAX) = '';
 
EXEC [Admin_Warehouse_ContainerDetail] 
	@UserKey = @UserKey,@JSONString = @JSONString,@JSONOutput = @JSONOutput OUTPUT,@Status = @Status OUTPUT,@Reason = @Reason OUTPUT;
 
SELECT @Status , @Reason;
*/

CREATE Procedure [dbo].[Admin_Warehouse_ContainerDetail]
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT ,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(100) = ''  OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @ContainerNo VARCHAR(30);

	SELECT @ContainerNo=ContainerNo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			ContainerNo	VARCHAR(100)		'$.ContainerNo'
		)
	
	IF @ContainerNo IS NULL 
    BEGIN
        SET @Status=0;
        SET @Reason='Data Not Found';
        RETURN;
    END
	
	ELSE
	BEGIN
		SELECT WC.OrderDetailKey,WC.ContainerMode,WC.PalletCount,WC.InDate,WC.OutDate,WC.StatusKey,WS.[Description] [Status],WC.CreateDate,WC.UpdateDate from OrderDetail OD
		INNER JOIN Warehouse_ContainerDetails WC ON OD.OrderDetailKey=WC.OrderDetailKey 
		INNER JOIN WarehouseStatus WS ON WS.StatusKey=WC.StatusKey  WHERE ContainerNo=@ContainerNo
		for JSON PATH
	END 

	SET @Status = 1;
    SET @Reason = 'Success';
END

/*
DECLARE 
    @Status BIT  = 0,
    @Reason VARCHAR(10) = ''


EXEC Integration_DocumentGet 954,'{"ContainerNo":"HLBU1284040"}',@Status OUTPUT,@Reason OUTPUT

SELECT @Status AS Status_,@Reason AS Reason 


*/


CREATE PROC [dbo].[Integration_DocumentGet](
	@UserKey INT,
	@JSONString NVARCHAR(MAX),
	@Status BIT OUTPUT,
	@Reason VARCHAR(10) OUTPUT
)
AS
BEGIN
	SET @Status = 1
	SET @Reason = ''

    DECLARE 
        @ContainerNo VARCHAR(20)

	IF(ISNULL(@JSONString,'') <> '')
		BEGIN
			SET @ContainerNo = JSON_VALUE(@JSONString,'$.ContainerNo')
		END

    SET @ContainerNo = ISNULL(@ContainerNo,'')

	SELECT 
		ContainerNo,
		NULL AS OrderNo,
		OrderKey,
		OrderDetailkey,
		StopKey,
		DocumentType,
		Id,
		IsSuccess,
		RequestSent,
		ResponseReceived,
		CreatedDate
	FROM
		Integration_DocumentUpload
    WHERE 
        --CreatedDate  > GETDATE() - 2 AND 
        (CASE 
            WHEN @ContainerNo = '' THEN '' 
            ELSE ContainerNo 
        END) = @ContainerNo
	ORDER BY 
		DocKey DESC
	FOR JSON PATH, INCLUDE_NULL_VALUES

END

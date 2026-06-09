/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_MasterCustomerList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_MasterCustomerList_V2]
(	
	@UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0	
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Status = 1;
	SET @Reason = 'Success';

	SELECT CustKey,CustID,CustName FROM Customer WITH (NOLOCK)
	WHERE IsActive=1 AND IsDelete=0 AND IsMaster=1
	FOR JSON PATH;
END
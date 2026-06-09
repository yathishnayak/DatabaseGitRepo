/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Legs_FilteredLegList] @UserKey,@JSONString, @IsDebug, @Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Legs_FilteredLegList]  
(  
 @UserKey  INT=512,  
 @JsonString  VARCHAR(MAX)='',  
 @IsDebug  BIT = 1,  
 @Status   BIT = 0 OUTPUT,  
 @Reason   NVARCHAR(1000) = '' OUTPUT  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET FMTONLY OFF;  
 SET ARITHABORT ON;  
  
 SELECT LegKey,LegID,FromLocation,ToLocation  
 FROM [LegFiltered] WITH (NOLOCK)
 FOR JSON PATH  
  
 SET @Reason='Success'  
 SET @Status = 1  
END  
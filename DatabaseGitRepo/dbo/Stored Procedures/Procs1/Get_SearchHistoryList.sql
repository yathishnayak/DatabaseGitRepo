/*    

Declare @UserKey  INT=1133,    
 @JsonString  NVARCHAR(MAX)='{"ScreenKey":4}',    
 @IsDebug  BIT = 1,    
 @Status   BIT = 0 ,    
 @Reason   VARCHAR(1000) = ''         
 EXEC Get_SearchHistoryList @UserKey,@JsonString,@IsDebug,@Status output, @Reason output    
 select @Reason AS Reason,@Status AS Status 
    
*/ 
CREATE PROCEDURE [dbo].[Get_SearchHistoryList]
(    
    @UserKey       INT=512,    
    @JsonString    NVARCHAR(MAX)='',    
    @IsDebug       BIT = 1,    
    @Status        BIT = 0 OUTPUT,    
    @Reason        VARCHAR(1000) = '' OUTPUT    
)    
AS    
BEGIN    
    SET NOCOUNT ON;    
    SET FMTONLY OFF;    
    SET ARITHABORT ON;

    DECLARE @ScreenKey INT = 0;

    SELECT @ScreenKey = ScreenKey
    FROM OPENJSON(@JsonString, '$')
    WITH(
        ScreenKey      INT   '$.ScreenKey'
    )

    SELECT SearchID, SearchText, ScreenKey, SearchCriteriaKey
        FROM SearchHistoryList
        WHERE UserKey = @UserKey AND CreateDate >= DATEADD(HOUR, -48, GETDATE()) AND ScreenKey = @ScreenKey
        ORDER BY SearchID DESC
            FOR JSON PATH;

    DELETE FROM SearchHistoryList
        WHERE CreateDate < DATEADD(hour, -48, GETDATE());

    SET @Status=1;    
    SET @Reason='Success'; 

 END
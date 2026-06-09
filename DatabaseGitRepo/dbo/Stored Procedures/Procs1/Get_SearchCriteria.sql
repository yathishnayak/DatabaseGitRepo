/*    
     
Declare @UserKey  INT=952,    
 @JsonString  VARCHAR(MAX)='{"ShortCode":"Scheduler"}',     
 @Status   BIT = 0 ,    
 @Reason   NVARCHAR(1000) = ''     
    
 EXEC Get_SearchCriteria @UserKey,@JsonString,@Status OUTPUT, @Reason OUTPUT    
 select @Reason AS Reason,@Status AS Status
    
*/
CREATE PROC [dbo].[Get_SearchCriteria]  
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT	
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	SET @Status = 1
	SET @Reason = 'Success'

	DECLARE @ShortCode			NVARCHAR(50)
			--@SearchCriteriaKey		INT

	SELECT @ShortCode=ShortCode
	--,@SearchCriteriaKey=SearchCriteriaKey
	FROM OPENJSON(@JsonString, '$')
	WITH (
			ShortCode			NVARCHAR(50)		'$.ShortCode'--,
			--SearchCriteriaKey	INT		'$.SearchCriteriaKey'
		)

		SELECT SC.SearchCriteriaKey, SC.SearchCriteriaName
		FROM SearchCriteria SC WITH(NOLOCK)
		INNER JOIN LinkSearch LS WITH(NOLOCK)
			ON LS.SearchCriteriaKey = SC.SearchCriteriaKey
		INNER JOIN ScreenNames SN WITH(NOLOCK) 
			ON SN.ScreenKey = LS.ScreenKey
		WHERE SN.ShortCode =  @ShortCode
			--AND LS.SearchCriteriaKey = @SearchCriteriaKey
			FOR JSON PATH
END
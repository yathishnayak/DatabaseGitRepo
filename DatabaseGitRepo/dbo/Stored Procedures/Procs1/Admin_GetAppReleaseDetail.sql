
/*


DECLARE 
	@Status		BIT	= 0		,
	@IntError	VARCHAR(500) = '',
	@Reason		VARCHAR(500) = ''

exec Admin_GetAppReleaseDetail @Status,@IntError,@Reason,954,''

SELECT 
	@Status		,
	@IntError	,
	@Reason		


select * from DA_AppReleaseDetail
select * from [User]

*/


CREATE PROC [dbo].[Admin_GetAppReleaseDetail](
	@Status		BIT				OUTPUT	,
	@IntError	VARCHAR(500)	OUTPUT	,
	@Reason		VARCHAR(500)	OUTPUT	,
	@UserKey	INT						,
	@JSONString NVARCHAR(MAX)
)
AS BEGIN

	SET FMTONLY OFF
	SET NOCOUNT ON

	SET @Status = 1
	SET @IntError = ''
	SET @Reason = ''

	SELECT
		AppVersion					,
		ReleaseDate					,
		[Description]				,
		U.UserName		AS CreatedBy,
		CreatedDate		
	FROM 
		DA_AppReleaseDetail A INNER JOIN [User] U 
			ON A.CreatedBy = U.UserKey
	FOR JSON PATH
END

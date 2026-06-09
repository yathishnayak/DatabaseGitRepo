/*


DECLARE 
	@Status		BIT	= 0		,
	@IntError	VARCHAR(500) = '',
	@Reason		VARCHAR(500) = ''

EXEC Admin_InsertAppReleaseDetail @Status,@IntError,@Reason,954,'[{"AppVersion":"1.0.0","ReleaseDate":"2025-05-19 00:56:26.220","Description":" test description ... .. .","CreatedBy":954}]'

SELECT 
	@Status		,
	@IntError	,
	@Reason		


*/
CREATE PROC [dbo].[Admin_InsertAppReleaseDetail](
	@Status		BIT				OUTPUT	,
	@IntError	VARCHAR(500)	OUTPUT	,
	@Reason		VARCHAR(500)	OUTPUT	,
	@UserKey	INT						,
	@JSONString NVARCHAR(MAX)
) AS BEGIN

	SET FMTONLY OFF
	SET NOCOUNT ON
	
	DECLARE 
		@AppVersion		VARCHAR(50),
		@ReleaseDate	DATETIME,
		@Description	NVARCHAR(MAX),
		@CreatedBy		INT

		BEGIN TRANSACTION
	BEGIN TRY
		

		SELECT 
			@AppVersion		= t_AppVersion	,
			@ReleaseDate	= t_ReleaseDate	,
			@Description	= t_Description	,
			@CreatedBy		= t_CreatedBy	
		FROM 
			OPENJSON(@JSONString,'$')
			WITH(
				t_AppVersion		VARCHAR(50)		'$.AppVersion',
				t_ReleaseDate		DATETIME		'$.ReleaseDate',
				t_Description		NVARCHAR(MAX)	'$.Description',
				t_CreatedBy			INT				'$.CreatedBy'
			)

		
		INSERT INTO DA_AppReleaseDetail
			(AppVersion,ReleaseDate,[Description],CreatedBy,CreatedDate)
		VALUES
			(@AppVersion,@ReleaseDate,@Description,@CreatedBy,GETDATE())

		COMMIT TRANSACTION

		SET @Status = 1
		SET @IntError = ''
		SET @Reason = ''

		SELECT ''

	END TRY
	BEGIN CATCH
		
		ROLLBACK TRANSACTION

		SET @Status = 0
		SET @IntError = ERROR_MESSAGE()
		SET @Reason = 'DB ERROR'

	END CATCH
END

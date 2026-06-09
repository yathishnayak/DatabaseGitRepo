

Create procedure [dbo].[CollectionStatuCode_Get]
AS
	BEGIN
		SELECT StatusCodeKey,StatusCodeName,IsActive,IsDelete,CreatedDate,CreatedUser
		FROM CollectionStatuCode
		FOR JSON PATH
	END

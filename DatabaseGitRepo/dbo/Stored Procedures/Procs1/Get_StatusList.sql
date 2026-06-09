
CREATE PROCEDURE [dbo].[Get_StatusList]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT [StatusKey]
      ,[StatusName]
      ,[CompanyKey]
      ,[IsActive]
      ,[CreateDate]
      ,[Type]
  FROM [dbo].[Status]
END

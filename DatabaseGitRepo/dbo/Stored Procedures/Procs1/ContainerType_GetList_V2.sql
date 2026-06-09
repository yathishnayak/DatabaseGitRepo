CREATE PROCEDURE [dbo].[ContainerType_GetList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	SET @Reason='Success';
	SET @Status=1
	SELECT CT.ContainerTypeKey,CT.ShortCode TypeDescription, --Ct.TypeDescription
			CT.LinkedItemKey,TypeID,ColorCode
			FROM ContainerTypes CT WITH (NOLOCK)
			ORDER BY OrderBy ASC
			FOR JSON PATH
END

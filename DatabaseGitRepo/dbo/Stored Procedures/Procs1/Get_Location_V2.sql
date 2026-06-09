/*
DECLARE 
	@UserKey INT,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT=0, @Debug int = 0,@Reason VARCHAR(100)=''
EXec [Get_Location_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_Location_V2]
(
	@UserKey		int = 1144,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Country,[State],City, ZipCode,CityKey
	FROM dbo.LocationData A WITH (NOLOCK)
		INNER JOIN dbo.[Status] S WITH (NOLOCK) ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND A.IsActive= 1
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END
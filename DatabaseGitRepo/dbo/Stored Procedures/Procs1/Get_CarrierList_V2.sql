CREATE PROCEDURE [dbo].[Get_CarrierList_V2]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	SET @Status=1;
	SET @Reason='Success';
	DECLARE @MarketLocationKey	INT= 1, @IsActive	BIT=0, @StatusKey INT=0

	SELECT @IsActive = IsActve, @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			
			IsActve				BIT		'$.IsActve',
			MarketLocationKey	INT     '$.MarketLocationKey'
		)

	SET @StatusKey = CASE WHEN @IsActive=1 THEN 1 
		WHEN @IsActive=0 THEN 2 ELSE 0 END

	SET @JSONOutput = (	SELECT Driverkey , DriverId , FirstName,LastName, OrgName, 
						STUFF((SELECT distinct ', ' + CMT.MoveTypeName
						 from CarrierMoveType CMT
						 INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1
						 where D.DriverKey = DM.DriverKey
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') 
						,1,2,'') MoveTypes,
						TruckTypeKey,MarketLocationKey
						FROM Driver D
						WHERE (@StatusKey=0 OR StatusKey=@StatusKey) AND 
							  (@MarketLocationKey=0 OR MarketLocationKey=@MarketLocationKey)
						FOR JSON PATH)
	SELECT @JSONOutput

END

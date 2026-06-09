/*
	DECLARE 
	@UserKey INT= 897,
	@JSONString NVARCHAR(MAX)='{"ContainerNo":"CAIU9312275"}',
	@Status  BIT=0,
	@Reason VARCHAR(100)='',
	@IsDebug  BIT=0
	EXEC [Admin_Container_RouteDetails] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
	Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Admin_Container_RouteDetails]
(
	@UserKey INT,
	@JSONString NVARCHAR(MAX)='',
	@Status  BIT=0 OUTPUT,
	@Reason VARCHAR(1000)='' OUTPUT,
	@IsDebug  BIT=0
)
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET @IsDebug=0

	Declare @ContainerNo VARCHAR(100),
			@JsonOutput NVARCHAR(MAX)=''

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END
	

	SELECT @ContainerNo=ContainerNo 
	FROM OPENJSON(@JsonString, '$')
	WITH (
		ContainerNo	VARCHAR(100)		'$.ContainerNo'
		)

	IF(@IsDebug=1)
	BEGIN
			SELECT 'Parmaters ' AS Params,
			@ContainerNo AS ContainerNo
	END

	--Select 'print', @Status

	SET @JsonOutput=(SELECT OH.OrderNo, OD.OrderDetailKey,OD.OrderKey ,OD.ContainerNo,OH.OrderDate,
						LegDetails = (Select L.LegID,L.LegNo,L.LegType,L.CreateDate,L.UpdateDate,L.FromLocation,L.ToLocation, RT.RouteKey, OD.OrderDetailKey FROM Routes RT 
						INNER JOIN Leg L 
						ON L.LegKey=RT.LegKey and RT.OrderDetailKey=OD.OrderDetailKey for json path)
						FROM OrderDetail OD
						INNER JOIN OrderHeader OH ON OD.OrderKey=OH.OrderKey 
						WHERE ContainerNo=@ContainerNo 
					for json path )

	SET @JsonOutput=CASE WHEN @JsonOutput IS NULL THEN '' ELSE @JsonOutput END
	select @JsonOutput as JSONOutput
	SET @Status =1
	SET @Reason='Success'
	SET ARITHABORT OFF;

	--Select @Status Status, @Reason Reason
END

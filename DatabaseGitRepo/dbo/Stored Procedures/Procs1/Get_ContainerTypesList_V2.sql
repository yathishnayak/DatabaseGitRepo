/**
DECLARE 
	@UserKey INT=29,
	@JSONString NVARCHAR(MAX)='{"OrderDetailKey":302884}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_ContainerTypesList_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_ContainerTypesList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"OrderKey":104718,"OrderDetailKey":0}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	declare @OrderKey			int,
			@OrderDetailKey		int

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SET @OrderKey = 0
		SET @OrderDetailKey = 0
	End
	ELSE
	Begin
		select @OrderKey = OrderKey, @OrderDetailKey =  OrderDetailKey
		from OpenJSON(@JsonString, '$')
		WITH (
			OrderKey				INT				'$.OrderKey',
			OrderDetailKey			INT				'$.OrderDetailKey'
		)
	END

	SELECT	PropsList = (
			Select CT.ContainerTypeKey,ct.ShortCode TypeDescription, ColorCode,IsStops, 
			IsOnlyLegs,IsOnlyStops,Ct.TypeDescription As FullDescription  --Ct.TypeDescription
			from ContainerTypes CT WITH (NOLOCK)
			ORDER BY OrderBy ASC
			FOR JSON PATH
			),
			OrderData = (
				Select distinct OH.OrderKey, OH.OrderNo, 
					ContainerData = (
						Select OD.OrderDetailKey, OD.ContainerNo, 
						ContainerProps = (
							Select CTL.ContainerTypeKey, Ct.TypeDescription
							From ContainerTypesLink CTL WITH (NOLOCK)
							inner join ContainerTypes CT WITH (NOLOCK) on CTL.ContainerTypeKey = CT.ContainerTypeKey
							Where OD.OrderDetailKey = CTL.OrderDetailKey
							FOR JSON PATH
						)
						From OrderDetail OD WITH(NOLOCK)
						WHERE 1 = 1 AND
							OD.orderKey = OH.OrderKey AND
							(ISNULL(@OrderDetailKey,0) = 0 OR OD.OrderDetailKey = @OrderDetailKey )
						FOR JSON PATH
						)
				from OrderHeader OH WITH(NOLOCK)
				LEFT join OrderDetail OD WITH (NOLOCK) on OH.ORderKey = OD.ORderKey
				WHERE (Isnull(@OrderKey,0) > 0 OR ISNULL(@OrderDetailKey,0) > 0) and 
					(Isnull(@OrderKey,0) = 0 OR OH.OrderKey = @OrderKey ) AND
					(ISNULL(@OrderDetailKey,0) = 0 OR OD.OrderDetailKey = @OrderDetailKey )
				FOR JSON PATH
		)
		FOR JSON PATH

		SET @Status = 1
		SET @Reason = 'Success'
END
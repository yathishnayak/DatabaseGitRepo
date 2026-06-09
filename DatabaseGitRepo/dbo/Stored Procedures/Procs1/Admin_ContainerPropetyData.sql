
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"ContainerNo":"UETU5925052"}'
SET	@IsDebug  = 0

EXEC [Admin_ContainerPropetyData] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

/*
DECLARE 
	@UserKey INT=953,
	@JSONString		NVARCHAR(MAX)=  '{"ContainerNo":"EMCU1454392  "}',
	@Status			BIT=0, 
	@IsDebug		BIT = 0, 
	@Reason			VARCHAR(100)='',
	@JSonOutput		NVARCHAR(MAX)=''
	EXec [Admin_ContainerPropetyData] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status, @Reason
	*/
CREATE procedure [dbo].[Admin_ContainerPropetyData]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	--@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	--@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	--@Result1		VARCHAR(1000)	= ''	OUTPUT,
	--@Result2		VARCHAR(1000)	= ''	OUTPUT,
	--@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@Reason		VARCHAR(100)	= ''	OUTPUT,
	@JSonOutput		NVARCHAR(MAX)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)
as
Begin

	Declare @ContainerNo VARCHAR(1000) = '',@JsonResult NVARCHAR(MAX) = ''

		SELECT	 @ContainerNo = ContainerNo
		FROM	 OPENJSON(@JSONString, '$')
				WITH(
						
						ContainerNo VARCHAR(1000)			'$.ContainerNo'
				)
		DECLARE @JSON NVARCHAR(MAX)

		--select @ContainerNo

		SELECT ContainerNo,Status,OrderDetailKey,OrderKey INTO #Container FROM OrderDetail WHERE ContainerNo = @ContainerNo

		--SELECT * FROM #Container;

		SELECT oh.OrderNo,oh.CreateDate,oh.Status AS OrderStatus,cn.ContainerNo,cn.Status as ContainerStatus,ct.TypeDescription As Description,cn.OrderDetailKey,cl.ContainerTypeKey,cn.orderKey
		INTO #Order
		FROM Orderheader oh
		inner join #Container cn on oh.OrderKey = cn.OrderKey
		inner join ContainertypesLink cl on cn.OrderDetailKey = cl.OrderDetailKey
		inner join ContainerTypes ct on cl.ContainerTypeKey = ct.ContainerTypeKey

		--select * from #Order

		
			SET @JsonResult =(
				SELECT * FROM #Order WITH(NOLOCK)
				For JSON PATH
				)
		
			SELECT @JsonResult AS JsonResult


	SET @Status = 1
	SET @Reason='Success'
	--SET @IntMessage = 'Success'
	--SET @ExtMessage = 'Success'

	DROP TABLE #Container
	DROP TABLE #Order
End

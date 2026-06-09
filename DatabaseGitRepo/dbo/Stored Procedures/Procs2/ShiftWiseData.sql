/*
DECLARE @UserKey INT=953,
	@JSONString NVARCHAR(MAX)='{}',@Status BIT=0,@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
Exec ShiftWiseData @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason
*/
CREATE PROCEDURE [dbo].[ShiftWiseData]
(
	@UserKey			INT,
	@JsonString			NVARCHAR(MAX) = '',
	@Status				BIT = 0 OUTPUT,
	@Reason				VARCHAR(500) = '' OUTPUT,
	@IsDebug			BIT = 0,
	@JsonOutput     NVARCHAR(MAX) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	--IF ISNULL(@JSONString, '') = ''
 --   BEGIN
 --       SET @Status = 0;
 --       SET @Reason = 'Invalid JSON input';
 --       RETURN;
 --   END;

	SELECT  EffectiveDate, ShiftName, OrderBy, SlotName,
		[From Port],[To Consignee],[To Port]
	INTO #Temp
	FROM (
		SELECT * FROM vShiftWiseCount A WITH (NOLOCK)
	) AS SourceTable
	PIVOT (
	SUM(cnt) FOR CountGroup in ([From Port],[To Consignee],[To Port])
	) AS PivotTable

	SELECT * FROM (
	SELECT EffectiveDate, ShiftName,'' AS SlotName, sum_FromPort, sum_ToConsignee, sum_ToPort,'S' AS 'RecType'
	FROM 
	(
		SELECT top 500 EffectiveDate, ShiftName, SUM([From Port]) AS sum_FromPort,
		SUM([To Consignee]) AS sum_ToConsignee, SUM([To Port]) AS sum_ToPort
		FROM #Temp
		group by EffectiveDate, ShiftName
		ORDER BY EffectiveDate, ShiftName
	) A
	UNION ALL
	SELECT EffectiveDate, ShiftName, slotName, [From Port], [To Consignee],[To Port], 'D'  FROM #Temp
	) A
	ORDER BY  EffectiveDate, ShiftName, RecType DESC
	FOR JSON PATH
	SET @Reason='succes';
	SET @Status=1;
	Drop table #temp
END

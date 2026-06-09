/**
DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='{"Date":"11/27/2024"}',@Status BIT=0,@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
Exec ShipInfra_GettimeSlotDisplay @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason

**/
CREATE PROC [dbo].[ShipInfra_GettimeSlotDisplay]
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT,
	@IsDebug			bit = 0
)
As
BEGIN

	IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid JSON input';
        RETURN;
    END;

	Declare @Date	varchar(20)
	SELECT @Date = JSON_Value(@JsonString, '$.Date')
	if (@IsDebug = 1)
	BEGIN
		SELECT @Date as dateParam
	END

	select substring(convert(varchar,100 + DatePart(HH, RT.ScheduledArrival)),2,2) + ':00' as timeName,
			case when L.ToLocation = 'Port' then 'From Port' else 'Inland' end as SlotType,
			count(1) cnt
	into #TempTimeSlots
	from Routes Rt
	Left join Leg L on RT.legkey = L.LegKey
	where RT.ScheduledArrival between convert(datetime, convert(varchar,rt.ScheduledArrival,101) + ' 00:00') and 
		convert(datetime, convert(varchar,rt.ScheduledArrival,101) + ' 23:59')
	and convert(varchar,rt.ScheduledArrival,101) = @Date
	group by DatePArt(HH, RT.ScheduledArrival), case when L.ToLocation = 'Port' then 'From Port' else 'Inland' end

	select Ts.shiftKey, S.ShiftName, TS.slotkey, Ts.slotName, BP.cnt as FromPortCnt, BI.cnt as InlandCnt
	from shiftTimeSlots TS
	inner join Shifts S on TS.shiftKey = Ts.shiftKey
	LEFT JOIN #TempTimeSlots BP on TS.slotName = BP.timeName and BP.SlotType = 'From Port'
	LEFT JOIN #TempTimeSlots BI on TS.slotName = BI.timeName and BI.SlotType = 'Inland'
	order by S.ShiftName, Ts.slotName
	FOR JSON PATH
	

	set @Status = 1
	SEt @Reason = 'Success'
	
END

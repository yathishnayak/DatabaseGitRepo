
CREATE Proc Gnosis_Integration_ProcessPendingDataJson
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @REcordKey		int,
			@GroupRecordID	varchar(50),
			@CreateDate		dateTime

	declare  _cursor cursor LOCAL FOR
	select distinct   DJ.recordkey, GroupRecordID, DJ.CreatedDate
	from Gnosis_Integration_ContainerDataJson DJ WITH (NOLOCK)
	left join Gnosis_Integration_Container GC  WITH (NOLOCK) on DJ.RecordKey = GC.RecordKey 
	where GC.RecordKey is null and DJ.GroupRecordID  in (
		SELECt distinct A.GroupRecordID
		FROm			(SELECT			GroupRecordID,  COUNT(*) ttt,MIN(CreatedDate) CreatedDate FROM Gnosis_Integration_ContainerDataJson
						GROUP BY		GroupRecordID ) A
		LEFT JOIN		(SELECt			GroupRecordID,COUNT(*) tt
						FROM			Gnosis_Integration_ContainerDataJson A  WITH (NOLOCK)
						INNER JOIN		Gnosis_Integration_Container  B  WITH (NOLOCK) ON A.RecordKey = B.RecordKey 
						GROUP BY		GroupRecordID) B ON A.GroupRecordID = B.GroupRecordID
		where b.tt is not null
	) order by CreatedDate 

	
	Open _cursor
	Fetch Next from _cursor into @RecordKey, @GroupREcordID, @CreateDate

	While @@FETCH_STATUS = 0
	Begin
		print '--------------------'
		print @RecordKey
		print @GroupRecordID
		Exec [Gnosis_Integration_Insert_ContainerData] @GroupREcordID
		Fetch Next from _cursor into @RecordKey, @GroupREcordID, @CreateDate
	end
	Close _cursor
	Deallocate _cursor
END

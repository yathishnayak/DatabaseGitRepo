/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' , @IsDebug		bit = 1
	set @JsonString = '{"OrderDetailKey":214690,"ContainerMode":"2","PalletCount":67567,"StatusKey":1,"PalletRestriction":"tetsh5","WHLocation":"dfu","DOWorkScope":"test3","SpecialInstruction":"tefj5","Sorting":3}'
	exec Charge_UpdateWarehouseContainerDetails @UserKey, @JSONString, @Status output, @Reason output, @IsDebug
	select @Status, @Reason
*/

CREATE  PROCEDURE [dbo].[Charge_UpdateWarehouseContainerDetails] -- Charge_UpdateWarehouseContainerDetails 0, 544
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;


	Declare 
		@OrderDetailKey				INT=0,
		@Count						int=0,
		@CurDate					DateTime,
		@ContainerNo				varchar(20) = ''

	set @CurDate = GetDate()

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	create table #Temp
	(
		OrderDetailKey		int	,
		ContainerMode		varchar	(2),
		PalletCount			int,
		ContainerSize		int	,
		InDate				datetime,
		OutDate				datetime,
		IsNoOutDate			bit	,
		TodaysDate			datetime,
		StorageDays			int,
		IsStoring			bit	,
		StatusKey			int,
		PalletRestriction   varchar(200),
		WHLocation		    nvarchar(200),        
		DOWorkScope			nvarchar(200),          
		SpecialInstruction	nvarchar(200),    
		[Priority]			int,
		Sorting				int
	)

	insert into #Temp (OrderDetailKey, ContainerMode, PalletCount,ContainerSize,
		InDate,OutDate,IsNoOutDate, StorageDays, IsStoring, StatusKey,PalletRestriction,WHLocation,DOWorkScope,SpecialInstruction,
		Priority,Sorting)
	Select OrderDetailKey, ContainerMode, PalletCount,ContainerSize,
		InDate,OutDate,IsNoOutDate, StorageDays, IsStoring, StatusKey,PalletRestriction,WHLocation,DOWorkScope,SpecialInstruction,
		Priority,Sorting
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			int				'$.OrderDetailKey',
		ContainerMode			varchar	(2)		'$.ContainerMode',
		PalletCount				int				'$.PalletCount',
		ContainerSize			int				'$.ContainerSize',
		InDate					datetime		'$.InDate',
		OutDate					datetime		'$.OutDate',
		IsNoOutDate				bit				'$.IsNoOutDate',
		StorageDays				int				'$.StorageDays',
		IsStoring				bit				'$.IsStoring',
		StatusKey				int				'$.StatusKey',
		PalletRestriction      varchar(200)		'$.PalletRestriction',
		WHLocation		       nvarchar(200)	'$.WHLocation',       
		DOWorkScope			   nvarchar(200)	'$.DOWorkScope',         
		SpecialInstruction	   nvarchar(200)	'$.SpecialInstruction',    
		[Priority]			   int				'$.Priority',
		Sorting				   int				'$.Sorting'
	)

	Update #Temp set StatusKey = CASE WHEN isnull(StatusKey,0) = 0 THEN 1 ELSE StatusKey END

	if(@IsDebug = 1)
	Begin
		select * from #Temp
	End

	if((Select count(1) from #Temp) = 0)
	Begin
		set @Status = 0
		set @Reason = 'No Record to Save'
	End

	Begin Try
		select @OrderDetailKey = OrderDetailKey from #temp
		select @Count = count(1) from Warehouse_ContainerDetails  WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
		SElect @ContainerNo = ContainerNo from OrderDetail  WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey

		if(@IsDebug = 1)
		Begin
			select  @OrderDetailKey as OrderDetailKey,
					@Count as Count,
					@ContainerNo as ContainerNo
		End


		if(@Count = 0)
		Begin
			insert into Warehouse_ContainerDetails (OrderDetailKey, ContainerMode, PalletCount, ContainerSize, 
				InDate, OutDate, IsNoOutDate, TodaysDate, StorageDays, IsStoring, StatusKey, CreateUserKey, CreateDate,
				PalletRestriction,WHLocation,DOWorkScope,SpecialInstruction,
				Priority,Sorting)
			select OrderDetailKey, ContainerMode, PalletCount, ContainerSize, 
				InDate, OutDate, IsNoOutDate, @CurDate, StorageDays, IsStoring, StatusKey, @UserKey, @CurDate,
				PalletRestriction,WHLocation,DOWorkScope,SpecialInstruction,
				Priority,Sorting
			from #Temp
			where isnull(ContainerMode,'') <> '' OR isnull(PalletCount,0) <> 0 OR
			isnull(InDate,'') <> ''
				--and  isnull(outdate,'') <> '' 
				OR ISNULL(IsStoring,'') <> ''




			insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
			select @CurDate, U.UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', 'Warehouse Container Details inserted'
			from Warehouse_ContainerDetails WCD WITH (NOLOCK)
			LEFT JOIN [USER] U WITH (NOLOCK) ON wcd.CreateUserKey = u.UserKey
			where isnull(ContainerMode,'') <> '' OR isnull(PalletCount,0) <> 0 OR
			isnull(InDate,'') <> ''
				OR  isnull(outdate,'') <> '' OR ISNULL(IsStoring,'') <> ''
	
		end 
		else
		Begin
			declare @Changetext varchar(max)
			set @Changetext = ''
			select @Changetext = 
				Case when isnull(WCD.ContainerMode,'') = isnull(T.ContainerMode,'') then '' 
					else ', Container Mode to : ' + isnull(T.ContainerMode,'') end +
				Case when isnull(WCD.PalletCount,0) = isnull(T.PalletCount,0) then '' 
					else ', PalletCount to : ' + convert(Varchar, isnull(T.PalletCount,0)) end +
				Case when isnull(WCD.InDate,'') = isnull(T.InDate,'') then '' 
					else ', InDate  to : ' + convert(varchar, isnull(T.InDate,''))  end+
				Case when isnull(WCD.IsNoOutDate,'') = isnull(T.IsNoOutDate,'') then '' 
					else ', IsNoOutDate  to : ' + convert(varchar,isnull(T.IsNoOutDate,0)) end +
				Case when isnull(WCD.IsStoring,0) = isnull(T.IsStoring,0) then '' 
					else ', IsStoring to : ' + convert(varchar, isnull(T.IsStoring,0)) end +
				Case when isnull(WCD.OutDate,'') = isnull(T.OutDate,'') then '' 
					else ', OutDate to : ' + convert(varchar,isnull(T.OutDate,'')) end +
				Case when isnull(WCD.StatusKey,'') = isnull(T.StatusKey,'') then '' 
					else ', Status to : ' + isnull(WS.Description,'')  end +
				Case when isnull(WCD.PalletRestriction,'') = isnull(T.PalletRestriction,'') then '' 
					else ', Pallet Restrictione to : ' + isnull(T.PalletRestriction,'') end + 
				Case when isnull(WCD.WHLocation,'') = isnull(T.WHLocation,'') then '' 
					else ', WH Location to : ' + isnull(T.WHLocation,'') end +
				Case when isnull(WCD.DOWorkScope,'') = isnull(T.DOWorkScope,'') then '' 
					else ', DO Work Scope to : ' + isnull(T.DOWorkScope,'') end +
				Case when isnull(WCD.SpecialInstruction,'') = isnull(T.SpecialInstruction,'') then '' 
					else ', Special Instruction to : ' + isnull(T.SpecialInstruction,'') end +
				Case when isnull(WCD.Priority,0) = isnull(T.Priority,0) then '' 
					else ', Priority to : ' + convert(Varchar, isnull(T.Priority,0)) end +
				Case when isnull(WCD.Sorting,0) = isnull(T.Sorting,0) then '' 
					else ', Sorting to : ' + convert(Varchar, isnull(T.Sorting,0)) end 
			from Warehouse_ContainerDetails WCD WITH (NOLOCK)
			inner join #Temp T on WCD.OrderDetailKey = T.OrderDetailKey
			LEFT join WarehouseStatus WS WITH (NOLOCK) on WCD.StatusKey = WS.StatusKey

			if(ISNULL(@Changetext,'') <> '')
			Begin
				insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
				select @CurDate, U.UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', @Changetext
				from Warehouse_ContainerDetails WCD WITH (NOLOCK)
				LEFT JOIN [USER] U WITH (NOLOCK) ON wcd.CreateUserKey = u.UserKey
			END

			update WCD SET
				OrderDetailKey= T.OrderDetailKey,
				ContainerMode = T.ContainerMode ,
				PalletCount   = T.PalletCount ,
				ContainerSize = T.ContainerSize, 
				InDate 		  = T.InDate ,
				OutDate 	  = T.OutDate ,
				IsNoOutDate   = T.IsNoOutDate ,
				StorageDays   = T.StorageDays ,
				IsStoring 	  = T.IsStoring ,
				StatusKey	  = T.StatusKey,
				UpdateUserKey = @UserKey,
				UpdateDate	  = @CurDate,
				PalletRestriction  = T.PalletRestriction,  
				WHLocation    = T.WHLocation,		         
				DOWorkScope	  = T.DOWorkScope,	         
				SpecialInstruction	= T.SpecialInstruction,  
				[Priority]			=T.Priority,
				Sorting         = T.Sorting
			from Warehouse_ContainerDetails WCD
			inner join #Temp T on WCD.OrderDetailKey = T.OrderDetailKey
		End

		update Warehouse_ContainerDetails set 
			StatusKey = 2, UpdateUserKey = @UserKey,
			UpdateDate = GetDate()
		where OrderDetailKey = @OrderDetailKey and IsStoring = 1 and StatusKey <> 3

		set @Status = 1
		set @Reason = 'SUCCESS'
	end try
	begin catch
		set @Status = 0
		set @Reason = 'ERROR IN PROC: ' + convert(varchar, ERROR_LINE()) + ' : ' + ERROR_MESSAGE()
	end catch
END



--select* from StgDriverDeductions	 

CREATE  procedure [dbo].[UTIL_ImportDriverDeductions]
as
Begin
	Declare @DriverId as  varchar(20)
	Declare @DriverVoucherKey int 
	Declare @DriverKey as int
	Declare @DriverVoucherdate date
	Declare @DriverVoucherAmount decimal(18,2)
	Declare @TotalQTy decimal(18,2)
	Declare @OutPut bit
	Declare @ItemKey int
	Declare @CurDetl as cursor  
	Declare @RowKey as int  
	Declare @CreatedUser varchar(10)
	Declare @UnitCost as decimal(18,2)
	Declare @Remarks as varchar(255)
	
	Update A set DriverId  = B.DriverID from StgDriverDeductions  A
	inner join Driver B on ( right('000'+ A.VehicleNo,3) = 
	case when  CHARINDEX('-', B.DriverId) >1 then  right('00'+ left( B.DriverId,  CHARINDEX('-', B.DriverId)-1),3) else '' end)
	where  B.StatusKey=1

	set @CreatedUser='272'
	Declare @Cur as cursor 
	set @Cur = cursor for 
		select distinct DriverId from StgDriverDeductions where ProcessStatus=0
	Open @Cur
	While (0=0)
	Begin
		Fetch next from @Cur into @DriverId
		if @@FETCH_STATUS<>0 break
		set @DriverKey=null
		select @DriverKey  = DriverKey from Driver where DriverID = @DriverId
		set @DriverVoucherAmount=0
		set @TotalQTy=0
		select  @DriverVoucherdate = min(VoucherDate),  @DriverVoucherAmount=sum(isnull(Amount,0)) from StgDriverDeductions   
			where DriverId =@DriverId and  ProcessStatus=0

		set @DriverVoucherKey=0
		exec InsertUpdate_DriverVoucherDeduction @DriverVoucherKey = @DriverVoucherKey Output, @DriverVoucherdate= @DriverVoucherdate, 
			@DriverVoucherAmount=@DriverVoucherAmount, 
			@DriverKey=@DriverKey, @CreateUser=@CreatedUser, @OutPut = @OutPut OutPut
			
		if @DriverVoucherKey is not null
		Begin
			set @CurDetl  =  cursor for select Rowkey from  StgDriverDeductions where DriverId =@DriverId and  ProcessStatus=0
			open @CurDetl
			while (0=0)
			Begin
				fetch next from @CurDetl  into  @RowKey
				if @@FETCH_STATUS <> 0 break
				set @UnitCost=0
				set @Remarks=''
				select @UnitCost =  Amount/1,  @TotalQTy = 1,  @ItemKey = B.ItemKey, 
					@Remarks  =  ' Date: ' + Isnull(convert(Varchar(10),TranDate,101),'') +', Qty: ' +
					           Isnull(convert(Varchar,Quantity),'')  +  ', Loc: ' + Remarks 
					from StgDriverDeductions A
				left outer join Item B on (A.ItemId = B.ItemId)
				where RowKey = @RowKey
				
				exec  InsertUpdate_DriverVoucherDeductionDetail @DriverVoucherKey=@DriverVoucherKey,  
						@DriverVoucherLineKey = null, @ItemKey =@ItemKey, 
						@UnitCost = @UnitCost, @Qty =@TotalQTy, @Remarks =@Remarks,  @CreateUser=@CreatedUser,
						@OutPut = @OutPut OutPut
			End			
		End
		close @CurDetl
		deallocate @CurDetl
		update StgDriverDeductions set ProcessStatus=1 where DriverId =@DriverId and  ProcessStatus=0
	End
	close @Cur
	deallocate @Cur

End

-- [Get_AuditLogDetail] 'Voucher', 57129
-- [Get_AuditLogDetail] 'Container', 19743
CREATE Procedure [dbo].[Get_AuditLogDetail] 
(
	@RefType as Varchar(20),
	@RefKey as Int
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	declare @orderKey			int,
			@OrderDetailKey		int,
			@VoucherKey			int

	select AuditKey, 
		DateCreated, 
		CreateUser, 
		RefType, 
		RefId, 
		RefKey,
		Stage, 
		CommentType, 
		Comments 
	into #auditlog
	from [AuditLogDetail] 
	where RefType  = @RefType and RefKey = @RefKey
	
	if(@RefType = 'Container')
	begin
		set @OrderDetailKey = @RefKey

		select @orderKey = OH.OrderKey from OrderDetail OD with (NoLOCK)
		inner join OrderHeader OH with (NoLOCK) on OD.OrderKey = OH.OrderKey
		where OD.OrderDetailKey = @RefKey

		select RT.RouteKey
		into #Routes
		from OrderDetail OD with (nolock)
		inner join Routes RT with (nolock) on OD.OrderDetailKey = Rt.OrderDetailKey
		where OD.OrderDetailKey = @RefKey

		set identity_insert #auditlog on

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select Al.MainAuditLogKey, LogDate, isnull(U.UserName,''),  'Order', OH.OrderNo, OH.OrderKey, '', '', LogText
		from OrderHeader_AuditLog AL  with (nolock)
		inner join OrderHeader OH with (nolock) on AL.OrderKey = OH.OrderKey
		LEft join [User] U with (nolock) on AL.ActionUserKey = U.UserKey
		where AL.OrderKey = @orderKey

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select Al.MainAuditLogKey, LogDate, isnull(U.UserName,''),  'Container', OD.ContainerNo, OD.OrderDetailKey, '', '', LogText
		from OrderDetail_AuditLog AL  with (nolock)
		inner join OrderDetail OD with (nolock) on AL.OrderDetailKey = OD.OrderDetailKey
		LEft join [User] U with (nolock) on AL.ActionUserKey = U.UserKey
		where AL.OrderDetailKey = @OrderDetailKey

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select Al.MainAuditLogKey, LogDate, isnull(U.UserName,''),  'Legs', L.LegID, OD.OrderDetailKey, '', '', LogText
		from Routes_AuditLog AL  with (nolock)
		inner join Routes RT with (nolock) on Al.RouteKey = RT.RouteKey
		inner join Leg L with (nolock) on RT.LegKey = L.legkey
		inner join OrderDetail OD with (nolock) on RT.OrderDetailKey = OD.OrderDetailKey
		LEft join [User] U with (nolock) on AL.ActionUserKey = U.UserKey
		inner join #Routes R with (nolock) on AL.RouteKey = R.RouteKey

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select OH.OrderKey, OH.CreateDate, isnull(U.UserName,''),  'Order', OH.OrderNo, OH.OrderKey, '', '', 'Order ' + OH.OrderNo + ' Created'
		from OrderHeader OH
		LEft join [User] U with (nolock) on OH.CreateUserKey = U.UserKey
		where OrderKey = @orderKey

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select OD.OrderDetailKey, OD.CreateDate, isnull(U.UserName,''),  'Container', OD.ContainerNo, OD.OrderDetailKey, '', '', 
			'Container ' + Od.ContainerNo +' Added'
		from OrderDetail OD
		LEft join [User] U with (nolock) on OD.CreateUserKey = U.UserKey
		where OD.OrderDetailKey = @OrderDetailKey

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select OD.OrderDetailKey, RT.CreateDate, isnull(U.UserName,''),  'Legs', L.LegID, OD.OrderDetailKey, '', '', 
			'Leg : ' +L.LegID +' Added'
		from OrderDetail OD  with (nolock) 
		inner join Routes RT  with (nolock)  on OD.OrderDetailKey = RT.OrderDetailKey
		inner join Leg L  with (nolock)  on Rt.LegKey = L.LegKey
		LEft join [User] U with (nolock) on RT.CreateUserKey = U.UserKey
		inner join #Routes R with (nolock) on RT.RouteKey = R.RouteKey
		
		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select OD.OrderDetailKey,DT.CreateDate, isnull(U.UserName,'') as UserName, 'Legs',L.LegId, OD.OrderDetailKey,
		 '', '', 'Leg ' + L.Description + '  ' +
		Case when DT.DateType  ='SP' then 'Scheduled Pickup'
						when DT.DateType  ='SD' then 'Scheduled Delivery'
						when DT.DateType  ='AP' then 'Actual Pickup'
						when DT.DateType  ='AD' then 'Actual Delivery'
						else ''
				End + ': ' +  convert(varchar, DT.[DateTime], 101) + ' ' + left(convert(varchar, DT.[DateTime], 108),5)
		from Routes_DateTracker DT
		inner join Routes RT on DT.RouteKey = Rt.RouteKey
		inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
		inner join Leg L on Rt.LegKey = L.LegKey
		LEft join [User] U with (nolock) on DT.CreateUserKey = U.UserKey
		where OD.OrderDetailKey = @OrderDetailKey AND ISNULL(DT.CreateUserKey,0)<>0

		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		Select Distinct ID.OrderDetailKey, A.SysDate, isnull(U.UserName,'') as UserName, 'Invoice', A.IDValue, ID.OrderDetailKey,
						'Invoice Item', '', 'Unit price changed from ' + CONVERT(Varchar, A.OldValue) + ' to ' + CONVERT(Varchar, A.NewValue)
		FRom AuditLog A
		Inner JOIN InvoiceHeader IH ON A.IDValue = IH.InvoiceNo AND TableName = 'Invoicedetail'
		Inner jOin InvoiceDetail ID On ID.InvoiceKey = IH.InvoiceKey
		LEft join [User] U with (nolock) on A.UserID = U.UserKey
		WHERE ID.OrderDetailKey = @OrderDetailKey

		set identity_insert #auditlog OFF
	end

	if(@RefType = 'Voucher')
	begin
		set @VoucherKey = @RefKey

		select distinct VoucherLineKey
		into #VoucherLine
		from VoucherDetail VD with (nolock) 
		where VD.Voucherkey = @RefKey

		set identity_insert #auditlog on
		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select Al.MainAuditLogKey, LogDate, isnull(U.UserName,''),  'Voucher',  VH.VoucherNo , VH.VoucherKey, '', '', LogText
		from Voucher_AuditLog AL  with (nolock)
		inner join VoucherHeader VH with (nolock) on AL.VoucherKey = VH.VoucherKey
		LEft join [User] U with (nolock) on AL.ActionUserKey = U.UserKey
		where AL.VoucherKey = @VoucherKey


		insert into #auditlog (AuditKey, DateCreated,CreateUser, RefType, RefId, RefKey,Stage, CommentType, Comments )
		select Al.MainAuditLogKey, LogDate, isnull(U.UserName,''),  'Voucher Items', I.ItemID, VD.VoucherLineKey, '', '', LogText
		from VoucherLine_AuditLog AL  with (nolock)
		inner join VoucherDetail VD with (nolock) on Al.VoucherLineKey = VD.VoucherLineKey
		inner join VoucherHeader VH with (nolock) on VD.Voucherkey = Vh.VoucherKey
		inner join Item I with (nolock) on VD.ItemKey = I.ItemKey
		LEft join [User] U with (nolock) on AL.ActionUserKey = U.UserKey
		inner join #VoucherLine R with (nolock) on AL.VoucherLineKey = R.VoucherLineKey
		set identity_insert #auditlog off
	end


	select * from #auditlog
	order by DateCreated desc

	drop table #auditlog
End

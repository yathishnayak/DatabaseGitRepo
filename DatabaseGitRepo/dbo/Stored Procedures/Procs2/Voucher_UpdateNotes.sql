create proc [dbo].[Voucher_UpdateNotes]
(
	@VoucherKey		int,
	@DriverNotes	varchar(max),
	@InternalNotes	varchar(max)
)
as
Begin
	set nocount on
	set fmtonly off
	update VoucherHeader set
		DriverNote = @DriverNotes,
		InternalNote = @InternalNotes
	where VoucherKey = @VoucherKey
End

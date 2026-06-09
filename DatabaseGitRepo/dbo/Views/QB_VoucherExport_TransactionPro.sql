



CREATE view [dbo].[QB_VoucherExport_TransactionPro] 
as
select distinct D.DriverID as [Vendor], A.VoucherDate as [Transaction Date], VoucherNo [RefNumber],
'' as  [Bill Due], '' as [Terms], 'Driver Pay for Week - ' as [Memo],
E.Address1 as [Address Line1], E.Address2 as [Address Line2], '' as [Address Line3],  '' as [Address Line4], 
E.City as [Address City], E.State  as [Address State], E.ZipCode as [Address PostalCode], '' as [Address Country], '' as [Vendor Acct No], 
'Outside Labor - Drivers:Contractor Services' as [Expenses Account], A.VoucherAmount as [Expenses Amount],
'CONTRACTOR SERVICE - TMS' as [Expenses Memo], '' as  [Expenses Class], '' as [Expenses Customer], '' as   [Expenses Billable],'' as [Items Item],
''  as [Items Qty],  '' as [Items Description], '' as [Items Cost],  '' as [Items Class],  '' as [Items Customer],  
'' as [Items Billable], '' as [Unit of Measure], '' as [AP Account], '' as [Currency],	'' as [Exchange Rate]   
from VoucherHeader A WITH (NOLOCK) 
inner join VoucherDetail B WITH (NOLOCK)  on (A.VoucherKey = B.Voucherkey)
inner join Routes C WITH (NOLOCK)  on (B.RouteKey = C.RouteKey)
inner join Driver D WITH (NOLOCK)  on (C.DriverKey = D.DriverKey)
left outer join [Address] E WITH (NOLOCK)  on(D.AddrKey= E.AddrKey)




CREATE procedure [dbo].[VoucherExportToQB_TransactionPro] -- VoucherExportToQB_TransactionPro 9
(
	@Weeknum as smallint = 1
)
as
	set nocount on
	set fmtonly off
	select  A.VoucherKey,   isnull(convert(varchar,datepart(ISO_WEEK, C.ActualArrival)),'') as Weeknum,
	isnull(OrgName, FirstName +' ' + LastName) as [Vendor],  
	DATEADD(wk, 1, DATEADD(DAY, -1-DATEPART(WEEKDAY, C.ActualArrival), DATEDIFF(dd, 0, C.ActualArrival))) as [Transaction Date], 
	D.DriverId + '-'+ convert(varchar, Year(C.ActualArrival)) +'-' + isnull(convert(varchar,datepart(ISO_WEEK, C.ActualArrival)),'') as  [RefNumber],
	'' as  [Bill Due], '' as [Terms], 'Driver Pay for Week - ' + isnull(convert(varchar,datepart(ISO_WEEK, C.ActualArrival)),'')  as [Memo],
	'' as [Address Line1], '' as [Address Line2], '' as [Address Line3],  '' as [Address Line4], 
	'' as [Address City], ''  as [Address State], '' as [Address PostalCode], '' as [Address Country], '' as [Vendor Acct No], 
	isnull(G.ERPGLAccount, F.ItemID) as [Expenses Account], B.ExtCost as [Expenses Amount],
	'CONTRACTOR SERVICE - TMS' as [Expenses Memo], '' as  [Expenses Class], '' as [Expenses Customer], '' as   [Expenses Billable],'' as [Items Item],
	''  as [Items Qty],  '' as [Items Description], '' as [Items Cost],  '' as [Items Class],  '' as [Items Customer],  
	'' as [Items Billable], '' as [Unit of Measure], '' as [AP Account], '' as [Currency],	'' as [Exchange Rate]   
	into #tmpExp
	from VoucherHeader A
	inner join VoucherDetail B on (A.VoucherKey = B.Voucherkey)
	inner join Routes C on (B.RouteKey = C.RouteKey)
	inner join Driver D on (C.DriverKey = D.DriverKey)
	left outer join [Address] E on(D.AddrKey= E.AddrKey)
	left outer join item F on  (B.ItemKey = F.ItemKey)
	left outer join ItemExt G on (F.ItemKey = G.ItemKey)
	where isnull(convert(varchar,datepart(ISO_WEEK, C.ActualArrival)),'')  = @Weeknum  
	

	select [Vendor],	[Transaction Date],	[RefNumber],	[Bill Due],	[Terms],	[Memo],	[Address Line1],	[Address Line2],	[Address Line3],	
	[Address Line4],	[Address City],	[Address State],	[Address PostalCode],	[Address Country],	[Vendor Acct No],	[Expenses Account],	
	sum([Expenses Amount]) as [Expenses Amount],	[Expenses Memo],	[Expenses Class],	[Expenses Customer],	[Expenses Billable],	[Items Item],	[Items Qty],	
	[Items Description],	[Items Cost],	[Items Class],	[Items Customer],	[Items Billable],	[Unit of Measure],	[AP Account],	[Currency],	
	[Exchange Rate] from 
	(
		select * from #tmpExp
		union all
		select distinct A.VoucherKey, C.Weeknum,  C.[Vendor] as [Vendor], A.VoucherDate as [Transaction Date], VoucherNo [RefNumber],
			'' as  [Bill Due], '' as [Terms], 'Driver Pay for Week - ' as [Memo],
			C.[Address Line1] as [Address Line1], C.[Address Line2] as [Address Line2], '' as [Address Line3],  '' as [Address Line4], 
			C.[Address City] as [Address City], C.[Address State]  as [Address State], C.[Address PostalCode] as [Address PostalCode], 
			'' as [Address Country], '' as [Vendor Acct No], 
			isnull(G.ERPGLAccount, D.ItemId)  as [Expenses Account], B.ExtCost as [Expenses Amount],
			'CONTRACTOR SERVICE - TMS' as [Expenses Memo], '' as  [Expenses Class], '' as [Expenses Customer], '' as   [Expenses Billable],'' as [Items Item],
			''  as [Items Qty],  '' as [Items Description], '' as [Items Cost],  '' as [Items Class],  '' as [Items Customer],  
			'' as [Items Billable], '' as [Unit of Measure], '' as [AP Account], '' as [Currency],	'' as [Exchange Rate]       
			from   
			VoucherHeader A WITH (NOLOCK) 
			INNER JOIN VoucherDetail B WITH (NOLOCK)  ON A.Voucherkey = B.Voucherkey and RouteKey=0
			inner join  #tmpExp C on (A.VoucherKey = C.Voucherkey)
			inner join Item D on (B.ItemKey = D.ItemKey)
			left outer join ItemExt G on (B.ItemKey = G.ItemKey)
		Union all
			select  distinct VH.DriverVoucherKey as VoucherKey, VH.WeekNumber as Weeknum, 
					isnull(OrgName, FirstName +' ' + LastName) as [Vendor], VH.DriverVoucherdate  as [Transaction Date], 
				D.DriverId + '-'+ convert(varchar, Year(vh.DriverVoucherdate)) +'-' + isnull(convert(varchar,datepart(ISO_WEEK, vh.DriverVoucherdate)),'')  as  [RefNumber],
				'' as  [Bill Due], '' as [Terms], 'Driver Pay for Week - ' +  convert(varchar,VH.WeekNumber) as [Memo],
				'' as [Address Line1], '' as [Address Line2], '' as [Address Line3],  '' as [Address Line4], 
				'' as [Address City], ''  as [Address State], '' as [Address PostalCode], 
				'' as [Address Country], '' as [Vendor Acct No], 
				isnull(G.ERPGLAccount, I.ItemId)  as [Expenses Account], -1 * VD.ExtCost  as [Expenses Amount],
				'CONTRACTOR SERVICE - TMS' as [Expenses Memo], '' as  [Expenses Class], '' as [Expenses Customer], '' as   [Expenses Billable],'' as [Items Item],
				''  as [Items Qty],  '' as [Items Description], '' as [Items Cost],  '' as [Items Class],  '' as [Items Customer],  
				'' as [Items Billable], '' as [Unit of Measure], '' as [AP Account], '' as [Currency],	'' as [Exchange Rate]         
			from   
			DriverVoucherDeduction VH WITH (NOLOCK) 
			INNER JOIN DriverVoucherDeductionDetail VD WITH (NOLOCK)  ON VH.DriverVoucherKey = VD.DriverVoucherKey
			inner join Item I on (vd.ItemKey = I.ItemKey)		
			inner join Driver D on (VH.DriverKey = D.DriverKey)
			left outer join ItemExt G on (I.ItemKey = G.ItemKey)
			WHERE     VH.WeekNumber = @Weeknum 
			
	) X
	group by [Vendor],	[Transaction Date],	[RefNumber],	[Bill Due],	[Terms],	[Memo],	[Address Line1],	[Address Line2],	[Address Line3],	
	[Address Line4],	[Address City],	[Address State],	[Address PostalCode],	[Address Country],	[Vendor Acct No],	[Expenses Account],	
	[Expenses Memo],	[Expenses Class],	[Expenses Customer],	[Expenses Billable],	[Items Item],	[Items Qty],	
	[Items Description],	[Items Cost], 	[Items Class],	[Items Customer],	[Items Billable],	[Unit of Measure],	[AP Account],	[Currency],	
	[Exchange Rate]
	order by [Vendor]

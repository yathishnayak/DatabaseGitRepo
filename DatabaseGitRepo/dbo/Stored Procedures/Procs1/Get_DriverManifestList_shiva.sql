


create PROCEDURE [dbo].[Get_DriverManifestList_shiva] -- 
@StatusKey           INT= 0,
@DriverKey           INT= 0,
@OrderKey            INT= 0,
@OrderDateFrom       DATE='01/01/2020',
@OrderDateTO  DATE='12/31/2099',
@DeliVeryDateFom DATE='01/01/2020',
@DelivaryDateTo      DATE='12/31/2099',
@OrderNo             VARCHAR(50)='',
@containerNo  VARCHAR(50)='',
@voucherNo           VARCHAR(50)='',
@VoucherKey          INT=0
AS
BEGIN
       ---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER
       SET NOCOUNT ON;
       SET FMTONLY OFF;
       

       SELECT distinct d.DriverID,d.FirstName,d.LastName,VH.VoucherNo,VH.VoucherDate,
                      SR.City AS PickUpPoint,DT.City AS DeliveryPoint,od.ContainerNo,I.ItemID,VD.ExtCost, VD.Qty, VD.UnitCost,
                      ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
                      ISNULL(VH.[Statuskey],9)  AS StatusKey
                      ,VH.VoucherAmount
                      , Case when ISNULL(ID.InvoiceKey,0) = 0 then 0 else 1 end AS IsInvoiced
                      , ISNULL(IH.InvoiceNo,'NA') as InvoiceNo
                      , ISNULL(IH.InvoiceDate,'') as InvoiceDate
                      , VS.Description
                      , ID.InvoiceKey
                      , VD.Voucherkey
                      , LG.LegID
                      , RT.FromLocation
                      , RT.ToLocation
                      , d.DriverKey
                      , d.DrivingLicenseNo
                      , d.DrivingLicenseExpiryDate 
                      , RT.ActualArrival
                      , 'WK-' + isnull(convert(varchar,datepart(ISO_WEEK, RT.ActualArrival)),'') as Weeknum
                      ,  null  AS APDeductions
                      , od.OrderDetailKey
                      , case when isnull(d.OrgName,'') = '' then '' 
                             else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
                                    + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end as DriverOrg
                      , A.Week_Start_Date, A.Week_End_Date
                             into #tmpManifst
       FROM 
              VoucherHeader VH WITH (NOLOCK) 
              INNER JOIN VoucherDetail VD WITH (NOLOCK)  ON VH.Voucherkey = VD.Voucherkey
              INNER JOIN dbo.VoucherStatus VS WITH (NOLOCK)   ON VS.[StatusKey]=VH.[StatusKey]
              INNER JOIN dbo.[routes] RT WITH (NOLOCK) ON VD.RouteKey = RT.RouteKey
              INNER JOIN dbo.OrderDetail od      ON RT.OrderDetailKey = od.OrderDetailkey
              INNER JOIN dbo.OrderHeader oh      ON oh.OrderKey = od.OrderKey
              INNER JOIN dbo.Leg LG                     ON LG.LegKey = RT.LegKey
              INNER JOIN dbo.LegType L           ON L.LegtypeKey = LG.LegTypeKey
              INNER JOIN dbo.Driver d                   ON d.DriverKey = RT.DriverKey
              INNER JOIN dbo.RouteStatus RTS     ON RTS.[Status]=RT.[Status]
              LEFT JOIN RouteVouchers RV         ON RV.RouteKey=RT.RouteKey
              LEFT JOIN dbo.[Address] SR         ON SR.AddrKey=RT.SourceAddrKey
              LEFT JOIN dbo.[Address] DT         ON DT.AddrKey=RT.DestinationAddrKey
              LEFT JOIN dbo.Item I               ON I.ItemKey=VD.ItemKey
              LEFT JOIN DBO.Invoicedetail ID     ON ID.OrderDetailKey = OD.OrderDetailKey -- AND ID.ItemKey = VD.ItemKey
              LEFT JOIN dbo.InvoiceHeader IH  ON ID.InvoiceKey = IH.InvoiceKey
              cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A 
       WHERE 
              (  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9)  = @StatusKey )
              AND (  @DriverKey =0 OR @DriverKey IS NULL OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
              AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )
              AND    (  @OrderDateFrom    IS NULL OR OH.OrderDate              IS NULL OR OH.OrderDate>=@OrderDateFrom)
              AND (  @OrderDateTo         IS NULL OR OH.OrderDate              IS NULL OR OH.OrderDate<=@OrderDateTo)
              AND    (  @DeliVeryDateFom  IS NULL OR RT.DeliveryDateFrom  IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
              AND (  @DelivaryDateTo      IS NULL OR RT.DeliveryDateTo    IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo)
              AND (  @OrderNo                    = '' OR OH.OrderNo           IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
              AND (  @containerNo         = '' OR OD.ContainerNo       IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
              AND (  @voucherNo           = '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')
              AND (  @VoucherKey          = 0 OR @VoucherKey is null OR VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey )
                             
       select *, 
	   case when charindex('-',DriverID) > 0 then 
			CAST(LEFT(DriverID,charindex('-',DriverID)-1) AS INT)
			else 
				   9999
			end
			AS DriverID1
	   from (
				 select* from  #tmpManifst
			   union all 
					  select distinct  DriverID,  FirstName,    LastName,       M.VoucherNo,  M.VoucherDate,       '' as PickUpPoint, '' as DeliveryPoint, '' as     ContainerNo,  
					  I.ItemID,     VD.ExtCost,   VD.Qty,       VD.UnitCost,  M.IsPaymentApproved, M.StatusKey,       M.VoucherAmount,     IsInvoiced,   InvoiceNo,       InvoiceDate,  
					  VD.Description,      InvoiceKey,   M.Voucherkey,       LegID, FromLocation, ToLocation,   DriverKey,       DrivingLicenseNo,    
					  DrivingLicenseExpiryDate,   ActualArrival,       Weeknum, VD.ExtCost as APDeductions,     OrderDetailKey,       DriverOrg,    Week_Start_Date,     
					  Week_End_Date        
					  from   
					  VoucherHeader VH WITH (NOLOCK) 
					  INNER JOIN VoucherDetail VD WITH (NOLOCK)  ON VH.Voucherkey = VD.Voucherkey and RouteKey=0
					  inner join  #tmpManifst M on (VH.VoucherKey = M.Voucherkey)
					  inner join Item I on (vd.ItemKey = I.ItemKey)
				UNION ALL
 					  select distinct  DriverID,  FirstName,    LastName,      VH.DriverVoucherNumber,  Vh.DriverVoucherdate,       
						'' as PickUpPoint, '' as DeliveryPoint, isnull(Remarks ,'') as     ContainerNo,  
					  I.ItemID  ,     VD.ExtCost as ExtCost,   VD.Qty,       VD.UnitCost as UnitCost, 
					   M.IsPaymentApproved as  IsPaymentApproved, M.StatusKey as StatusKey,       
					  VH.DriverVoucherAmount,   0  IsInvoiced,   
					  '' InvoiceNo,  GETDATE() InvoiceDate,  
					  VD.Description,    0  InvoiceKey,  '' Voucherkey,    ''   LegID, '' FromLocation, 
					  '' ToLocation,   VH.DriverKey,       DrivingLicenseNo,    
					   DrivingLicenseExpiryDate,   GETDATE() ActualArrival,      'WK-'+ convert(varchar,VH.WeekNumber) Weeknum, 
					  VD.ExtCost as APDeductions,      9999 OrderDetailKey,        DriverOrg,    Week_Start_Date,     
					  Week_End_Date        
					  from   
					  DriverVoucherDeduction VH WITH (NOLOCK) 
					  INNER JOIN DriverVoucherDeductionDetail VD WITH (NOLOCK)  ON VH.DriverVoucherKey = VD.DriverVoucherKey
					  inner join Item I on (vd.ItemKey = I.ItemKey)
					  inner join #tmpManifst M on ('WK-'+ convert(varchar,VH.WeekNumber) =  M.Weeknum and M.DriverKey =VH.DriverKey )
					  WHERE
					   (  @DriverKey =0 OR @DriverKey IS NULL OR VH.DriverKey IS NULL OR VH.DriverKey=@DriverKey )
              ) X
	order by DriverID1, DriverID, ActualArrival,OrderDetailKey, ContainerNo, LegID, ItemID
       
END

create view [dbo].[vRouteVouchers]
as
select distinct VoucherKey, RouteKey from VoucherDetail

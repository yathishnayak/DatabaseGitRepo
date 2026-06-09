

CREATE proc [dbo].[Get_VersionNumber]
as
Select Top 1 VersionNumber from VersionHistory order by VersionDate desc

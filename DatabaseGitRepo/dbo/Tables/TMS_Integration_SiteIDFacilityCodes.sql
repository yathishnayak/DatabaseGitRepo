CREATE TABLE [dbo].[TMS_Integration_SiteIDFacilityCodes] (
    [FacilityCodeKey] INT           NOT NULL,
    [SiteID]          VARCHAR (50)  NULL,
    [FacilityCode]    VARCHAR (10)  NULL,
    [OrderBy]         INT           NULL,
    [ShareEventFiles] BIT           CONSTRAINT [DF_TMS_Integration_SiteIDFacilityCodes_ShareEventFiles] DEFAULT ((0)) NULL,
    [StopTypeCode]    VARCHAR (10)  NULL,
    [StopTypeDesc]    VARCHAR (100) NULL,
    [CustGroupID]     INT           NULL,
    CONSTRAINT [PK_TMS_Integration_SiteIDFacilityCodes] PRIMARY KEY CLUSTERED ([FacilityCodeKey] ASC)
);


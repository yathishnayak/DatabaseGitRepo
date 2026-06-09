CREATE TABLE [dbo].[Gnosis_Integration_Shipments] (
    [Datakey]             INT          NULL,
    [incoming_vessel]     VARCHAR (50) NULL,
    [incoming_voyage]     VARCHAR (50) NULL,
    [in_vessel_eta_dt]    VARCHAR (50) NULL,
    [in_vessel_ata_dt]    VARCHAR (50) NULL,
    [pod_locode]          VARCHAR (50) NULL,
    [pod_city]            VARCHAR (50) NULL,
    [outgoing_vessel]     VARCHAR (50) NULL,
    [outgoing_voyage]     VARCHAR (50) NULL,
    [out_vessel_etd_dt]   VARCHAR (50) NULL,
    [out_vessel_atd_dt]   VARCHAR (50) NULL,
    [loaded_on_vessel_dt] VARCHAR (50) NULL,
    [discharged_dt]       VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Shipments_Datakey]
    ON [dbo].[Gnosis_Integration_Shipments]([Datakey] ASC);


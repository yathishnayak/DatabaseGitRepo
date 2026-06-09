CREATE TABLE [dbo].[Gnosis_Export_TrackingRequestBookingStatus] (
    [TrackingBookingStatusKey]   INT          NULL,
    [uuid]                       VARCHAR (50) NULL,
    [booking_number]             VARCHAR (50) NULL,
    [num_of_supplier_containers] VARCHAR (20) NULL,
    [tracking_status]            VARCHAR (20) NULL,
    [num_containers]             VARCHAR (20) NULL,
    [cargo_cut_off_dt]           VARCHAR (50) NULL,
    [doc_cut_off]                VARCHAR (20) NULL,
    [early_receive_dt]           VARCHAR (20) NULL,
    [first_vessel]               VARCHAR (20) NULL,
    [first_voyage]               VARCHAR (20) NULL,
    [vessel_etb_pol_dt]          VARCHAR (20) NULL,
    [vessel_eta_pol_dt]          VARCHAR (20) NULL,
    [vessel_etd_pol_dt]          VARCHAR (20) NULL,
    [vessel_eta_pod_dt]          VARCHAR (20) NULL,
    [pol_locode]                 VARCHAR (20) NULL,
    [pol_city]                   VARCHAR (20) NULL,
    [pol_terminal_name]          VARCHAR (50) NULL,
    [pol_terminal_firms_code]    VARCHAR (20) NULL,
    [created_dt]                 VARCHAR (20) NULL,
    [CreatedDate]                DATETIME     NULL
);


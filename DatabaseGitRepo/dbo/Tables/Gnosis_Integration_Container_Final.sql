CREATE TABLE [dbo].[Gnosis_Integration_Container_Final] (
    [UUID]                              VARCHAR (50) NOT NULL,
    [Container_number]                  VARCHAR (50) NULL,
    [ContainerStatus]                   VARCHAR (50) NULL,
    [HoldStatus]                        VARCHAR (20) NULL,
    [Holds]                             VARCHAR (50) NULL,
    [Container_journey_start_key]       VARCHAR (50) NULL,
    [Seal_no]                           VARCHAR (50) NULL,
    [Container_type]                    VARCHAR (50) NULL,
    [Length]                            VARCHAR (50) NULL,
    [Weight]                            VARCHAR (50) NULL,
    [Empty_out_dt]                      VARCHAR (50) NULL,
    [In_gate_dt]                        VARCHAR (50) NULL,
    [Early_receive_dt]                  VARCHAR (50) NULL,
    [Cut_off_dt]                        VARCHAR (50) NULL,
    [Out_gate_dt]                       VARCHAR (50) NULL,
    [Port_eta_dt]                       VARCHAR (50) NULL,
    [Gnosis_vessel_eta_dt]              VARCHAR (50) NULL,
    [Gnosis_estimated_discharge_dt]     VARCHAR (50) NULL,
    [Gnosis_rail_eta_dt]                VARCHAR (50) NULL,
    [Vessel_eta_dt]                     VARCHAR (50) NULL,
    [Vessel_etd_dt]                     VARCHAR (50) NULL,
    [Vessel_ata_dt]                     VARCHAR (50) NULL,
    [Vessel_atd_dt]                     VARCHAR (50) NULL,
    [Discharged_dt]                     VARCHAR (50) NULL,
    [Empty_returned_dt]                 VARCHAR (50) NULL,
    [Pod_locode]                        VARCHAR (50) NULL,
    [Pod_city]                          VARCHAR (50) NULL,
    [Pod_terminal_name]                 VARCHAR (50) NULL,
    [Pod_terminal_firms_code]           VARCHAR (50) NULL,
    [Pol_locode]                        VARCHAR (50) NULL,
    [Pol_city]                          VARCHAR (50) NULL,
    [Pol_terminal_name]                 VARCHAR (50) NULL,
    [Pol_terminal_firms_code]           VARCHAR (50) NULL,
    [Por_locode]                        VARCHAR (50) NULL,
    [Por_city]                          VARCHAR (50) NULL,
    [Ocean_carrier_name]                VARCHAR (50) NULL,
    [Ocean_carrier_scac]                VARCHAR (50) NULL,
    [Mother_vessel]                     VARCHAR (50) NULL,
    [Mother_vessel_imo]                 VARCHAR (50) NULL,
    [Mother_voyage]                     VARCHAR (50) NULL,
    [Motherload_dt]                     VARCHAR (50) NULL,
    [Current_vessel]                    VARCHAR (50) NULL,
    [Current_vessel_imo]                VARCHAR (50) NULL,
    [First_vessel]                      VARCHAR (50) NULL,
    [First_vessel_imo]                  VARCHAR (50) NULL,
    [Location_at_terminal]              VARCHAR (50) NULL,
    [Is_railing]                        VARCHAR (50) NULL,
    [Rail_eta_dt]                       VARCHAR (50) NULL,
    [Rail_ata_dt]                       VARCHAR (50) NULL,
    [Rail_departed_dt]                  VARCHAR (50) NULL,
    [Rail_discharged_dt]                VARCHAR (50) NULL,
    [Rail_terminal]                     VARCHAR (50) NULL,
    [Rail_terminal_firms_code]          VARCHAR (50) NULL,
    [Rail_notify_dt]                    VARCHAR (50) NULL,
    [Pickup_number]                     VARCHAR (50) NULL,
    [Available_dt]                      VARCHAR (50) NULL,
    [Final_dest_locode]                 VARCHAR (50) NULL,
    [Final_dest_city]                   VARCHAR (50) NULL,
    [Last_free_demurrage_day_dt]        VARCHAR (50) NULL,
    [Last_free_detention_day_dt]        VARCHAR (50) NULL,
    [Estd_last_free_demurrage_day_dt]   VARCHAR (50) NULL,
    [Demurrage_amount]                  VARCHAR (50) NULL,
    [Estd_demurrage_amount]             VARCHAR (50) NULL,
    [Estd_last_free_detention_day_dt]   VARCHAR (50) NULL,
    [Estd_detention_amount]             VARCHAR (50) NULL,
    [Carrier_release_dt]                VARCHAR (50) NULL,
    [Customs_clearance_dt]              VARCHAR (50) NULL,
    [Available_for_pickup]              VARCHAR (50) NULL,
    [Loaded_on_vessel_dt]               VARCHAR (50) NULL,
    [Pickup_appointment_dt]             VARCHAR (50) NULL,
    [Updated_dt]                        VARCHAR (50) NULL,
    [Chassis_number]                    VARCHAR (50) NULL,
    [Customer_tag]                      VARCHAR (50) NULL,
    [Carrier_contract]                  VARCHAR (50) NULL,
    [Distribution_center]               VARCHAR (50) NULL,
    [Drayage_carrier]                   VARCHAR (50) NULL,
    [LastUpdateDate]                    DATETIME     NULL,
    [LastDataKey]                       INT          NULL,
    [OrderDetailKey]                    INT          NULL,
    [Push_to_Schedule]                  BIT          DEFAULT ((0)) NULL,
    [gnosis_estimated_demurrage_amount] VARCHAR (50) NULL,
    [IsAutoMove]                        BIT          NULL,
    [MovedBy]                           INT          NULL,
    [MovedOn]                           DATETIME     NULL,
    [RailOutGateDate]                   VARCHAR (50) NULL,
    CONSTRAINT [PK_Gnosis_Integration_Container_Final] PRIMARY KEY CLUSTERED ([UUID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Container_Final]
    ON [dbo].[Gnosis_Integration_Container_Final]([OrderDetailKey] ASC);


GO
CREATE NONCLUSTERED INDEX [Ind_Gnosis_ContainerNo]
    ON [dbo].[Gnosis_Integration_Container_Final]([Container_number] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [Ind_Gnosis_UUID_UpdatedDt]
    ON [dbo].[Gnosis_Integration_Container_Final]([UUID] ASC)
    INCLUDE([Updated_dt]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Container_Final_LastDataKey]
    ON [dbo].[Gnosis_Integration_Container_Final]([LastDataKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Container_Final_ContainerStatus]
    ON [dbo].[Gnosis_Integration_Container_Final]([ContainerStatus] ASC)
    INCLUDE([Container_number], [Container_type], [Discharged_dt], [Pod_terminal_name], [Pod_terminal_firms_code], [Final_dest_city], [Available_for_pickup], [Pickup_appointment_dt]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Container_Final_OrderDetailKey]
    ON [dbo].[Gnosis_Integration_Container_Final]([OrderDetailKey] ASC)
    INCLUDE([Container_number], [ContainerStatus], [Out_gate_dt], [Gnosis_vessel_eta_dt], [Vessel_eta_dt], [Discharged_dt], [Empty_returned_dt], [Available_dt], [Last_free_demurrage_day_dt], [Demurrage_amount], [Estd_demurrage_amount], [Available_for_pickup], [gnosis_estimated_demurrage_amount]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Container_Final_ContainerStatus1]
    ON [dbo].[Gnosis_Integration_Container_Final]([ContainerStatus] ASC)
    INCLUDE([Container_number], [Out_gate_dt], [OrderDetailKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_3167_3166_Gnosis_Integration_Container_Fin]
    ON [dbo].[Gnosis_Integration_Container_Final]([ContainerStatus] ASC)
    INCLUDE([Container_number], [Container_type], [Discharged_dt], [Pod_terminal_name], [Pod_terminal_firms_code], [Is_railing], [Rail_terminal], [Final_dest_city], [Available_for_pickup], [Pickup_appointment_dt]) WITH (FILLFACTOR = 90);


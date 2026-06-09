CREATE TABLE [dbo].[Gnosis_Export_TrackingRequestBooking] (
    [TrackingBookingKey]    INT           NULL,
    [Tracking_request_uuid] VARCHAR (50)  NULL,
    [Booking_number]        VARCHAR (50)  NULL,
    [Booking_uuid]          VARCHAR (50)  NULL,
    [Returnmessage]         VARCHAR (500) NULL,
    [Carrier_scac]          VARCHAR (20)  NULL,
    [CreatedDate]           DATETIME      NULL
);


// //*************

// pageextension 50621 "Service Item Card Extension" extends "Service Item Card"
// {
//     layout
//     {
//         addlast(General)
//         {
//             field("Show Warranty Notifications"; Rec."Show Warranty Notifications")
//             {
//                 ApplicationArea = All;
//                 ToolTip = 'Indicates whether warranty notifications exist for this service item';

//                 trigger OnDrillDown()
//                 var
//                     WarrantyNotificationLog: Record "Warranty Notification Log";
//                     WarrantyNotificationLogPage: Page "Warranty Notification Log";
//                 begin
//                     WarrantyNotificationLog.Reset();
//                     WarrantyNotificationLog.SetRange("Service Item No.", Rec."No.");
//                     WarrantyNotificationLogPage.SetTableView(WarrantyNotificationLog);
//                     WarrantyNotificationLogPage.RunModal();
//                 end;
//             }
//         }
//     }

//     actions
//     {
//         addlast(processing)
//         {
//             action(SendWarrantyNotification)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Send Warranty Notification';
//                 Image = Email;
//                 ToolTip = 'Send warranty notification for this service item';

//                 trigger OnAction()
//                 var
//                     WarrantyNotificationLog: Record "Warranty Notification Log";
//                     WarrantyEmailMgt: Codeunit "Warranty Email Management";
//                     Customer: Record Customer;
//                     CustomerEmail: Text[80];
//                     WarrantyNotificationSetup: Record "Warranty Notification Setup";
//                     CurrentDate: Date;
//                 begin
//                     CurrentDate := Today;

//                     // Show dates for debugging
//                     Message('Today''s date: %1\nWarranty end date: %2', Format(CurrentDate), Format(Rec."Warranty Ending Date (Parts)"));

//                     // Check warranty end date
//                     if Rec."Warranty Ending Date (Parts)" = 0D then
//                         Error('Warranty end date for this service item is not set');

//                     // Continue only if warranty has expired - today must be greater than end date
//                     if CurrentDate <= Rec."Warranty Ending Date (Parts)" then
//                         Error('Warranty for this item has not expired yet.\nToday: %1\nEnd date: %2',
//                             Format(CurrentDate), Format(Rec."Warranty Ending Date (Parts)"));

//                     // Get customer email
//                     CustomerEmail := '';
//                     if Customer.Get(Rec."Customer No.") then
//                         CustomerEmail := Customer."E-Mail";

//                     if CustomerEmail = '' then
//                         Error('Customer email is not set');

//                     // Get settings
//                     if not WarrantyNotificationSetup.Get() then
//                         if not WarrantyNotificationSetup.FindFirst() then begin
//                             WarrantyNotificationSetup.Init();
//                             WarrantyNotificationSetup."Primary Key" := 'DEFAULT';
//                             WarrantyNotificationSetup.Insert();
//                             WarrantyNotificationSetup.SetDefaultTemplate();
//                             WarrantyNotificationSetup.Modify();
//                         end;

//                     if Confirm('Do you want to send a warranty notification for this item with expired warranty?') then begin
//                         // Log entry
//                         WarrantyNotificationLog.Init();
//                         WarrantyNotificationLog."Service Item No." := Rec."No.";
//                         WarrantyNotificationLog."Customer No." := Rec."Customer No.";
//                         WarrantyNotificationLog."Customer Email" := CustomerEmail;
//                         WarrantyNotificationLog."Warranty End Date" := Rec."Warranty Ending Date (Parts)";
//                         WarrantyNotificationLog."Notification Date" := CurrentDate;
//                         WarrantyNotificationLog.Insert();

//                         // Send email
//                         WarrantyEmailMgt.SendWarrantyNotification(WarrantyNotificationLog);
//                     end;
//                 end;
//             }
//         }
//     }
// }
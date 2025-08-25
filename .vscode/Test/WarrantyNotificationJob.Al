// codeunit 50624 "Warranty Notification Job"
// {
//     procedure RunJob()
//     var
//         NotificationSetup: Record "Notification Setup";
//         ServiceItem: Record "Service Item";
//         WarrantyNotificationLog: Record "Warranty Notification Log";
//         WarrantyEmailManagement: Codeunit "Warranty Email Management";
//         Customer: Record Customer;
//         Today: Date;
//         WarrantyEndDate: Date;
//     begin
//         if not NotificationSetup.Get() then
//             exit;
//         if NotificationSetup."Notification Type" <> NotificationSetup."Notification Type"::"Warranty 90 Days" then
//             exit;

//         Today := Today;

//         ServiceItem.Reset();
//         if ServiceItem.FindSet() then
//             repeat
//                 WarrantyEndDate := ServiceItem."Warranty Ending Date (Parts)";
//                 if WarrantyEndDate <> 0D then
//                     if CalcDate('<+90D>', Today) = WarrantyEndDate then begin
//                         Clear(WarrantyNotificationLog);
//                         WarrantyNotificationLog.Init();
//                         WarrantyNotificationLog."Service Item No." := ServiceItem."No.";
//                         WarrantyNotificationLog."Customer No." := ServiceItem."Customer No.";

//                         // گرفتن ایمیل مشتری
//                         if Customer.Get(ServiceItem."Customer No.") then
//                             WarrantyNotificationLog."Customer Email" := Customer."E-Mail"
//                         else
//                             WarrantyNotificationLog."Customer Email" := '';

//                         WarrantyNotificationLog."Warranty End Date" := WarrantyEndDate;
//                         WarrantyNotificationLog."Notification Date" := Today;
//                         WarrantyNotificationLog.Insert(true);

//                         WarrantyEmailManagement.SendWarrantyNotification(WarrantyNotificationLog);
//                     end;
//             until ServiceItem.Next() = 0;
//     end;
// }
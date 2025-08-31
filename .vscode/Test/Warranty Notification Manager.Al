// codeunit 50649 "Warranty Notification Manager"
// {
//     trigger OnRun()
//     begin
//         CheckWarrantyItemsAndNotify();
//     end;

//     local procedure CheckWarrantyItemsAndNotify()
//     var
//         ServiceItem: Record "Service Item";
//         Customer: Record Customer;
//         Salesperson: Record "Salesperson/Purchaser";
//     begin
//         ServiceItem.SetFilter("Warranty Ending Date (Parts)", '=%1', CalcDate('<+3M>', Today));

//         if ServiceItem.FindSet() then
//             repeat
//                 if Customer.Get(ServiceItem."Customer No.") then
//                     SendNotificationsForServiceItem(ServiceItem, Customer);
//             until ServiceItem.Next() = 0;
//     end;

//     local procedure SendNotificationsForServiceItem(var ServiceItem: Record "Service Item"; var Customer: Record Customer)
//     var
//         Salesperson: Record "Salesperson/Purchaser";
//     begin

//         if Customer."E-Mail" <> '' then
//             SendCustomerNotification(ServiceItem, Customer);

//         if (Customer."Salesperson Code" <> '') and
//            Salesperson.Get(Customer."Salesperson Code") and
//            (Salesperson."E-Mail" <> '')
//         then
//             SendSalespersonNotification(ServiceItem, Customer, Salesperson);
//     end;

//     local procedure SendCustomerNotification(var ServiceItem: Record "Service Item"; var Customer: Record Customer)
//     var
//         SMTPMail: Codeunit "SMTP Mail";
//         RecipientList: List of [Text];
//         Salesperson: Record "Salesperson/Purchaser";
//         Subject: Text;
//         Body: Text;
//     begin
//         RecipientList.Add(Customer."E-Mail");

//         if Customer."Salesperson Code" <> '' then
//             Salesperson.Get(Customer."Salesperson Code");

//         Body := GetCustomerEmailBody(ServiceItem, Customer, Salesperson);
//         Subject := 'پایان اعتبار گارانتی';

//         SMTPMail.CreateMessage('BC Support', 'bcsupport@aliasaas.com', RecipientList, Subject, Body, true);

//         if not SMTPMail.Send() then
//             Error('Failed to send customer notification for item %1', ServiceItem."No.");
//     end;

//     local procedure SendSalespersonNotification(var ServiceItem: Record "Service Item"; var Customer: Record Customer; Salesperson: Record "Salesperson/Purchaser")
//     var
//         SMTPMail: Codeunit "SMTP Mail";
//         RecipientList: List of [Text];
//         Subject: Text;
//         Body: Text;

//     begin
//         RecipientList.Add(Salesperson."E-Mail");
//         Body := GetSalespersonEmailBody(ServiceItem, Customer, Salesperson);
//         Subject := 'پایان اعتبار گارانتی';

//         SMTPMail.CreateMessage('BC Support', 'bcsupport@aliasaas.com', RecipientList, Subject, Body, true);

//         if not SMTPMail.Send() then
//             Error('Failed to send salesperson notification for item %1', ServiceItem."No.");
//     end;

//     local procedure GetCustomerEmailBody(var ServiceItem: Record "Service Item"; var Customer: Record Customer; var Salesperson: Record "Salesperson/Purchaser"): Text
//     var
//         Body: Text;
//         SalespersonInfo: Text;
//     begin
//         // Add salesperson contact info if available
//         if Salesperson.Code <> '' then
//             Body := StrSubstNo(
//             '<span style="color:black !important;">' +
//             '<div style="direction:rtl; text-align:right; font-family:Tahoma; font-size:12pt;color:black !important;">' +
//             '[english version below]<br/><br/>' +
//             'گارانتی شما به زودی منقضی می‌شود.<br/><br/>' +
//             '<b>%1 عزیز،</b><br/><br/>' +
//             'این یک یادآوری است که گارانتی محصول <b>%2</b> در تاریخ <b>%3</b> منقضی خواهد شد.<br/><br/>' +
//             'برای اطمینان از حفاظت مداوم با ما در ارتباط باشید.<br/>' +
//             '<br/><br/>' +
//             'با احترام.' +
//             '<br/><br/>' +
//             '<br/>کارشناس فروش مربوطه: %4<br/>' +
//             'ایمیل کارشناس: %5<br/>' +
//             'تلفن کارشناس: %6<br/><br/><br/><br/>' +
//             '<br/><br/>' +
//             '</div>' +
//             '<div style="direction:ltr; text-align:left; font-family:Tahoma; font-size:12pt;color:black !important;">' +
//             'Your warranty is expiring soon.<br/><br/>' +
//             '<b>Dear %1,</b><br/><br/>' +
//             'We hope this message finds you well. This is a reminder that your <b>%2</b> warranty is going to expire on <b>%3</b>.<br/><br/>' +
//             'To ensure continued protection of your product, contact us.<br/>' +
//             '<br/><br/>' +
//             'Best Regurds.' +
//             '<br/><br/>' +
//             '<br/>Sales Person: %4<br/>' +
//             'Sales Person E-Mail: %5<br/>' +
//             'Sales Person Phone: %6' +
//             '<br/><br/>' +
//             '</div>' +
//             '</span>',
//             Customer.Name,
//             ServiceItem.Description,
//             Format(ServiceItem."Warranty Ending Date (Parts)", 0, '<Day,2>/<Month,2>/<Year4>'),
//             Salesperson.Name, Salesperson."E-Mail",
//             Salesperson."Phone No.");
//         exit(Body);
//     end;

//     local procedure GetSalespersonEmailBody(var ServiceItem: Record "Service Item"; var Customer: Record Customer; var Salesperson: Record "Salesperson/Purchaser"): Text
//     begin
//         exit(StrSubstNo(
//             '<div style="direction:rtl; text-align:right; font-family:Tahoma; font-size:12pt;color:black !important;">' +
//             '[english version below]' +
//             '.یادآوری انقضای گارانتی مشتری<br/><br/>' +
//             'کارشناس فروش محترم %1،<br/><br/>' +
//             'این یک یادآوری است که گارانتی محصول زیر برای مشتری شما به زودی منقضی خواهد شد:<br/><br/>' +
//             '<b>مشتری:</b> %2<br/>' +
//             '<b>شماره مشتری:</b> %3<br/>' +
//             '<b>شماره آیتم سرویس:</b> %4<br/>' +
//             '<b>تاریخ انقضا:</b> %5<br/><br/>' +
//             'لطفاً با مشتری جهت پیگیری اقدامات لازم تماس حاصل فرمایید.<br/><br/>' +
//             'اطلاعات تماس مشتری:<br/>' +
//             'تلفن: %6<br/>' +
//             'ایمیل: %7<br/><br/>' +
//             'با تشکر<br/>' +
//             'سیستم اطلاع‌رسانی گارانتی' +
//             '</div>',
//             Salesperson.Name,
//             Customer.Name,
//             Customer."No.",
//             ServiceItem.Description,
//             Format(ServiceItem."Warranty Ending Date (Parts)", 0, '<Day,2>/<Month,2>/<Year4>'),
//             Customer."Phone No.",
//             Customer."E-Mail"));
//     end;
// }
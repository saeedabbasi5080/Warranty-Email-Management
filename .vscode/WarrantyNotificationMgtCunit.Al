codeunit 50620 "Warranty Notification Mgt."
{
    trigger OnRun()
    begin
        RunWarrantyNotificationProcess();
    end;

    procedure RunWarrantyNotificationProcess()
    var
        NotificationSetup: Record "Notification Setup";
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        ServiceItem: Record "Service Item";
        ServiceItemGroup: Record "Service Item Group";
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        WarrantyNotificationLog: Record "Warranty Notification Log";
        WarrantyEmailMgt: Codeunit "Warranty Email Management";
        NotificationDate: Date;
        CustomerEmail: Text[80];
        SalespersonEmail: Text[80];
    begin
        // NotificationSetup.Get();

        // if NotificationSetup."Notification Type" <> NotificationSetup."Notification Type"::"Warranty 90 Days" then
        //     exit;
        // if not WarrantyNotificationSetup.Get('DEFAULT') then
        //     Error('Warranty notification settings not found. Please open the settings page first.');

        // if not WarrantyNotificationSetup."Notification Enabled" then
        //     Error('Warranty notification system is disabled');

        // Only service items that are license and support (filtered by service item group)
        ServiceItem.Reset();
        ServiceItem.SetFilter("Warranty Ending Date (Parts)", '<>%1', 0D);

        NotificationDate := CalcDate(Format(WarrantyNotificationSetup."Days Before Expiry") + 'D', WorkDate());

        ServiceItem.SetFilter("Warranty Ending Date (Parts)", '=%1', CalcDate(Format(WarrantyNotificationSetup."Days Before Expiry") + 'D', WorkDate()));

        if ServiceItem.FindSet() then
            repeat
                // Check if the service item is license or support
                if ServiceItemGroup.Get(ServiceItem."Service Item Group Code") then begin
                    if (ServiceItemGroup.Description.Contains('license') or ServiceItemGroup.Description.Contains('support')) then begin
                        // Check if notification has already been sent
                        WarrantyNotificationLog.Reset();
                        WarrantyNotificationLog.SetRange("Service Item No.", ServiceItem."No.");
                        WarrantyNotificationLog.SetRange("Notification Date", WorkDate());

                        if not WarrantyNotificationLog.FindFirst() then begin
                            // Customer email
                            CustomerEmail := '';
                            if Customer.Get(ServiceItem."Customer No.") then
                                CustomerEmail := Customer."E-Mail";

                            // Salesperson email
                            SalespersonEmail := '';
                            if Customer."Salesperson Code" <> '' then
                                if SalespersonPurchaser.Get(Customer."Salesperson Code") then
                                    SalespersonEmail := SalespersonPurchaser."E-Mail";

                            // Log entry
                            WarrantyNotificationLog.Init();
                            WarrantyNotificationLog."Service Item No." := ServiceItem."No.";
                            WarrantyNotificationLog."Customer No." := ServiceItem."Customer No.";
                            WarrantyNotificationLog."Customer Email" := CustomerEmail;
                            WarrantyNotificationLog."Salesperson Code" := Customer."Salesperson Code";
                            WarrantyNotificationLog."Salesperson Email" := SalespersonEmail;
                            WarrantyNotificationLog."Warranty End Date" := ServiceItem."Warranty Ending Date (Parts)";
                            WarrantyNotificationLog."Notification Date" := WorkDate();
                            WarrantyNotificationLog.Insert();

                            // Send email
                            if (CustomerEmail <> '') or (SalespersonEmail <> '') then
                                WarrantyEmailMgt.SendWarrantyNotification(WarrantyNotificationLog);
                        end;
                    end;
                end;
            until ServiceItem.Next() = 0;

        // Update last run date
        WarrantyNotificationSetup."Last Run Date" := WorkDate();
        WarrantyNotificationSetup.Modify();

        Message('Warranty notification process executed successfully');
    end;
}
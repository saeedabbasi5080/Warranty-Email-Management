codeunit 50620 "Warranty Notification Mgt."
{
    trigger OnRun()
    begin
        RunWarrantyNotificationProcess();
    end;

    procedure RunWarrantyNotificationProcess()
    var
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
        LatestEntryNo: Integer;
        IsLicenseOrSupport: Boolean;
    begin
        // Get notification settings
        if WarrantyNotificationSetup.FindFirst() then;

        // Calculate the target expiry date
        NotificationDate := CalcDate('<+' + Format(WarrantyNotificationSetup."Days Before Expiry") + 'D>', WorkDate());

        // Only service items that expire on the target date
        ServiceItem.Reset();
        ServiceItem.SetFilter("Warranty Ending Date (Parts)", '<>%1', 0D);
        // ServiceItem.SetRange("Warranty Ending Date (Parts)", NotificationDate);

        if ServiceItem.FindSet() then
            repeat
                // Check if the service item group exists
                if ServiceItemGroup.Get(ServiceItem."Service Item Group Code") then begin
                    // All items are eligible
                    IsLicenseOrSupport := true;

                    if IsLicenseOrSupport then begin
                        // Check if notification has already been sent
                        WarrantyNotificationLog.Reset();
                        WarrantyNotificationLog.SetRange("Service Item No.", ServiceItem."No.");
                        WarrantyNotificationLog.SetRange("Warranty End Date", ServiceItem."Warranty Ending Date (Parts)");
                        WarrantyNotificationLog.SetRange("Email Sent", true);

                        if not WarrantyNotificationLog.FindFirst() then begin
                            // Get customer email
                            CustomerEmail := '';
                            if Customer.Get(ServiceItem."Customer No.") then
                                CustomerEmail := Customer."E-Mail";

                            // Get salesperson email
                            SalespersonEmail := '';
                            if Customer."Salesperson Code" <> '' then
                                if SalespersonPurchaser.Get(Customer."Salesperson Code") then
                                    SalespersonEmail := SalespersonPurchaser."E-Mail";

                            // Find the latest entry number
                            WarrantyNotificationLog.Reset();
                            if WarrantyNotificationLog.FindLast() then
                                LatestEntryNo := WarrantyNotificationLog."Entry No."
                            else
                                LatestEntryNo := 0;

                            // Create log entry
                            WarrantyNotificationLog.Init();
                            WarrantyNotificationLog."Entry No." := LatestEntryNo + 1;
                            WarrantyNotificationLog."Service Item No." := ServiceItem."No.";
                            WarrantyNotificationLog."Customer No." := ServiceItem."Customer No.";
                            WarrantyNotificationLog."Customer Email" := CustomerEmail;
                            WarrantyNotificationLog."Salesperson Code" := Customer."Salesperson Code";
                            WarrantyNotificationLog."Salesperson Email" := SalespersonEmail;
                            WarrantyNotificationLog."Warranty End Date" := ServiceItem."Warranty Ending Date (Parts)";
                            WarrantyNotificationLog."Notification Date" := WorkDate();
                            WarrantyNotificationLog.Insert();

                            // Complete the current write transaction before running the codeunit
                            COMMIT;

                            // Send email if recipients exist
                            if (CustomerEmail <> '') or (SalespersonEmail <> '') then begin
                                ClearLastError();
                                WarrantyEmailMgt.SendWarrantyNotification(WarrantyNotificationLog);
                                if not WarrantyNotificationLog."Email Sent" then begin
                                    WarrantyNotificationLog."Failed" := true;
                                    WarrantyNotificationLog."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
                                    WarrantyNotificationLog.Modify();
                                end;
                            end else begin
                                WarrantyNotificationLog."Failed" := true;
                                WarrantyNotificationLog."Error Message" := 'No email recipients found';
                                WarrantyNotificationLog.Modify();
                            end;
                        end;
                    end;
                end;
            until ServiceItem.Next() = 0;

        // Update last run date if settings exist
        if WarrantyNotificationSetup.FindFirst() then begin
            WarrantyNotificationSetup."Last Run Date" := WorkDate();
            WarrantyNotificationSetup.Modify();
        end;

        Message('Warranty notification process completed');
    end;
}
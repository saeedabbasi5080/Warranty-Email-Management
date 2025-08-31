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
        TempServiceItemBuffer: Record "Service Item" temporary;
        Customer: Record Customer;
        NotificationDate: Date;
        CurrentCustomerNo: Code[20];
        TotalEmails: Integer;
        TotalItems: Integer;
    begin
        TotalEmails := 0;
        TotalItems := 0;

        // Process each active notification setup
        WarrantyNotificationSetup.Reset();
        WarrantyNotificationSetup.SetRange("Notification Enabled", true);
        if not WarrantyNotificationSetup.FindSet() then begin
            Message('No active notification settings found.');
            exit;
        end;

        // Calculate target expiry date based on Days Before Expiry
        NotificationDate := CalcDate('<+' + Format(WarrantyNotificationSetup."Days Before Expiry") + 'D>', WorkDate());
        repeat
            // Find all service items expiring on target date - directly without customer loop
            ServiceItem.Reset();
            ServiceItem.SetFilter("Warranty Ending Date (Parts)", '<>%1', 0D);
            ServiceItem.SetRange("Warranty Ending Date (Parts)", NotificationDate);
            // فقط آیتم‌هایی که گروه‌شان License یا Support است
            ServiceItem.SetFilter("Service Item Group Code", '%1|%2', 'License', 'Support');

            // Group by customer
            if ServiceItem.FindSet() then begin
                Clear(CurrentCustomerNo);
                TempServiceItemBuffer.Reset();
                TempServiceItemBuffer.DeleteAll();

                repeat
                    // When we encounter a new customer, process previous customer's items if any
                    if (CurrentCustomerNo <> '') and (CurrentCustomerNo <> ServiceItem."Customer No.") then begin
                        if Customer.Get(CurrentCustomerNo) then
                            ProcessCustomerItemsFromBuffer(
                                WarrantyNotificationSetup,
                                Customer,
                                TempServiceItemBuffer,
                                TotalEmails,
                                TotalItems);

                        // Reset buffer for new customer
                        TempServiceItemBuffer.Reset();
                        TempServiceItemBuffer.DeleteAll();
                    end;

                    // Store current customer
                    CurrentCustomerNo := ServiceItem."Customer No.";

                    // Add to buffer for current customer
                    TempServiceItemBuffer.Init();
                    TempServiceItemBuffer.TransferFields(ServiceItem);
                    TempServiceItemBuffer.Insert();
                until ServiceItem.Next() = 0;

                // Process last customer
                if (CurrentCustomerNo <> '') then
                    if Customer.Get(CurrentCustomerNo) then
                        ProcessCustomerItemsFromBuffer(
                            WarrantyNotificationSetup,
                            Customer,
                            TempServiceItemBuffer,
                            TotalEmails,
                            TotalItems);
            end;

            // Update last run date
            WarrantyNotificationSetup."Last Run Date" := WorkDate();
            WarrantyNotificationSetup.Modify();
        until WarrantyNotificationSetup.Next() = 0;

        if TotalEmails = 0 then
            Message('No emails sent. No service items match the notification criteria.')
        else
            Message('Warranty notification process completed. %1 emails sent for %2 service items.', TotalEmails, TotalItems);
    end;

    local procedure ProcessCustomerItemsFromBuffer(
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        Customer: Record Customer;
        var TempServiceItemBuffer: Record "Service Item" temporary;
        var TotalEmails: Integer;
        var TotalItems: Integer)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        WarrantyNotificationLog: Record "Warranty Notification Log";
        WarrantyEmailMgt: Codeunit "Warranty Email Management";
        CustomerEmail: Text[80];
        SalespersonEmail: Text[80];
        ItemsList: Text;
        EmailSent: Boolean;
        LatestEntryNo: Integer;
    begin
        // Get customer email
        CustomerEmail := Customer."E-Mail";

        // Get salesperson email
        SalespersonEmail := '';
        if Customer."Salesperson Code" <> '' then
            if SalespersonPurchaser.Get(Customer."Salesperson Code") then
                SalespersonEmail := SalespersonPurchaser."E-Mail";

        // If no recipients, exit
        if (CustomerEmail = '') and (SalespersonEmail = '') then
            exit;

        // حلقه روی هر آیتم و ارسال ایمیل جداگانه
        TempServiceItemBuffer.Reset();
        if TempServiceItemBuffer.FindSet() then
            repeat
                // فقط اطلاعات همان آیتم را بساز
                ItemsList := BuildSingleItemRow(TempServiceItemBuffer);

                // ساخت لاگ برای هر آیتم
                WarrantyNotificationLog.Init();
                WarrantyNotificationLog."Entry No." := WarrantyNotificationLog.Count + 1;
                WarrantyNotificationLog."Service Item No." := TempServiceItemBuffer."No.";
                WarrantyNotificationLog."Customer No." := Customer."No.";
                WarrantyNotificationLog."Customer Email" := CustomerEmail;
                WarrantyNotificationLog."Salesperson Code" := Customer."Salesperson Code";
                WarrantyNotificationLog."Salesperson Email" := SalespersonEmail;
                WarrantyNotificationLog."Warranty End Date" := TempServiceItemBuffer."Warranty Ending Date (Parts)";
                WarrantyNotificationLog."Notification Date" := WorkDate();
                WarrantyNotificationLog."Setup ID" := WarrantyNotificationSetup."Primary Key";
                WarrantyNotificationLog."Item List" := TempServiceItemBuffer."No.";
                WarrantyNotificationLog."Items Count" := 1;
                WarrantyNotificationLog.Insert();

                Commit();

                // ارسال ایمیل برای هر آیتم
                Clear(EmailSent);
                EmailSent := WarrantyEmailMgt.SendGroupWarrantyNotification(
                    WarrantyNotificationLog,
                    WarrantyNotificationSetup,
                    ItemsList);

                WarrantyNotificationLog."Email Sent" := EmailSent;
                if not EmailSent then begin
                    WarrantyNotificationLog."Failed" := true;
                    WarrantyNotificationLog."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
                end else begin
                    TotalEmails += 1;
                    TotalItems += 1;
                end;
                WarrantyNotificationLog.Modify();
            until TempServiceItemBuffer.Next() = 0;
    end;

    local procedure BuildSingleItemRow(var TempServiceItemBuffer: Record "Service Item" temporary) ItemsList: Text
    var
        WarrantyDate: Text;
    begin
        WarrantyDate := Format(TempServiceItemBuffer."Warranty Ending Date (Parts)");
        ItemsList := '<table border="1" cellpadding="5" style="border-collapse: collapse; width: 100%;">' +
                     '<tr style="background-color: #f2f2f2;">' +
                     '<th>شماره محصول</th>' +
                     '<th>توضیحات</th>' +
                     '<th>شماره سریال</th>' +
                     '<th>تاریخ انقضای گارانتی</th>' +
                     '</tr>' +
                     '<tr>' +
                     '<td>' + TempServiceItemBuffer."No." + '</td>' +
                     '<td>' + TempServiceItemBuffer.Description + '</td>' +
                     '<td>' + TempServiceItemBuffer."Serial No." + '</td>' +
                     '<td>' + WarrantyDate + '</td>' +
                     '</tr>' +
                     '</table>';
    end;

    local procedure LogIndividualItemsFromBuffer(
        var TempServiceItemBuffer: Record "Service Item" temporary;
        ParentEntryNo: Integer;
        Customer: Record Customer;
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        EmailSent: Boolean)
    var
        WarrantyNotificationLog: Record "Warranty Notification Log";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        NextEntryNo: Integer;
    begin
        WarrantyNotificationLog.Reset();
        if WarrantyNotificationLog.FindLast() then
            NextEntryNo := WarrantyNotificationLog."Entry No." + 1
        else
            NextEntryNo := 1;

        TempServiceItemBuffer.Reset();
        if TempServiceItemBuffer.FindSet() then
            repeat
                WarrantyNotificationLog.Init();
                WarrantyNotificationLog."Entry No." := NextEntryNo;
                WarrantyNotificationLog."Parent Entry No." := ParentEntryNo;
                WarrantyNotificationLog."Service Item No." := TempServiceItemBuffer."No.";
                WarrantyNotificationLog."Customer No." := Customer."No.";
                WarrantyNotificationLog."Customer Email" := Customer."E-Mail";
                WarrantyNotificationLog."Salesperson Code" := Customer."Salesperson Code";
                WarrantyNotificationLog."Salesperson Email" := '';
                if Customer."Salesperson Code" <> '' then begin
                    if SalespersonPurchaser.Get(Customer."Salesperson Code") then
                        WarrantyNotificationLog."Salesperson Email" := SalespersonPurchaser."E-Mail";
                end;
                WarrantyNotificationLog."Warranty End Date" := TempServiceItemBuffer."Warranty Ending Date (Parts)";
                WarrantyNotificationLog."Notification Date" := WorkDate();
                WarrantyNotificationLog."Setup ID" := WarrantyNotificationSetup."Primary Key";
                WarrantyNotificationLog."Email Sent" := EmailSent;
                WarrantyNotificationLog."Failed" := not EmailSent;
                WarrantyNotificationLog.Insert();

                NextEntryNo += 1;
            until TempServiceItemBuffer.Next() = 0;
    end;
}
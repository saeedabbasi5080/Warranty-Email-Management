codeunit 50621 "Warranty Email Management"
{
    procedure SendWarrantyNotification(var WarrantyNotificationLog: Record "Warranty Notification Log")
    var
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        ServiceItem: Record "Service Item";
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SMTPMailSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit "SMTP Mail";
        EmailBody: Text;
        EmailSubject: Text;
        Recipients: List of [Text];
    begin
        // Check warranty notification settings
        if not WarrantyNotificationSetup.FindFirst() then
            Error('Warranty notification settings not found. Please configure settings first.');

        // Check SMTP settings
        if not SMTPMailSetup.Get() then
            Error('SMTP settings not found. Please configure email settings.');

        // Get service item information
        if not ServiceItem.Get(WarrantyNotificationLog."Service Item No.") then
            Error('Service item with number %1 not found', WarrantyNotificationLog."Service Item No.");

        // Get customer information
        if not Customer.Get(WarrantyNotificationLog."Customer No.") then
            Error('Customer with number %1 not found', WarrantyNotificationLog."Customer No.");

        // Get salesperson information (if exists)
        Clear(SalespersonPurchaser);
        if WarrantyNotificationLog."Salesperson Code" <> '' then
            if not SalespersonPurchaser.Get(WarrantyNotificationLog."Salesperson Code") then
                Clear(SalespersonPurchaser);

        // Prepare email subject
        EmailSubject := WarrantyNotificationSetup."Email Subject";
        if EmailSubject = '' then
            Error('Email subject not defined in settings');

        // Prepare email body
        EmailBody := PrepareEmailBody(
            WarrantyNotificationSetup."Email Template",
            ServiceItem,
            Customer,
            SalespersonPurchaser,
            WarrantyNotificationSetup);

        // Set email recipients
        Clear(Recipients);

        // Customer
        if WarrantyNotificationLog."Customer Email" <> '' then
            Recipients.Add(WarrantyNotificationLog."Customer Email");

        // Salesperson
        if WarrantyNotificationLog."Salesperson Email" <> '' then
            Recipients.Add(WarrantyNotificationLog."Salesperson Email");

        if Recipients.Count = 0 then
            Error('No recipient is set for sending email');

        // Create message
        Clear(SMTPMail);

        SMTPMail.CreateMessage(
            WarrantyNotificationSetup."Company Name",
            SMTPMailSetup."User ID",
            Recipients,
            EmailSubject,
            EmailBody,
            true); // HTML = true

        // Send email
        ClearLastError();
        if SMTPMail.Send() then begin
            // Update log
            WarrantyNotificationLog."Email Sent" := true;
            WarrantyNotificationLog."Email Sent DateTime" := CurrentDateTime;
            WarrantyNotificationLog."Failed" := false;
            WarrantyNotificationLog."Error Message" := '';
        end else begin
            // Log error
            WarrantyNotificationLog."Email Sent" := false;
            WarrantyNotificationLog."Failed" := true;
            WarrantyNotificationLog."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
            Error('Error sending email: %1', GetLastErrorText());
        end;

        WarrantyNotificationLog.Modify();
    end;

    local procedure PrepareEmailBody(Template: Text; ServiceItem: Record "Service Item"; Customer: Record Customer; SalespersonPurchaser: Record "Salesperson/Purchaser"; WarrantyNotificationSetup: Record "Warranty Notification Setup") Result: Text
    var
        ContactName: Text;
    begin
        Result := Template;

        // Select contact name - customer or salesperson
        ContactName := Customer.Name;
        if Customer.Contact <> '' then
            ContactName := Customer.Contact;

        if SalespersonPurchaser.Code <> '' then
            if SalespersonPurchaser.Name <> '' then
                ContactName := SalespersonPurchaser.Name;

        // Replace fields in template
        Result := Result.Replace('[نام مشتری/کارشناس فروش]', ContactName);
        Result := Result.Replace('[item no]', ServiceItem."No.");
        Result := Result.Replace('[item serial no]', ServiceItem."Serial No.");
        Result := Result.Replace('[item description]', ServiceItem.Description);
        Result := Result.Replace('[warranty ending date]', Format(ServiceItem."Warranty Ending Date (Parts)"));
        Result := Result.Replace('[support email]', WarrantyNotificationSetup."Support Email");
        Result := Result.Replace('[support phone]', WarrantyNotificationSetup."Support Phone");
        Result := Result.Replace('[company name]', WarrantyNotificationSetup."Company Name");
    end;

    procedure SendTestEmail(EmailAddress: Text[80]; SetupKey: Code[10])
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit "SMTP Mail";
        EmailBody: Text;
        EmailSubject: Text;
        Recipients: List of [Text];
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
    begin
        // استفاده دقیق از SetupKey برای بازیابی رکورد مورد نظر
        if not WarrantyNotificationSetup.Get(SetupKey) then
            Error('Setup record with key %1 not found', SetupKey);

        // بررسی تنظیمات SMTP
        if not SMTPMailSetup.Get() then
            Error('SMTP settings not found. Please configure email settings.');

        // آماده‌سازی موضوع ایمیل از رکورد انتخاب شده
        EmailSubject := StrSubstNo('%1 (Test)', WarrantyNotificationSetup."Email Subject");
        if EmailSubject = ' (Test)' then
            EmailSubject := 'Warranty Notification (Test)';

        // آماده‌سازی متن ایمیل از رکورد انتخاب شده
        EmailBody := WarrantyNotificationSetup."Email Template";

        // جایگزینی متغیرها با مقادیر تست
        EmailBody := EmailBody.Replace('[نام مشتری/کارشناس فروش]', 'Test User');
        EmailBody := EmailBody.Replace('[item no]', 'ITEM-TEST');
        EmailBody := EmailBody.Replace('[item serial no]', 'SN-TEST-123');
        EmailBody := EmailBody.Replace('[item description]', 'Test Product');
        EmailBody := EmailBody.Replace('[warranty ending date]', Format(CalcDate('<+30D>', WorkDate())));
        EmailBody := EmailBody.Replace('[support email]', WarrantyNotificationSetup."Support Email");
        EmailBody := EmailBody.Replace('[support phone]', WarrantyNotificationSetup."Support Phone");
        EmailBody := EmailBody.Replace('[company name]', WarrantyNotificationSetup."Company Name");

        // پاک کردن لیست گیرندگان قبلی
        Clear(Recipients);

        // اضافه کردن فقط یک گیرنده - آدرس ایمیل مشخص شده
        Recipients.Add(EmailAddress);

        // ساخت پیام ایمیل
        Clear(SMTPMail);
        SMTPMail.CreateMessage(
            WarrantyNotificationSetup."Company Name",
            SMTPMailSetup."User ID",
            Recipients,
            EmailSubject,
            EmailBody,
            true); // HTML = true

        // ارسال ایمیل - فقط یک بار
        ClearLastError();
        if SMTPMail.Send() then
            Message('Test email sent successfully to %1', EmailAddress)
        else
            Error('Error sending test email: %1', GetLastErrorText());
    end;

    // Add to Warranty Email Management codeunit
    procedure SendGroupWarrantyNotification(
        var WarrantyNotificationLog: Record "Warranty Notification Log";
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        ItemsList: Text) EmailSent: Boolean
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit "SMTP Mail";
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        EmailBody: Text;
        EmailSubject: Text;
        Recipients: List of [Text];
        ContactName: Text;
    begin
        EmailSent := false;

        // Check SMTP settings
        if not SMTPMailSetup.Get() then
            Error('SMTP settings not found. Please configure email settings.');

        // Get customer information
        if not Customer.Get(WarrantyNotificationLog."Customer No.") then
            Error('Customer with number %1 not found', WarrantyNotificationLog."Customer No.");

        // Get salesperson information (if exists)
        Clear(SalespersonPurchaser);
        if WarrantyNotificationLog."Salesperson Code" <> '' then
            if not SalespersonPurchaser.Get(WarrantyNotificationLog."Salesperson Code") then
                Clear(SalespersonPurchaser);

        // Prepare email subject
        EmailSubject := WarrantyNotificationSetup."Email Subject";
        if EmailSubject = '' then
            EmailSubject := 'Your warranty will expire soon';

        // Select contact name - customer or salesperson
        ContactName := Customer.Name;
        if Customer.Contact <> '' then
            ContactName := Customer.Contact;

        // Prepare email body
        EmailBody := WarrantyNotificationSetup."Email Template";
        EmailBody := EmailBody.Replace('[نام مشتری/کارشناس فروش]', ContactName);
        EmailBody := EmailBody.Replace('[company name]', WarrantyNotificationSetup."Company Name");
        EmailBody := EmailBody.Replace('[support email]', WarrantyNotificationSetup."Support Email");
        EmailBody := EmailBody.Replace('[support phone]', WarrantyNotificationSetup."Support Phone");

        // Add the items list at the bottom of the email
        EmailBody += '<br/><br/><h3>لیست محصولات با گارانتی در حال انقضا:</h3><br/>';
        EmailBody += ItemsList;

        // Set email recipients
        Clear(Recipients);

        // Customer
        if WarrantyNotificationLog."Customer Email" <> '' then
            Recipients.Add(WarrantyNotificationLog."Customer Email");

        // Salesperson
        if WarrantyNotificationLog."Salesperson Email" <> '' then
            Recipients.Add(WarrantyNotificationLog."Salesperson Email");

        if Recipients.Count = 0 then
            exit(false);

        // Create message
        Clear(SMTPMail);
        SMTPMail.CreateMessage(
            WarrantyNotificationSetup."Company Name",
            SMTPMailSetup."User ID",
            Recipients,
            EmailSubject,
            EmailBody,
            true); // HTML = true

        // Send email
        ClearLastError();
        if SMTPMail.Send() then begin
            WarrantyNotificationLog."Email Sent DateTime" := CurrentDateTime;
            EmailSent := true;
        end;

        exit(EmailSent);
    end;
}
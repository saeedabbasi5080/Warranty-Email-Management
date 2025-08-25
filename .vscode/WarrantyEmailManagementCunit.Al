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
        if not WarrantyNotificationSetup.Get() then
            if not WarrantyNotificationSetup.FindFirst() then begin
                WarrantyNotificationSetup.Init();
                WarrantyNotificationSetup."Primary Key" := 'DEFAULT';
                WarrantyNotificationSetup.Insert();
                WarrantyNotificationSetup.SetDefaultTemplate();
                WarrantyNotificationSetup.Modify();
            end;

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
            EmailSubject := 'Your warranty will expire soon';

        // Prepare email body
        EmailBody := PrepareEmailBody(
            WarrantyNotificationSetup.GetEmailTemplate(),
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

        // Notification for debugging
        Message('Sending email from %1 to %2 recipient(s)',
            SMTPMailSetup."User ID", Format(Recipients.Count));

        // Show SMTP info for debugging
        Message('SMTP settings:\nServer: %1\nPort: %2\nUser: %3\nSSL/TLS: %4',
            SMTPMailSetup."SMTP Server", SMTPMailSetup."SMTP Server Port",
            SMTPMailSetup."User ID", Format(SMTPMailSetup."Secure Connection"));

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
            Message('Email sent successfully');
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

    procedure SendTestEmail(EmailAddress: Text[80])
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
        ErrorText: Text;
    begin
        if not WarrantyNotificationSetup.Get() then
            if not WarrantyNotificationSetup.FindFirst() then
                Error('Warranty notification setup not found');

        // Check SMTP settings
        if not SMTPMailSetup.Get() then
            Error('SMTP settings not found. Please configure email settings.');

        // Show SMTP info for debugging
        Message('SMTP info:\nServer: %1\nPort: %2\nUser: %3\nSSL/TLS: %4',
            SMTPMailSetup."SMTP Server", SMTPMailSetup."SMTP Server Port",
            SMTPMailSetup."User ID", Format(SMTPMailSetup."Secure Connection"));

        // Prepare email template with sample values
        EmailSubject := StrSubstNo('%1 (Test)', WarrantyNotificationSetup."Email Subject");

        // Use sample values
        EmailBody := PrepareEmailBody(
            WarrantyNotificationSetup.GetEmailTemplate(),
            ServiceItem,
            Customer,
            SalespersonPurchaser,
            WarrantyNotificationSetup);

        // Replace sample info
        EmailBody := EmailBody.Replace('[نام مشتری/کارشناس فروش]', 'Test User');
        EmailBody := EmailBody.Replace('[item no]', 'ITEM-TEST');
        EmailBody := EmailBody.Replace('[warranty ending date]', Format(CalcDate('<+3M>', WorkDate())));

        Clear(SMTPMail);

        // Set recipients list
        Clear(Recipients);
        Recipients.Add(EmailAddress);
        Message('Sending test email to: %1', EmailAddress);

        // Create message
        SMTPMail.CreateMessage(
            WarrantyNotificationSetup."Company Name",
            SMTPMailSetup."User ID",
            Recipients,
            EmailSubject,
            EmailBody,
            true);

        // Send email
        ClearLastError();
        if not SMTPMail.Send() then begin
            ErrorText := GetLastErrorText();
            Message('Error sending test email: %1', ErrorText);
            Error(ErrorText);
        end else
            Message('Test email sent successfully to %1', EmailAddress);
    end;
}
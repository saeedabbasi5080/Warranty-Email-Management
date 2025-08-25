
//*****
table 50620 "Warranty Notification Setup"
{
    Caption = 'Warranty Notification Settings';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Notification Enabled"; Boolean)
        {
            Caption = 'Notification is enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(3; "Days Before Expiry"; Integer)
        {
            Caption = 'Days before expiry';
            DataClassification = CustomerContent;
            InitValue = 90; // 3 months
            MinValue = 1;
        }
        field(4; "Email Subject"; Text[100])
        {
            Caption = 'Email subject';
            DataClassification = CustomerContent;
            InitValue = 'Your warranty will expire soon';
        }
        field(5; "Email Template"; Blob)
        {
            Caption = 'Email template';
            DataClassification = CustomerContent;
        }
        field(6; "Support Email"; Text[80])
        {
            Caption = 'Support email';
            DataClassification = CustomerContent;
        }
        field(7; "Support Phone"; Text[30])
        {
            Caption = 'Support phone';
            DataClassification = CustomerContent;
        }
        field(8; "Company Name"; Text[100])
        {
            Caption = 'Company name';
            DataClassification = CustomerContent;
        }
        field(9; "Send Test Email To"; Text[80])
        {
            Caption = 'Send test email to';
            DataClassification = CustomerContent;
        }
        field(10; "Last Run Date"; Date)
        {
            Caption = 'Last run date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        DefaultEmailTemplateTxt: Label 'Subject: Your warranty will expire soon\r\nDear [Customer Name/Salesperson],\r\nWe hope you receive this message well. This is a friendly reminder that your warranty for [item no] will expire on [warranty ending date].\r\n\r\nTo ensure continued protection of your product, we recommend:\r\n\r\n• Schedule any ongoing repairs or maintenance under warranty.\r\n\r\n• If needed, review extended warranty options ([link to details, if available]).\r\n\r\nIf you have any questions or need assistance, feel free to contact us via [support email/phone] or reply to this email.\r\n\r\nThank you for trusting [your company name]!';

    procedure SetDefaultTemplate()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        // اصلاح شده برای BC 2019
        "Email Template".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(DefaultEmailTemplateTxt);
        Modify();
    end;

    procedure GetEmailTemplate() TemplateText: Text
    var
        InStr: InStream;
    begin
        if not "Email Template".HasValue() then
            SetDefaultTemplate();

        CalcFields("Email Template");
        "Email Template".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(TemplateText);
        exit(TemplateText);
    end;

    procedure SetEmailTemplate(NewTemplate: Text)
    var
        OutStr: OutStream;
    begin
        // اصلاح شده برای BC 2019
        "Email Template".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewTemplate);
        Modify();
    end;
}
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
        }
        field(3; "Days Before Expiry"; Integer)
        {
            Caption = 'Days before expiry';
            DataClassification = CustomerContent;
            MinValue = 1;
        }
        field(4; "Email Subject"; Text[100])
        {
            Caption = 'Email subject';
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
        field(11; "Email Template"; Text[2048])
        {
            Caption = 'Email Template';
            DataClassification = CustomerContent;
        }
        field(15; "Email Signature"; Text[2048])
        {
            Caption = 'Email Signature';
            DataClassification = CustomerContent;
        }
        field(16; "Additional Message"; Text[2048])
        {
            Caption = 'Additional Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
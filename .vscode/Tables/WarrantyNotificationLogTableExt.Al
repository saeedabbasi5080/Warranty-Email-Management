//*******************

table 50621 "Warranty Notification Log"
{
    Caption = 'Warranty Notification Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry Number';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Service Item No."; Code[20])
        {
            Caption = 'Service Item Number';
            DataClassification = CustomerContent;
            TableRelation = "Service Item";
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(4; "Customer Email"; Text[80])
        {
            Caption = 'Customer Email';
            DataClassification = CustomerContent;
        }
        field(5; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6; "Salesperson Email"; Text[80])
        {
            Caption = 'Salesperson Email';
            DataClassification = CustomerContent;
        }
        field(7; "Warranty End Date"; Date)
        {
            Caption = 'Warranty End Date';
            DataClassification = CustomerContent;
        }
        field(8; "Notification Date"; Date)
        {
            Caption = 'Notification Date';
            DataClassification = CustomerContent;
        }
        field(9; "Email Sent"; Boolean)
        {
            Caption = 'Email Sent';
            DataClassification = CustomerContent;
        }
        field(10; "Email Sent DateTime"; DateTime)
        {
            Caption = 'Email Sent DateTime';
            DataClassification = CustomerContent;
        }
        field(11; "Failed"; Boolean)
        {
            Caption = 'Failed';
            DataClassification = CustomerContent;
        }
        field(12; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(15; "Setup ID"; Code[10])
        {
            Caption = 'Setup ID';
            DataClassification = CustomerContent;
        }
        field(16; "Parent Entry No."; Integer)
        {
            Caption = 'Parent Entry No.';
            DataClassification = CustomerContent;
        }
        field(17; "Item List"; Text[250])
        {
            Caption = 'Item List (Preview)';
            DataClassification = CustomerContent;
        }
        field(18; "Items Count"; Integer)
        {
            Caption = 'Number of Items';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Service Item No.", "Notification Date")
        {
        }
        key(SK2; "Customer No.", "Notification Date")
        {
        }
        key(SK3; "Warranty End Date")
        {
        }
        key(SK4; "Failed", "Email Sent")
        {
        }
    }
}
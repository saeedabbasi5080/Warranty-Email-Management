//*******
page 50620 "Warranty Notification Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Warranty Notification Setup";
    Caption = 'Warranty Notification Settings';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Notification Enabled"; Rec."Notification Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the warranty expiration notification is enabled';
                }
                field("Days Before Expiry"; Rec."Days Before Expiry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of days before warranty expiration to send notification';
                }
                field("Last Run Date"; Rec."Last Run Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of last warranty notification system run';
                    Editable = false;
                }
            }

            group(EmailSettings)
            {
                Caption = 'Email Settings';
                field("Email Subject"; Rec."Email Subject")
                {
                    ApplicationArea = All;
                    ToolTip = 'Email subject sent for warranty expiration notification';
                }
                field("Email Template Text"; Rec."Email Template")
                {
                    ApplicationArea = All;
                    Caption = 'Email Template Text';
                    ToolTip = 'Email body for warranty expiration notification. You can use available parameters in the guide';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        Rec.Validate("Email Template");
                    end;
                }
                field("Support Email"; Rec."Support Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Support email address used in the email body';
                }
                field("Support Phone"; Rec."Support Phone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Support phone number used in the email body';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Company name used in the email body';
                }
            }

            group(Testing)
            {
                Caption = 'Testing';
                field("Send Test Email To"; Rec."Send Test Email To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Email address to send test email to';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendTestEmail)
            {
                ApplicationArea = All;
                Caption = 'Send Test Email';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Send a test email to check the settings';

                trigger OnAction()
                var
                    WarrantyEmailMgt: Codeunit "Warranty Email Management";
                begin
                    if Rec."Send Test Email To" = '' then
                        Error('Please enter the test email address');

                    WarrantyEmailMgt.SendTestEmail(Rec."Send Test Email To", Rec."Primary Key");
                end;
            }

            action(RunNotificationProcess)
            {
                ApplicationArea = All;
                Caption = 'Run Notification Process';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Run the notification process to check service items that are expiring';

                trigger OnAction()
                var
                    WarrantyNotificationMgt: Codeunit "Warranty Notification Mgt.";
                begin
                    WarrantyNotificationMgt.RunWarrantyNotificationProcess();
                end;
            }

            action(SetupList)
            {
                ApplicationArea = All;
                Caption = 'Setup List';
                Image = List;
                RunObject = page "Warranty Notification List";
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View all notification setup configurations';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
        NewCode: Integer;
    begin
        // Generate unique Primary Key for new records
        if WarrantyNotificationSetup.FindLast() then begin
            if Evaluate(NewCode, WarrantyNotificationSetup."Primary Key") then
                NewCode += 1
            else
                NewCode := 1;
        end else
            NewCode := 1;

        Rec."Primary Key" := Format(NewCode, 0, '<Integer,4><Filler,0>');
        Rec."Notification Enabled" := true;
        Rec."Days Before Expiry" := 90;
    end;
}
//****************

page 50621 "Warranty Notification Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Warranty Notification Log";
    Caption = 'Warranty Notification Log';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique entry number';
                }
                field("Service Item No."; Rec."Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Service item number';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer number';
                }
                field("Customer Email"; Rec."Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer email';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Salesperson code';
                }
                field("Salesperson Email"; Rec."Salesperson Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Salesperson email';
                }
                field("Warranty End Date"; Rec."Warranty End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Warranty end date';
                }
                field("Notification Date"; Rec."Notification Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Notification date';
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the email has been sent';
                }
                field("Email Sent DateTime"; Rec."Email Sent DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Email sent date and time';
                }
                field("Failed"; Rec."Failed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether email sending failed';
                    StyleExpr = FailedStyle;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error message if exists';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResendEmail)
            {
                ApplicationArea = All;
                Caption = 'Resend Email';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Resend notification email';

                trigger OnAction()
                var
                    WarrantyEmailMgt: Codeunit "Warranty Email Management";
                begin
                    if not Confirm('Do you want to resend the email?') then
                        exit;

                    WarrantyEmailMgt.SendWarrantyNotification(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Failed" then
            FailedStyle := 'Unfavorable'
        else
            FailedStyle := 'Standard';
    end;

    var
        FailedStyle: Text;
}
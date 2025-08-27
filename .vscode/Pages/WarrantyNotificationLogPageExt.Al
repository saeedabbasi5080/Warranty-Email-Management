page 50621 "Warranty Notification Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Warranty Notification Log";
    Caption = 'Warranty Notification Log';
    Editable = false;
    // CardPageId حذف شده است

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number';
                    Style = Strong;
                    StyleExpr = IsGroupEntry;
                }
                field("Service Item No."; Rec."Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service item number';
                    StyleExpr = ServiceItemStyle;
                }
                field("Items Count"; Rec."Items Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many items are included in this notification';
                    BlankZero = true;
                    Visible = ShowGroupFields;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number';
                }
                field("Customer Email"; Rec."Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer email address';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the salesperson code';
                }
                field("Warranty End Date"; Rec."Warranty End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the warranty end date';
                }
                field("Notification Date"; Rec."Notification Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the notification was sent';
                }
                field("Setup ID"; Rec."Setup ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which notification setup was used';
                }
                field("Parent Entry No."; Rec."Parent Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent entry number for detail records';
                    Visible = ShowDetailFields;
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the email was sent';
                }
                field("Email Sent DateTime"; Rec."Email Sent DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the email was sent';
                }
                field("Failed"; Rec."Failed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the notification failed';
                    StyleExpr = FailedStyle;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if notification failed';
                    Visible = ShowErrorMessage;
                }
            }
        }
        // بخش FactBoxes حذف شده است
    }

    actions
    {
        area(Processing)
        {
            action(ViewItems)
            {
                ApplicationArea = All;
                Caption = 'View Included Items';
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View all items included in this notification group';
                Visible = Rec."Service Item No." = 'MULTI';

                trigger OnAction()
                var
                    WarrantyLog: Record "Warranty Notification Log";
                begin
                    WarrantyLog.Reset();
                    WarrantyLog.SetRange("Parent Entry No.", Rec."Entry No.");
                    Page.Run(Page::"Warranty Notification Log", WarrantyLog);
                end;
            }

            action(ViewParent)
            {
                ApplicationArea = All;
                Caption = 'View Parent Notification';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the parent notification that includes this item';
                Visible = Rec."Parent Entry No." <> 0;

                trigger OnAction()
                var
                    WarrantyLog: Record "Warranty Notification Log";
                    FilteredLog: Record "Warranty Notification Log";
                begin
                    // به جای باز کردن صفحه کارت، رکورد مربوطه را در همین صفحه نمایش می‌دهیم
                    if WarrantyLog.Get(Rec."Parent Entry No.") then begin
                        FilteredLog.Reset();
                        FilteredLog.SetRange("Entry No.", Rec."Parent Entry No.");
                        Page.Run(Page::"Warranty Notification Log", FilteredLog);
                    end;
                end;
            }
        }
    }

    views
    {
        view(AllEntries)
        {
            Caption = 'All Entries';
        }
        view(GroupEntries)
        {
            Caption = 'Group Notifications';
            Filters = where("Service Item No." = const('MULTI'));
        }
        view(IndividualEntries)
        {
            Caption = 'Individual Item Logs';
            Filters = where("Parent Entry No." = filter(<> 0));
        }
        view(FailedNotifications)
        {
            Caption = 'Failed Notifications';
            Filters = where(Failed = const(true));
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsGroupEntry := Rec."Service Item No." = 'MULTI';
        ShowGroupFields := IsGroupEntry;
        ShowDetailFields := Rec."Parent Entry No." <> 0;
        ShowErrorMessage := Rec."Failed";

        if Rec."Failed" then
            FailedStyle := 'Unfavorable'
        else
            FailedStyle := 'StandardAccent';

        if IsGroupEntry then
            ServiceItemStyle := 'Strong'
        else
            ServiceItemStyle := 'Standard';
    end;

    var
        IsGroupEntry: Boolean;
        ShowGroupFields: Boolean;
        ShowDetailFields: Boolean;
        ShowErrorMessage: Boolean;
        FailedStyle: Text;
        ServiceItemStyle: Text;
}
page 50622 "Warranty Notification List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Warranty Notification Setup";
    CardPageId = "Warranty Notification Setup";
    Editable = false;
    Caption = 'Warranty Notification Setup List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the identifier of the setup record';
                }
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
                field("Email Subject"; Rec."Email Subject")
                {
                    ApplicationArea = All;
                    ToolTip = 'Email subject sent for warranty expiration notification';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Company name used in the email body';
                }
                field("Last Run Date"; Rec."Last Run Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of last warranty notification system run';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Card)
            {
                ApplicationArea = All;
                Caption = 'Card';
                Image = EditLines;
                RunObject = page "Warranty Notification Setup";
                RunPageLink = "Primary Key" = field("Primary Key");
                ShortCutKey = 'Shift+F7';
                ToolTip = 'View or edit the setup details';
                Promoted = true;
                PromotedCategory = Process;
            }
        }
        area(Processing)
        {
            action(CreateNew)
            {
                ApplicationArea = All;
                Caption = 'Create New Setup';
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create a new warranty notification setup';

                trigger OnAction()
                var
                    WarrantyNotificationSetup: Record "Warranty Notification Setup";
                    WarrantyNotificationSetupPage: Page "Warranty Notification Setup";
                    LastSetupCode: Code[10];
                    NewSetupCode: Integer;
                begin
                    // Find the highest existing setup code
                    WarrantyNotificationSetup.Reset();
                    if WarrantyNotificationSetup.FindLast() then begin
                        // Try to convert the last code to a number and increment it
                        if Evaluate(NewSetupCode, WarrantyNotificationSetup."Primary Key") then
                            NewSetupCode += 1
                        else
                            NewSetupCode := 1;
                    end else
                        NewSetupCode := 1;

                    // Create a new record with unique Primary Key
                    WarrantyNotificationSetup.Init();
                    WarrantyNotificationSetup."Primary Key" := Format(NewSetupCode, 0, '<Integer,4><Filler,0>'); // Format as "0001", "0002", etc.

                    // Set some default values
                    WarrantyNotificationSetup."Notification Enabled" := true;
                    WarrantyNotificationSetup."Days Before Expiry" := 90;

                    // Open the card page with new record
                    WarrantyNotificationSetupPage.SetRecord(WarrantyNotificationSetup);
                    WarrantyNotificationSetupPage.Run();
                end;
            }
        }
    }
}
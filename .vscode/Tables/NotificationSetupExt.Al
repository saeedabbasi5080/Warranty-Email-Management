tableextension 50647 NotificationSetupExt extends "Notification Setup"
{
    fields
    {

        modify("User ID")
        {
            trigger OnBeforeValidate()
            begin
                if Rec."Notification Type" = "Notification Entry Type"::"Warranty 90 Days" then
                    Error('برای نوع اعلان Warranty 90 Days مجاز به وارد کردن User ID نیستید.');
            end;
        }
        modify("Notification Type")
        {
            trigger OnBeforeValidate()
            begin
                if "Notification Type" = "Notification Entry Type"::"Warranty 90 Days" then
                    Error('برای نوع اعلان Warranty 90 Days مجاز به وارد کردن User ID نیستید.');
            end;

            trigger OnAfterValidate()
            var
                OldNotificationType: Enum "Notification Entry Type";
            begin
                OldNotificationType := Rec."Notification Type";

                if (Rec."Notification Type" = "Notification Entry Type"::"Warranty 90 Days") and (UserIdDelete = '') then
                    CreateWarrantyNotificationJob();

                if (OldNotificationType = "Notification Entry Type"::"Warranty 90 Days") and
                   (Rec."Notification Type" <> "Notification Entry Type"::"Warranty 90 Days") then
                    TryDeleteWarrantyNotificationJob();
            end;
        }
    }

    trigger OnDelete()
    begin
        DeletedNotificationType := Rec."Notification Type";
        UserIdDelete := Rec."User ID";
    end;

    trigger OnAfterDelete()
    begin
        if DeletedNotificationType = "Notification Entry Type"::"Warranty 90 Days" then
            TryDeleteWarrantyNotificationJob();
    end;

    local procedure CreateWarrantyNotificationJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", 50620); // Warranty Notification Mgt.
        if not JobQueueEntry.FindFirst() then begin
            JobQueueEntry.Init();
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := 50620;
            JobQueueEntry.Description := 'Daily Warranty Notification';
            JobQueueEntry."Earliest Start Date/Time" := CURRENTDATETIME;
            JobQueueEntry."No. of Minutes between Runs" := 1440;
            JobQueueEntry.Status := JobQueueEntry.Status::Ready;
            JobQueueEntry.Insert(true);
        end;
    end;

    local procedure TryDeleteWarrantyNotificationJob()
    var
        NotificationSetup: Record "Notification Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        NotificationSetup.Reset();
        NotificationSetup.SetFilter("Notification Type", '<>%1', "Notification Entry Type"::"Warranty 90 Days");
        if NotificationSetup.FindSet() then begin
            JobQueueEntry.Reset();
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            JobQueueEntry.SetRange("Object ID to Run", 50620); // Warranty Notification Mgt.
            if JobQueueEntry.FindFirst() then
                JobQueueEntry.Delete();
        end;

    end;

    var
        DeletedNotificationType: Enum "Notification Entry Type";
        UserIdDelete: Code[50];
}
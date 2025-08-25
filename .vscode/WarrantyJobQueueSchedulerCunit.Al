codeunit 50622 "Warranty Job Queue Scheduler"
{
    trigger OnRun()
    begin
        CreateJobQueueEntry();
    end;

    procedure CreateJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        WarrantyNotificationSetup: Record "Warranty Notification Setup";
    begin
        if not WarrantyNotificationSetup.Get() then
            Error('Warranty notification settings not found');

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Warranty Notification Mgt.";
        JobQueueEntry.Description := 'Automatic execution of the warranty notification process';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := true;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Starting Time" := 010000T; // 01:00 AM
        JobQueueEntry."Ending Time" := 020000T;   // 02:00 AM
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
        JobQueueEntry.Insert(true);

        Message('Job queue entry created successfully. Please change its status to "Ready" to start.');
    end;
}
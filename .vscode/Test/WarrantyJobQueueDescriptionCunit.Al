// codeunit 50623 "Warranty Job Queue Description"
// {
//     // This codeunit is only responsible for setting descriptions for job queue entries related to warranty notifications
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeEnqueueJobQueueEntry', '', false, false)]
//     local procedure OnBeforeEnqueueJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
//     begin
//         if JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit then
//             if JobQueueEntry."Object ID to Run" = Codeunit::"Warranty Notification Mgt." then
//                 JobQueueEntry.Description := 'Automatic execution of the warranty notification process';
//     end;
// }
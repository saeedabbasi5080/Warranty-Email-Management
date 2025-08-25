// //******************

// tableextension 50620 "Service Item Extension" extends "Service Item"
// {
//     fields
//     {
//         // Add link to the notifications page
//         field(50100; "Show Warranty Notifications"; Boolean)
//         {
//             Caption = 'Show Warranty Notifications';
//             FieldClass = FlowField;
//             CalcFormula = exist("Warranty Notification Log" where("Service Item No." = field("No.")));
//             Editable = false;
//         }
//     }
// }
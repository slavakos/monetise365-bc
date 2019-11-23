page 50127 "Mixed Sample"
{
    PageType = List;
    Caption = 'Mixed Sample';
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Customer";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("no."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DoStandardAction)
            {
                ApplicationArea = All;
                Caption = 'Do Standard Action';

                trigger OnAction();
                var

                begin
                    Message('Standard action completed.');
                end;
            }
            action(DoEnterpriseAction)
            {
                ApplicationArea = All;
                Caption = 'Do Enterprise Action';

                trigger OnAction();
                var

                begin
                    Message('Enterprise action completed.');
                end;
            }
        }
    }
    var
        CU: Codeunit 50100;

}
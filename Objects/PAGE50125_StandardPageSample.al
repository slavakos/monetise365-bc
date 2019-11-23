page 50125 "Standard Sample"
{
    PageType = List;
    Caption = 'Standard Sample';
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
        }
    }
    var
        CU: Codeunit 50100;

    trigger OnOpenPage()
    var
    begin
    end;

}
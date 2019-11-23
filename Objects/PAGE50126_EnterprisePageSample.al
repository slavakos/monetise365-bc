page 50126 "Enterprise Sample"
{
    PageType = List;
    Caption = 'Enterprise Sample';
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
codeunit 50100 SubscriptionManagement
{
    EventSubscriberInstance = StaticAutomatic;
    SingleInstance = true;

    var
        ErrorLabel: Label 'This item is only allowed in the following subscription plans: %1. Your current subscription plan(s): %2.';
        EnvironmentInfo: Codeunit "Environment Information";
        TenantInfo: Codeunit "Tenant Information";

        // CACHE VARS REGION
        IsInitialised: Boolean;
        ApiUri: Text;
        ApiKey: Text;
        ApiSecret: Text;
        ProductUniqueIdentifier: Text;
        CurrentActivePlanList: List of [Text];
    // ADD YOUR GLOBAL VARs HERE:

    // INTERNAL USE PROCEDURES 
    local procedure Init()
    begin
        // Set your unique values:
        ApiKey := '<your_api_key>';
        ApiSecret := '<your_api_secret>';
        ProductUniqueIdentifier := '<your_product_id>';

        // Do not modify
        ApiUri := 'http://dev.monetise365.com/api/subscription/';
        CLEAR(CurrentActivePlanList);
    end;

    local procedure CheckSubscriptionForObject(AllowedPlans: Text; Object: Variant; ObjectMetadata: Variant)
    begin
        RunSubscriptionCheck(AllowedPlans, '', '', false);
    end;

    local procedure ValidateSubscriptionForObject(AllowedPlans: Text; Object: Variant; ObjectMetadata: Variant): Boolean;
    begin
        exit(RunSubscriptionCheck(AllowedPlans, '', '', true));
    end;

    local procedure CheckSubscription(AllowedPlans: Text): Boolean;
    begin
        exit(RunSubscriptionCheck(AllowedPlans, '', '', false));
    end;

    local procedure ValidateSubscription(AllowedPlans: Text)
    begin
        RunSubscriptionCheck(AllowedPlans, '', '', true);
    end;

    local procedure RunSubscriptionCheck(AllowedPlans: Text; Object: Variant; ObjectMetadata: Variant; RaiseError: Boolean): Boolean
    var
        JArray: JsonArray;
        JToken: JsonToken;
        JTokenPlan: JsonToken;
        JObject: JsonObject;
        JsonPayload: JsonObject;
        JsonPayloadText: Text;
        ResponseText: Text;
        AllowedPlansList: List of [Text];
        CurrentActivePlans: Text;
        Stream: InStream;
        i: Integer;
        check_passed: Boolean;
    begin
        if not IsInitialised then begin
            Init();
            IsInitialised := true;
        end;
        if CurrentActivePlanList.Count = 0 then begin
            JsonPayload.Add('api_key', ApiKey);
            JsonPayload.Add('api_secret', ApiSecret);
            JsonPayload.Add('ProductUID', ProductUniqueIdentifier);
            JsonPayload.Add('TenantId', TenantInfo.GetTenantId());
            JsonPayload.Add('IsProduction', EnvironmentInfo.IsProduction());
            JsonPayload.Add('IsSandbox', EnvironmentInfo.IsSandbox());
            JsonPayload.Add('CompanyName', CompanyName());
            JsonPayload.Add('UserId', UserId());

            JsonPayload.WriteTo(JsonPayloadText);
            ResponseText := MakeRequest(ApiUri, 'POST', JsonPayloadText);
            JToken.ReadFrom(ResponseText);

            JArray := JToken.AsArray();
            for i := 0 to JArray.Count - 1 do begin
                JArray.Get(i, JToken);
                JObject := JToken.AsObject();
                JObject.Get('plan', JTokenPlan);
                if (Format(JTokenPlan.AsValue()) <> 'null') and (Format(JTokenPlan.AsValue()) <> '') then begin
                    CurrentActivePlanList.Add(Format(JTokenPlan.AsValue()).Trim());
                end;
            end;
        end;

        AllowedPlansList := AllowedPlans.Split(',');
        i := 1;
        while (i <= CurrentActivePlanList.Count()) and not check_passed do begin
            if not check_passed then
                check_passed := AllowedPlansList.Contains(CurrentActivePlanList.Get(i));

            // Build a string of active plans for error message (if occurs)
            // TODO: remove
            if CurrentActivePlans <> '' then
                CurrentActivePlans := CurrentActivePlans + ', ';
            CurrentActivePlans := CurrentActivePlans + CurrentActivePlanList.Get(i);

            i += 1;
        end;
        if not check_passed then
            if RaiseError then
                Error(ErrorLabel, AllowedPlans, CurrentActivePlans)
            else
                exit(False);

        exit(true);
    end;

    local procedure MakeRequest(uri: Text; method: Text; payload: Text) responseText: Text;
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
    begin
        // Add the payload to the content
        content.WriteFrom(payload);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        request.Content := content;
        request.SetRequestUri(uri);
        request.Method := method;
        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
    end;

    // EVENT SUBSCRIBERS REGION
    // TODO: ADD YOUR SUBSCRIBERS HERE:

    // SAMPLES:
    [EventSubscriber(ObjectType::Page, 50125, 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenPage50125()
    begin
        ValidateSubscription('"Standard","Enterprise"');
    end;

    [EventSubscriber(ObjectType::Page, 50125, 'OnBeforeActionEvent', 'DoStandardAction', true, true)]
    local procedure OnActionDoStandardActionPage50125()
    begin
        ValidateSubscription('"Standard","Enterprise"');
    end;

    [EventSubscriber(ObjectType::Page, 50126, 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenPage50126()
    begin
        ValidateSubscription('"Enterprise"');
    end;

    [EventSubscriber(ObjectType::Page, 50127, 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenPage50127()
    begin
        ValidateSubscription('"Standard","Enterprise"');
    end;

    [EventSubscriber(ObjectType::Page, 50127, 'OnBeforeActionEvent', 'DoStandardAction', true, true)]
    local procedure OnActionDoStandardActionPage50127()
    begin
        ValidateSubscription('"Standard","Enterprise"');
    end;

    [EventSubscriber(ObjectType::Page, 50127, 'OnBeforeActionEvent', 'DoEnterpriseAction', true, true)]
    local procedure OnActionDoEnterpriseActionPage50127()
    begin
        ValidateSubscription('"Enterprise"');
    end;
}
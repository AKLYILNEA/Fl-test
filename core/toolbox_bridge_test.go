package core

import (
	"encoding/json"
	"testing"
)

func toolboxTestCall(t *testing.T, method CoreMethod, arguments any) any {
	t.Helper()
	raw, err := json.Marshal(arguments)
	if err != nil {
		t.Fatal(err)
	}
	var response MethodResponse
	if err := json.Unmarshal(handleMethodCall(&MethodCall{ID: "toolbox-test", Method: method, Arguments: raw}), &response); err != nil {
		t.Fatal(err)
	}
	if response.Error != nil {
		t.Fatal(response.Error)
	}
	return response.Result
}

func TestToolboxAgeRoundTripUsesNativeEnvelopes(t *testing.T) {
	keys := toolboxTestCall(t, toolboxAgeKeysMethod, map[string]any{"hybrid": false}).(map[string]any)
	encrypted := toolboxTestCall(t, toolboxAgeCryptMethod, map[string]any{"mode": "encrypt", "data": "FlClash toolbox", "keys": []string{keys["public-key"].(string)}}).(map[string]any)
	if encrypted["error"] != "" {
		t.Fatal(encrypted)
	}
	decrypted := toolboxTestCall(t, toolboxAgeCryptMethod, map[string]any{"mode": "decrypt", "data": encrypted["data"], "keys": []string{keys["secret-key"].(string)}}).(map[string]any)
	if decrypted["error"] != "" || decrypted["data"] != "FlClash toolbox" {
		t.Fatal(decrypted)
	}
}

func TestToolboxRejectsNonObjectArguments(t *testing.T) {
	var response MethodResponse
	_ = json.Unmarshal(handleMethodCall(&MethodCall{Method: toolboxRouteTraceMethod, Arguments: json.RawMessage(`[]`)}), &response)
	if response.Error == nil || response.Error.Code != "invalid_arguments" {
		t.Fatal(response)
	}
}

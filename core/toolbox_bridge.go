package core

import (
	"encoding/json"
	"errors"
	"sync"

	"core/toolbox"

	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/config"
)

var toolboxAgeMu sync.Mutex

func init() {
	methodHandlers[toolboxTrafficProfileMethod] = command(func(p struct {
		Profile string `json:"profile"`
	}) error {
		toolbox.SetTrafficProfile(p.Profile)
		return nil
	})
	toolbox.Setup(toolbox.Host{
		Notify: func(kind string, data any) {
			sendMessage(ToolboxMessage, map[string]any{"kind": kind, "data": data})
		},
		State: func() (bool, *config.Config, *config.RawConfig) {
			configMu.Lock()
			defer configMu.Unlock()
			raw, _ := readRawConfig(runningConfigPath())
			return isRunning.Load(), currentConfig, raw
		},
		AgeLock: &toolboxAgeMu,
	})
	for method, handler := range map[CoreMethod]methodHandler{
		toolboxRouteTraceMethod:       toolboxJSON(toolbox.HandleRouteTrace),
		toolboxDnsQueryMethod:         toolboxJSON(toolbox.HandleDnsQuery),
		toolboxMrsPrepareMethod:       toolboxJSON(func(string) string { return toolbox.HandleMrsPrepare() }),
		toolboxMrsLookupMethod:        toolboxJSON(toolbox.HandleMrsLookup),
		toolboxMrsDumpMethod:          withArguments(func(p PathParams) string { return toolbox.HandleMrsDump(p.Path) }),
		toolboxMrsCancelMethod:        toolboxCommand(toolbox.HandleCancelMrsLookup),
		toolboxSpeedStartMethod:       toolboxJSON(toolbox.HandleStartSpeedTest),
		toolboxSpeedProbeMethod:       toolboxJSON(toolbox.HandleProbeSpeedTest),
		toolboxSpeedCancelMethod:      toolboxCommand(toolbox.HandleCancelSpeedTest),
		toolboxSpeedServersMethod:     toolboxJSON(toolbox.HandleSpeedTestServers),
		toolboxStunStartMethod:        toolboxJSON(toolbox.HandleStartStunTest),
		toolboxStunCancelMethod:       toolboxCommand(toolbox.HandleCancelStunTest),
		toolboxPingStartMethod:        toolboxJSON(toolbox.HandleStartLocalPing),
		toolboxPingCancelMethod:       toolboxCommand(toolbox.HandleCancelLocalPing),
		toolboxIperfStartMethod:       toolboxJSON(toolbox.HandleStartIperfClient),
		toolboxIperfCancelMethod:      toolboxCommand(toolbox.HandleCancelIperfClient),
		toolboxIperfListenMethod:      toolboxJSON(toolbox.HandleStartIperfServer),
		toolboxIperfStopMethod:        toolboxCommand(toolbox.HandleStopIperfServer),
		toolboxAgeCryptMethod:         toolboxJSON(toolbox.HandleAgeCrypt),
		toolboxAgeKeysMethod:          withFallible(toolboxAgeKeys),
		toolboxTrafficQueryMethod:     toolboxJSON(toolbox.HandleGetTrafficStats),
		toolboxTrafficClearMethod:     toolboxCommand(toolbox.HandleClearTrafficStats),
		toolboxTrafficConfigureMethod: command(configureToolboxTraffic),
		toolboxStoreGetMethod:         toolboxJSON(toolbox.HandleStoreGet),
		toolboxStoreSetMethod: withFallible(func(p json.RawMessage) (bool, error) {
			return toolbox.HandleStoreSet(string(p)), nil
		}),
		toolboxStoreListMethod: toolboxJSON(func(p string) string {
			var args struct {
				Space string `json:"ns"`
			}
			_ = json.Unmarshal([]byte(p), &args)
			return toolbox.HandleStoreList(args.Space)
		}),
		toolboxStoreClearMethod: command(func(p struct {
			Space string `json:"ns"`
		}) error {
			if !toolbox.HandleStoreClear(p.Space) {
				return errors.New("unknown toolbox store")
			}
			return nil
		}),
		toolboxProxyStartMethod: withoutArguments(func() int {
			var port int
			_ = json.Unmarshal([]byte(toolbox.HandleStartToolProxy()), &port)
			return port
		}),
		toolboxProxyStopMethod: toolboxCommand(toolbox.HandleStopToolProxy),
	} {
		methodHandlers[method] = handler
	}
}

func toolboxJSON(run func(string) string) methodHandler {
	return func(call *MethodCall) (any, error) {
		arguments := call.Arguments
		if len(arguments) == 0 || string(arguments) == "null" {
			arguments = json.RawMessage(`{}`)
		}
		var object map[string]any
		if err := json.Unmarshal(arguments, &object); err != nil {
			return nil, &MethodError{Code: "invalid_arguments", Message: err.Error()}
		}
		result := run(string(arguments))
		if result == "" {
			return nil, nil
		}
		var value any
		if err := json.Unmarshal([]byte(result), &value); err != nil {
			return nil, err
		}
		return value, nil
	}
}

func toolboxCommand(run func() bool) methodHandler {
	return action(func() { run() })
}

func toolboxAgeKeys(p struct {
	Hybrid bool   `json:"hybrid"`
	Secret string `json:"secret"`
}) (map[string]string, error) {
	toolboxAgeMu.Lock()
	defer toolboxAgeMu.Unlock()
	secret := p.Secret
	var public string
	var err error
	if secret != "" {
		keys, keyErr := age.ToPublicKeys(secret)
		if keyErr != nil {
			return nil, keyErr
		}
		if len(keys) == 0 {
			return nil, errors.New("missing age identity")
		}
		public = keys[0]
	} else if p.Hybrid {
		secret, public, err = age.GenHybridKeyPair()
	} else {
		secret, public, err = age.GenX25519KeyPair()
	}
	return map[string]string{"secret-key": secret, "public-key": public}, err
}

func configureToolboxTraffic(p struct {
	Options toolbox.TrafficStatsOptions `json:"options"`
	Profile string                      `json:"profile"`
}) error {
	toolbox.ConfigureTrafficStats(p.Options, p.Profile)
	encoded, err := json.Marshal(map[string]any{"ns": "toolbox", "key": "trafficSettings", "data": p.Options})
	if err != nil {
		return err
	}
	if !toolbox.HandleStoreSet(string(encoded)) {
		return errors.New("save traffic settings")
	}
	toolbox.FlushKvStore()
	return nil
}

func initToolbox(home string) {
	toolbox.InitKvStore(home)
	toolbox.InitTrafficStats(home)
	toolbox.SuspendTrafficStats(false)
	options := toolbox.DefaultTrafficStatsOptions()
	raw := toolbox.HandleStoreGet(`{"ns":"toolbox","key":"trafficSettings"}`)
	if raw != "" {
		_ = json.Unmarshal([]byte(raw), &options)
	}
	toolbox.ConfigureTrafficStats(options, "")
}

func stopToolbox() {
	toolbox.HandleCancelSpeedTest()
	toolbox.HandleCancelStunTest()
	toolbox.HandleCancelLocalPing()
	toolbox.HandleCancelIperfClient()
	toolbox.HandleStopIperfServer()
	toolbox.HandleCancelMrsLookup()
	toolbox.HandleStopToolProxy()
	toolbox.SuspendTrafficStats(true)
	toolbox.FlushTrafficStats()
	toolbox.FlushKvStore()
}

package core

import (
	"encoding/json"
	"net/netip"
	"path/filepath"
	"sync"
	"time"
)

const ipCacheTTL = 30 * 24 * time.Hour
const ipCacheLimit = 1024

type ipCacheEntry struct {
	Saved time.Time
	Data  json.RawMessage
}

// Entries are loaded only for an operation, not retained in the background.
type ipCacheStore struct {
	mu   sync.Mutex
	path string
}

var ipCache ipCacheStore

type ipCacheParams struct {
	IP   string          `json:"ip"`
	Data json.RawMessage `json:"data,omitempty"`
}

func (s *ipCacheStore) init(home string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.path = ""
	if home != "" {
		s.path = filepath.Join(home, "ip_cache.dat")
	}
}

func (s *ipCacheStore) load(now time.Time) map[string]ipCacheEntry {
	entries := map[string]ipCacheEntry{}
	if !readTrafficStoreFile(s.path, &entries) || entries == nil {
		return map[string]ipCacheEntry{}
	}
	for key, entry := range entries {
		if !now.Before(entry.Saved.Add(ipCacheTTL)) || entry.Saved.After(now) || !json.Valid(entry.Data) {
			delete(entries, key)
		}
	}
	return entries
}

func (s *ipCacheStore) get(ip string, now time.Time) json.RawMessage {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.path == "" {
		return nil
	}
	return s.load(now)[ip].Data
}

func (s *ipCacheStore) put(ip string, data json.RawMessage, now time.Time) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.path == "" {
		return nil
	}
	entries := s.load(now)
	entries[ip] = ipCacheEntry{Saved: now, Data: data}
	for len(entries) > ipCacheLimit {
		oldest := ""
		for key, entry := range entries {
			if oldest == "" || entry.Saved.Before(entries[oldest].Saved) ||
				(entry.Saved.Equal(entries[oldest].Saved) && key < oldest) {
				oldest = key
			}
		}
		delete(entries, oldest)
	}
	encoded, err := encodeTrafficStore(entries)
	if err != nil {
		return err
	}
	return writeTrafficStoreBytes(s.path, encoded)
}

func ipCacheKey(ip string) string {
	addr, err := netip.ParseAddr(ip)
	if err != nil || !addr.IsGlobalUnicast() || addr.IsPrivate() {
		return ""
	}
	return addr.Unmap().String()
}

func handleIPCacheGet(params ipCacheParams) json.RawMessage {
	if key := ipCacheKey(params.IP); key != "" {
		return ipCache.get(key, time.Now())
	}
	return nil
}

func handleIPCacheSet(params ipCacheParams) error {
	key := ipCacheKey(params.IP)
	// Persist only a small parsed result, never the remote HTML document.
	if key == "" || len(params.Data) > 64*1024 || !json.Valid(params.Data) || len(params.Data) == 0 || params.Data[0] != '{' {
		return &MethodError{Code: "invalid_arguments", Message: "invalid IP cache entry"}
	}
	return ipCache.put(key, params.Data, time.Now())
}

package core

import (
	"testing"
	"time"
)

func trafficRuntimeClock(t *testing.T, initial time.Time) *time.Time {
	t.Helper()
	now := initial
	previous := trafficNow
	trafficNow = func() time.Time { return now }
	t.Cleanup(func() { trafficNow = previous })
	return &now
}

func TestTrafficStatsRunningTimeCountsIdleAndExcludesStoppedTime(t *testing.T) {
	now := trafficRuntimeClock(t, time.Date(2026, 11, 17, 0, 0, 0, 0, time.UTC))
	c := newTestTrafficCollector(t, 0)
	query := TrafficStatsQuery{Start: "2026-11-17", End: "2026-11-17"}
	*now = now.Add(time.Hour)
	if got := c.query(query).RunningSeconds; got != 0 {
		t.Fatalf("stopped service counted %d seconds", got)
	}
	c.setRunning(true)
	if c.timer == nil {
		t.Fatal("idle running service must checkpoint time without traffic")
	}
	*now = now.Add(90 * time.Second)
	for range 2 {
		if got := c.query(query).RunningSeconds; got != 90 {
			t.Fatalf("idle time counted incorrectly or twice: %d", got)
		}
	}
	*now = now.Add(30 * time.Second)
	c.setRunning(false)
	*now = now.Add(time.Hour)
	if got := c.query(query).RunningSeconds; got != 120 {
		t.Fatalf("stopped interval must not count: %d", got)
	}
	c.setRunning(true)
	*now = now.Add(time.Minute)
	if got := c.query(query).RunningSeconds; got != 180 {
		t.Fatalf("restarted service did not accumulate: %d", got)
	}
}

func TestTrafficStatsRunningTimeSplitsLocalMidnightAndPersists(t *testing.T) {
	now := trafficRuntimeClock(t, time.Date(2026, 11, 17, 15, 59, 30, 0, time.UTC))
	c := newTestTrafficCollector(t, 480)
	c.setRunning(true)
	*now = now.Add(90 * time.Second)
	c.setRunning(false)
	c.flush()
	loaded := newTrafficCollector()
	loaded.init(c.dir)
	for _, tc := range []struct {
		start, end string
		seconds    int64
	}{
		{"2026-11-17", "2026-11-17", 30},
		{"2026-11-18", "2026-11-18", 60},
		{"2026-11-17", "2026-11-18", 90},
	} {
		if got := loaded.query(TrafficStatsQuery{Start: tc.start, End: tc.end}).RunningSeconds; got != tc.seconds {
			t.Fatalf("persisted range %s..%s: got %d want %d", tc.start, tc.end, got, tc.seconds)
		}
	}
}

func TestTrafficStatsRunningTimeDisableSuspendAndClear(t *testing.T) {
	now := trafficRuntimeClock(t, time.Date(2026, 11, 17, 0, 0, 0, 0, time.UTC))
	c := newTestTrafficCollector(t, 0)
	query := TrafficStatsQuery{Start: "2026-11-17", End: "2026-11-17"}
	c.setRunning(true)
	*now = now.Add(time.Minute)
	c.configure(defaultTrafficStatsOptions(), "")
	*now = now.Add(time.Hour)
	c.configure(enabledTrafficOptions(0), "")
	*now = now.Add(time.Minute)
	c.setSuspended(true)
	*now = now.Add(time.Hour)
	c.setSuspended(false)
	*now = now.Add(time.Minute)
	if got := c.query(query).RunningSeconds; got != 180 {
		t.Fatalf("disabled/suspended time counted: %d", got)
	}
	c.clear()
	if got := c.query(query).RunningSeconds; got != 0 {
		t.Fatalf("cleared running time resurrected: %d", got)
	}
	*now = now.Add(1500 * time.Millisecond)
	for range 4 {
		c.query(query)
		*now = now.Add(250 * time.Millisecond)
	}
	if got := c.query(query).RunningSeconds; got != 2 {
		t.Fatalf("fractional checkpoint time was lost: %d", got)
	}
}

package toolbox

import "time"

type TrafficStatsOptions struct {
	Enable        bool `json:"enable"`
	Detail        bool `json:"detail"`
	RetentionDays int  `json:"retention-days"`
	TzOffset      int  `json:"tz-offset"`
}

func DefaultTrafficStatsOptions() TrafficStatsOptions {
	_, offset := time.Now().Zone()
	return TrafficStatsOptions{
		Enable:        false,
		Detail:        true,
		RetentionDays: 7,
		TzOffset:      offset / 60,
	}
}

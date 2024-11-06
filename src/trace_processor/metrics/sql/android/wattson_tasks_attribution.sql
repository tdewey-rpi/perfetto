
-- Copyright 2024 The Android Open Source Project
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

INCLUDE PERFETTO MODULE wattson.curves.estimates;
INCLUDE PERFETTO MODULE wattson.curves.idle_attribution;
INCLUDE PERFETTO MODULE viz.summary.threads_w_processes;

-- Take only the Wattson estimations that are in the window of interest
DROP VIEW IF EXISTS _windowed_wattson;
CREATE PERFETTO VIEW _windowed_wattson AS
SELECT ii.*, ss.*
FROM _interval_intersect_single!(
  (SELECT ts FROM {{window_table}}),
  (SELECT dur FROM {{window_table}}),
  _ii_subquery!(_system_state_mw)
) ii
JOIN _system_state_mw AS ss ON ss._auto_id = id;

-- "Unpivot" the table so that table can by PARTITIONED BY cpu
DROP TABLE IF EXISTS _unioned_windowed_wattson;
CREATE PERFETTO TABLE _unioned_windowed_wattson AS
  SELECT ts, dur, 0 as cpu, cpu0_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 0 = cpu)
  UNION ALL
  SELECT ts, dur, 1 as cpu, cpu1_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 1 = cpu)
  UNION ALL
  SELECT ts, dur, 2 as cpu, cpu2_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 2 = cpu)
  UNION ALL
  SELECT ts, dur, 3 as cpu, cpu3_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 3 = cpu)
  UNION ALL
  SELECT ts, dur, 4 as cpu, cpu4_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 4 = cpu)
  UNION ALL
  SELECT ts, dur, 5 as cpu, cpu5_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 5 = cpu)
  UNION ALL
  SELECT ts, dur, 6 as cpu, cpu6_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 6 = cpu)
  UNION ALL
  SELECT ts, dur, 7 as cpu, cpu7_mw as estimated_mw
  FROM _windowed_wattson
  WHERE EXISTS (SELECT cpu FROM _dev_cpu_policy_map WHERE 7 = cpu)
  UNION ALL
  SELECT ts, dur, -1 as cpu, dsu_scu_mw as estimated_mw
  FROM _windowed_wattson;

DROP TABLE IF EXISTS _windowed_threads_system_state;
CREATE PERFETTO TABLE _windowed_threads_system_state AS
SELECT
  ii.ts,
  ii.dur,
  ii.cpu,
  uw.estimated_mw,
  s.thread_name,
  s.process_name,
  s.tid,
  s.pid,
  s.utid
FROM _interval_intersect!(
  (
    _ii_subquery!(_unioned_windowed_wattson),
    _ii_subquery!(_sched_w_thread_process_package_summary)
  ),
  (cpu)
) ii
JOIN _unioned_windowed_wattson AS uw ON uw._auto_id = id_0
JOIN _sched_w_thread_process_package_summary AS s ON s._auto_id = id_1;

-- Get idle overhead attribution per thread
DROP VIEW IF EXISTS _per_thread_idle_attribution;
CREATE PERFETTO VIEW _per_thread_idle_attribution AS
SELECT
  SUM(idle_cost_mws) as idle_cost_mws,
  utid
FROM _filter_idle_attribution(
   (SELECT ts FROM {{window_table}}),
   (SELECT dur FROM {{window_table}})
)
GROUP BY utid;

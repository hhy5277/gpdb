include: helpers/gp_management_utils_helpers.sql;

-- Given a segment running without a replication slot
0U: select * from pg_drop_replication_slot('some_replication_slot');
!\retcode rm -rf /tmp/some_isolation2_pg_basebackup;

-- When pg_basebackup runs with --slot and stream as xlog-method
select pg_basebackup(address, dbid, port, 'some_replication_slot', '/tmp/some_isolation2_pg_basebackup') from gp_segment_configuration where content = 0 and role = 'p';

-- Then a replication slot gets created on that segment with the slot
-- name and the slot's restart_lsn is not NULL, indicating that the
-- WAL streamer process utilized this slot for streaming WAL during
-- base backup
0U: select slot_name, slot_type, active, restart_lsn is not NULL as slot_was_used from pg_get_replication_slots() where slot_name = 'some_replication_slot';

-- When another basebackup is run with the same slot name
select pg_basebackup(address, dbid, port, 'some_replication_slot', '/tmp/some_other_isolation2_pg_basebackup') from gp_segment_configuration where content = 0 and role = 'p';

-- Then the backup should exist on the filesystem, ready for mirroring
!\retcode cat /tmp/some_other_isolation2_pg_basebackup/recovery.conf;

-- And the replication slot information should be unchanged
0U: select slot_name, slot_type, active, restart_lsn is not NULL as slot_was_used from pg_get_replication_slots() where slot_name = 'some_replication_slot';

-- Given we remove the replication slot
0U: select * from pg_drop_replication_slot('some_replication_slot');
!\retcode rm -rf /tmp/some_isolation2_pg_basebackup;
!\retcode rm -rf /tmp/some_other_isolation2_pg_basebackup;

-- When pg_basebackup runs without --slot
select pg_basebackup(address, dbid, port, null, '/tmp/some_isolation2_pg_basebackup') from gp_segment_configuration where content = 0 and role = 'p';

-- Then there should NOT be a replication slot
0U: select count(1) from pg_get_replication_slots() where slot_name = 'some_replication_slot';


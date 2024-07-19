-- Migration Down (Dropping tables and indexes)
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS media CASCADE;
DROP TABLE IF EXISTS memories CASCADE;
DROP TABLE IF EXISTS custom_events CASCADE;
DROP TABLE IF EXISTS milestones CASCADE;
DROP TABLE IF EXISTS users;

DROP INDEX IF EXISTS idx_comments_memory_id;
DROP INDEX IF EXISTS idx_comments_user_id;
DROP INDEX IF EXISTS idx_media_memory_id;
DROP INDEX IF EXISTS idx_memories_user_id;
DROP INDEX IF EXISTS idx_custom_events_user_id;

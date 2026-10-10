CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE IF NOT EXISTS permanent_metadata_log (
    id SERIAL PRIMARY KEY,
    domain_topic VARCHAR(255) NOT NULL,
    summary_cheat_sheet TEXT NOT NULL,
    context_signature vector(384)
);

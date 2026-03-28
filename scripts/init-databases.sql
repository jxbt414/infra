-- Auto-creates all 15 databases on first PostgreSQL startup
-- Each site gets its own isolated database

-- Science Pipeline
CREATE DATABASE mof_database;
CREATE DATABASE clinical_trials;
CREATE DATABASE reagent_prices;
CREATE DATABASE lab_equipment;
CREATE DATABASE research_protocols;
CREATE DATABASE grant_funding;
CREATE DATABASE core_facilities;
CREATE DATABASE plasma_donation;
CREATE DATABASE calibration_finder;
CREATE DATABASE reference_standards;
CREATE DATABASE cro_directory;

-- Consciousness Research
CREATE DATABASE upe_literature;
CREATE DATABASE consciousness_directory;

-- Gov / SaaS
CREATE DATABASE govcontractscout;
CREATE DATABASE govportals;

-- Auto-creates all 8 databases on first PostgreSQL startup
-- Each site gets its own isolated database

CREATE DATABASE mof_database;
CREATE DATABASE clinical_trials;
CREATE DATABASE upe_literature;
CREATE DATABASE tga_intel;
CREATE DATABASE cell_line_directory;
CREATE DATABASE lab_software;
CREATE DATABASE reference_standards;
CREATE DATABASE reagent_prices;

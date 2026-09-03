SHOW server_encoding;
SHOW client_encoding;
SELECT current_database();
SELECT datname, encoding, datcollate, datctype FROM pg_database WHERE datname = 'inventory_db';

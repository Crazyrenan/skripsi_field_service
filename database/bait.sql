INSERT INTO roles (id, role_name, access_level) VALUES (1, 'Technician', 2);

INSERT INTO users (id, role_id, full_name, email, password_hash) 
VALUES (1, 1, 'Budi Teknisi', 'budi@field.com', 'hashed_pass_123');

INSERT INTO clients (id, client_name) VALUES (1, 'PT Tambang Makmur');

INSERT INTO sites (id, client_id, site_name) VALUES (1, 1, 'Site Alpha - Hutan');

INSERT INTO product_catalogs (id, model_name) VALUES (1, 'Modul DSE4520');

INSERT INTO warehouses (id, warehouse_name, location_type) VALUES (1, 'Gudang Pusat', 'MAIN');

INSERT INTO suppliers (id, supplier_name) VALUES (1, 'Pabrik Genset Indo');

INSERT INTO asset_items (id, catalog_id, warehouse_id, supplier_id, serial_number) 
VALUES (1, 1, 1, 1, 'SN-DSE-999');

INSERT INTO failure_codes (id, code, description) VALUES (1, 'ERR-01', 'Modul Terbakar');

INSERT INTO work_orders (id, user_id, site_id, asset_id, failure_code_id, status, scheduled_date)
VALUES (101, 1, 1, 1, 1, 'IN_PROGRESS', CURRENT_DATE);
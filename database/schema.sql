CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    access_level INT NOT NULL 
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES roles(id),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE device_whitelist (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    device_id VARCHAR(100) NOT NULL UNIQUE, 
    device_model VARCHAR(100),
    is_approved BOOLEAN DEFAULT FALSE
);

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone_number VARCHAR(20)
);

CREATE TABLE sites (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    site_name VARCHAR(100) NOT NULL,
    address TEXT,
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8)
);

CREATE TABLE product_catalogs (
    id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    category VARCHAR(50), 
    specifications JSONB 
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    location_type VARCHAR(50) 
);

CREATE TABLE asset_items (
    id SERIAL PRIMARY KEY,
    catalog_id INT REFERENCES product_catalogs(id),
    warehouse_id INT REFERENCES warehouses(id),
    supplier_id INT REFERENCES suppliers(id),
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    purchase_date DATE,
    current_status VARCHAR(50) 
);

CREATE TABLE failure_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE action_types (
    id SERIAL PRIMARY KEY,
    action_name VARCHAR(50) UNIQUE NOT NULL, 
    requires_approval BOOLEAN DEFAULT FALSE
);

CREATE TABLE work_orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    site_id INT REFERENCES sites(id),
    asset_id INT REFERENCES asset_items(id),
    failure_code_id INT REFERENCES failure_codes(id),
    status VARCHAR(50) NOT NULL,
    scheduled_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    asset_id INT REFERENCES asset_items(id),
    from_warehouse_id INT REFERENCES warehouses(id),
    to_warehouse_id INT REFERENCES warehouses(id),
    user_id INT REFERENCES users(id),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chain_ledger (
    id SERIAL PRIMARY KEY,
    work_order_id INT REFERENCES work_orders(id),
    user_id INT REFERENCES users(id),
    transaction_data JSONB NOT NULL,
    previous_hash VARCHAR(64) NOT NULL,
    current_hash VARCHAR(64) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
UPDATE chain_ledger 
SET transaction_data = '{"action": "OUT", "item": "Generator Modul DSE4520", "qty": 50}' 
WHERE id = 1;


UPDATE users 
SET password_hash = '$2b$12$R.P96/9n39X77EclHn9Jduz.o.yI06fH1qZ8iB1K8R5b5aJ6n4z4W' 
WHERE id = 1;
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import models
import hashlib
import json
import schemas
from middleware import setup_middleware
from fastapi.security import OAuth2PasswordRequestForm
import security
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Field Service API", version="1.0.0")

setup_middleware(app)

@app.get("/")
def read_root():
    return {"message": "Hello dari API Field Service Skripsi!"}

# --- ENDPOINT BARU UNTUK CEK DATABASE ---
@app.get("/test-db")
def test_database_connection(db: Session = Depends(get_db)):
    try:
        # Coba hitung ada berapa user di database
        user_count = db.query(models.User).count()
        return {
            "status": "success", 
            "message": "Koneksi ke PostgreSQL Berhasil!",
            "total_users": user_count
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/ledger/add")
def add_to_ledger(ledger: schemas.LedgerCreate, db: Session = Depends(get_db)):
    try:
        # 1. Cari data terakhir di tabel untuk mendapatkan 'previous_hash'
        last_entry = db.query(models.ChainLedger).order_by(models.ChainLedger.id.desc()).first()
        
        # Jika database masih kosong (Genesis Block), gunakan hash 0000...
        if not last_entry:
            previous_hash = "0" * 64 
        else:
            previous_hash = last_entry.current_hash

        # 2. Siapkan data yang mau di-hash (Data + Previous Hash)
        data_string = json.dumps(ledger.transaction_data, sort_keys=True) + previous_hash
        
        # 3. Hitung Hash Baru menggunakan SHA-256
        new_hash = hashlib.sha256(data_string.encode('utf-8')).hexdigest()

        # 4. Simpan ke Database
        new_ledger_entry = models.ChainLedger(
            work_order_id=ledger.work_order_id,
            user_id=ledger.user_id,
            transaction_data=ledger.transaction_data,
            previous_hash=previous_hash,
            current_hash=new_hash
        )
        
        db.add(new_ledger_entry)
        db.commit()
        db.refresh(new_ledger_entry)

        return {
            "status": "success",
            "message": "Data aman tercatat di Blockchain!",
            "hash": new_hash
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/ledger/verify")
def verify_ledger(db: Session = Depends(get_db)):
    # Ambil semua data urut dari yang paling lama
    ledgers = db.query(models.ChainLedger).order_by(models.ChainLedger.id.asc()).all()

    if not ledgers:
        return {"status": "success", "message": "Ledger kosong."}

    corrupted_blocks = []
    is_valid = True

    # Periksa satu per satu baris
    for i in range(len(ledgers)):
        current_block = ledgers[i]

        # 1. Tentukan apa 'previous_hash' yang seharusnya
        if i == 0:
            expected_prev_hash = "0" * 64 # Untuk baris pertama
        else:
            expected_prev_hash = ledgers[i-1].current_hash # Untuk baris ke-2 dst

        # Cek apakah rantai putus
        if current_block.previous_hash != expected_prev_hash:
            is_valid = False
            corrupted_blocks.append(f"Rantai putus di Transaksi ID {current_block.id}. Previous Hash tidak cocok!")
            continue 

        # 2. Hitung ulang Hash dari data yang ada di database sekarang
        data_string = json.dumps(current_block.transaction_data, sort_keys=True) + current_block.previous_hash
        recalculated_hash = hashlib.sha256(data_string.encode('utf-8')).hexdigest()

        # Cek apakah isinya diedit diam-diam
        if current_block.current_hash != recalculated_hash:
            is_valid = False
            corrupted_blocks.append(f"Manipulasi data terdeteksi di Transaksi ID {current_block.id}. Ada yang mengubah jumlah stok/barang!")

    # Hasil Akhir
    if is_valid:
        return {"status": "success", "message": "✅ Audit Log 100% AMAN. Tidak ada manipulasi data."}
    else:
        return {"status": "danger", "message": "❌ BAHAYA: Data telah dimanipulasi orang dalam!", "errors": corrupted_blocks}
    
    
# DI FILE: backend/main.py

# Di backend/main.py

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # 1. Baris ini yang HILANG sebelumnya (Mendefinisikan variabel 'user')
    user = db.query(models.User).filter(models.User.email == form_data.username).first()
    
    # 2. Cek password
    # Sekarang 'user' sudah dikenali, jadi baris ini tidak akan error lagi
    if not user or not security.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Email atau Password salah!")

    access_token = security.create_access_token(data={"sub": user.email, "user_id": user.id})
    
    # 4. Return data lengkap (Token + Info User)
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "role_id": user.role_id
        },
        "message": f"Selamat datang, {user.full_name}!"
    }
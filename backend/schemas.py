from pydantic import BaseModel
from typing import Dict, Any

# Ini adalah bentuk data JSON yang akan kita kirim dari Postman/Flutter
class LedgerCreate(BaseModel):
    user_id: int
    work_order_id: int
    transaction_data: Dict[str, Any] 


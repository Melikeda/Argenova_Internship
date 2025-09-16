# 🖥️ Qdrant Loader

Bu dosya (`qdrant_loader.py`), **Excel’deki mesai verilerini Qdrant’a yükler** ve chatbot’un doğru yanıt vermesini sağlar.

---

## 📝 Özellikler
- Excel dosyasını okur: `mesai_saatleri.xlsx`   
- Her satır için: 👤 Personel, 📅 Tarihler, ⏰ Saatler, 🕒 Toplam çalışma süresi  
- Verileri cümleye çevirir ve **vektörleştirir**   
- Qdrant’a kaydeder   

---

## 🛠️ Kütüphaneler
- `pandas`, `datetime`, `sentence_transformers`, `qdrant_client`, `uuid`  

---

## 🗂️ Qdrant Koleksiyonu
- Adı: `mesai_chatbot` 
- Vektör boyutu: 384  
- Mesafe: Cosine Distance   
- Mevcut koleksiyon varsa silinir ve yeniden oluşturulur   

---

## ▶️ Çalıştırma
1. Qdrant çalışıyor olmalı: `localhost:6333`   
2. Excel dosyası aynı klasörde   
3. Komut:

```bash
python qdrant_loader.py
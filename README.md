# 📌 AI Mesai Asistanı – Backend

Bu proje, **FastAPI** tabanlı bir yapay zekâ destekli backend uygulamasıdır.  
Amaç, Excel/CSV’de tutulan **personel mesai verilerini** kullanarak doğal dilde sorulan sorulara yanıt vermektir.

Uygulama, **RAG (Retrieval-Augmented Generation)** mimarisi ile çalışır:

1. Kullanıcının sorusu embedding’e dönüştürülür,  
2. Qdrant vektör veritabanı üzerinden en alakalı veriler bulunur,  
3. Bu veriler LLaMA 3 modeline bağlam olarak gönderilir,  
4. Modelden alınan yanıt kullanıcıya döndürülür.  

---

## 🚀 Özellikler
- FastAPI tabanlı REST API  
- Türkçe dil desteği  
- SentenceTransformer (all-MiniLM-L6-v2) ile embedding çıkarma  
- Qdrant entegrasyonu ile vektör arama  
- Ollama aracılığıyla LLaMA 3 modeliyle yanıt üretme  
- Doğru ve veri temelli hesaplamalar yapma  

---

## 📂 Dosya Açıklaması

### 🔹 `main.py`
Projenin ana backend dosyasıdır.  

- `SoruModel`: API’ye gelen kullanıcı sorusunu temsil eden Pydantic modeli  
- `build_rag_prompt()`: Kullanıcı sorusu + Qdrant’tan gelen bağlam ile LLaMA 3 için özel bir prompt oluşturur  
- `/sor` endpoint’i:  
  - Kullanıcıdan gelen soruyu işler  
  - Qdrant üzerinden bağlam arar  
  - LLaMA 3 modelinden yanıt üretir  

---

## ⚙️ Kurulum & Çalıştırma
```bash
# Gerekli bağımlılıkların yüklenmesi
pip install -r requirements.txt

# API’nin başlatılması
uvicorn main:app --reload
# 🤖 AI Mesai Chatbot – Genel Proje README

**AI Mesai Chatbot**, kullanıcıların Excel veya CSV formatında tutulan **mesai verilerini analiz etmelerine yardımcı olan** yapay zekâ destekli bir sohbet uygulamasıdır.  
Uygulama, hem **Flutter frontend** hem de **FastAPI backend** ile çalışır.

---

## 📝 Proje Özeti
- Kullanıcılar, Excel veya CSV dosyalarını uygulamaya yükleyerek veri analizleri yapabilir 📊  
- Sorular **doğal dilde** sorulabilir ve chatbot, geçmiş mesai verilerini analiz ederek yanıt verir 💬  
- **RAG (Retrieval-Augmented Generation)** mimarisi sayesinde geçmiş veriler ve sohbetler dikkate alınarak daha doğru yanıtlar sağlanır 🔗  
- Sohbet geçmişi cihaz üzerinde saklanır ve kullanıcı, uygulamayı kapatsa bile geçmişe erişebilir 💾  

---

## 🚀 Özellikler
- 🧠 **Doğal Dil Analizi**: Kullanıcı sorularını anlayarak doğru cevaplar üretir  
- 📊 **Mesai Verisi Analizi**: Excel/CSV verilerini okuyup saat ve tarih analizleri yapabilir  
- 💬 **Sohbet Geçmişi**: Tüm mesajlar `SharedPreferences` ile saklanır  
- ✨ **Yeni Sohbet ve Temizleme**: Kullanıcı yeni sohbet başlatabilir veya mevcut sohbeti temizleyebilir  
- 🌐 **Backend İletişimi**: FastAPI üzerinden sorgular işlenir ve JSON formatında cevap döner  
- 🔍 **Vektör Tabanlı Arama (RAG)**: Qdrant ve embedding modelleri ile geçmiş verilerden ilgili yanıtlar çıkarılır  

---

## ⚙️ Kurulum

### Backend Kurulumu
1. Python 3.10+ önerilir 🐍  
2. Gerekli kütüphaneler: FastAPI, uvicorn, pandas, sentence-transformers, qdrant-client  
3. API server başlatma:

```bash
uvicorn main:app --reload

# AI Mesai Chatbot – Genel Proje README

**AI Mesai Chatbot**, kullanıcıların Excel veya CSV formatında tutulan mesai verilerini analiz etmelerine yardımcı olan bir yapay zekâ destekli sohbet uygulamasıdır. Uygulama, hem lokal hem de web tabanlı çözümlerle çalışan bir Flutter frontend ve FastAPI backend mimarisine sahiptir.

---

## Proje Özeti

* Kullanıcılar, Excel veya CSV dosyalarını uygulamaya yükleyerek veri analizleri yapabilir.
* Sorular doğal dilde sorulabilir ve chatbot, geçmiş mesai verilerini analiz ederek yanıt verir.
* RAG (Retrieval-Augmented Generation) mimarisi sayesinde geçmiş veriler ve sohbetler dikkate alınarak daha doğru yanıtlar sağlanır.
* Sohbet geçmişi cihaz üzerinde saklanır ve kullanıcı, uygulamayı kapatsa bile geçmişe erişebilir.

---

## Özellikler

* **Doğal Dil Analizi**: Kullanıcı sorularını anlayarak doğru cevaplar üretir.
* **Mesai Verisi Analizi**: Excel/CSV verilerini okuyup saat ve tarih analizleri yapabilir.
* **Sohbet Geçmişi**: Tüm mesajlar `SharedPreferences` ile saklanır.
* **Yeni Sohbet ve Temizleme**: Kullanıcı yeni sohbet başlatabilir veya mevcut sohbeti temizleyebilir.
* **Backend İletişimi**: FastAPI üzerinden sorgular işlenir ve JSON formatında cevap döner.
* **Vektör Tabanlı Arama (RAG)**: Qdrant ve embedding modelleri ile geçmiş verilerden ilgili yanıtlar çıkarılır.

---

## Kurulum

1. **Backend Kurulumu**:

   * Python 3.10+ önerilir.
   * Gerekli kütüphaneler: FastAPI, uvicorn, pandas, sentence-transformers, qdrant-client
   * API server başlatma:

     ```bash
     uvicorn main:app --reload
     ```

2. **Flutter Frontend Kurulumu**:

   * Flutter ortamını kurun: [Flutter Kurulum Rehberi](https://flutter.dev/docs/get-started/install)
   * Projeyi klonlayın:

     ```bash
     git clone <repository-url>
     cd AI_MesaiChatbot
     flutter pub get
     flutter run
     ```

---

## Kullanım

1. Uygulamayı açın.
2. Excel veya CSV dosyanızı yükleyin.
3. Mesaj kutusuna sorularınızı yazın (örneğin: "Ali Bey’in toplam mesai saati nedir?").
4. Chatbot, verileri analiz edip yanıt verecektir.
5. Sohbetleri silebilir veya yeni sohbet başlatabilirsiniz.

---

## Dosya Yapısı

* **main.dart**: Flutter uygulamasının giriş noktası ve tüm UI mantığı.
* **ChatPage / ChatListPage**: Kullanıcı arayüzü ve mesaj yönetimi.
* **ChatSession, ChatMessage**: Sohbet ve mesaj model sınıfları.
* **SharedPreferences**: Sohbet geçmişinin saklanması.
* **http**: Backend ile iletişim.
* **Backend (FastAPI)**: Mesai verilerini analiz eder ve yanıt üretir.
* **RAG ve Qdrant**: Vektör tabanlı sorgular için kullanılır.

---

## Özelleştirme

* Tema rengi ve fontlar Flutter tarafında değiştirilebilir.
* Backend URL ve port `main.dart` içinde ayarlanabilir.
* Mesaj baloncukları ve avatar ikonları UI üzerinden özelleştirilebilir.

---

## Gereksinimler

* Flutter 3.0 veya üzeri
* Dart 3.0 veya üzeri
* Python 3.10+ (Backend için)
* İnternet bağlantısı (Backend ile iletişim için)

---
* RAG ve embedding modelleri, gelecekte veri tabanına daha büyük veri setleri eklenerek geliştirilebilir.
* Kullanıcı deneyimini artırmak için frontend UI sürekli güncellenebilir.

# 🎙️ Omni Voice AI — Ovoz Bilan Telefonni Boshqaruvchi Sun'iy Intellekt

Groq (Llama 3.3 70B) va Google Gemini bilan quvvatlangan, telefonning butun qismini (YouTube, Qo'ng'iroqlar, Ilovalar, Tizim amallari) ovoz orqali boshqaruvchi Liquid Glass dizayndagi mobil ilova.

---

## ✨ Imkoniyatlar

1. **⚡ Ultra-Tez AI (Groq Llama 3.3 70B & Google Gemini 2.0 Flash)**:
   - Buyruqlarni bir necha millisekundda tahlil qilish va ovoz bilan javob berish.
2. **▶️ YouTube Smart Bot**:
   - Istalgan videoni qidirish va aytilgan aniq daqiqa/sekunddan ochish (Masalan: *"YouTube ga kirib lofi musiqani 5-minutiga qo'y"*).
3. **📞 Ovozli Qo'ng'iroqlar**:
   - Kiruvchi qo'ng'iroq bo'lganda *"Answer the call"*, *"Qo'ng'iroqqa javob ber"* yoki *"Go'shakni ko'tar"* ovozli buyruqlari orqali avtomatik javob berish.
4. **📱 Telefonning Butun Tizimini Boshqarish (Accessibility Service)**:
   - Ilovalarni ochish (Telegram, Kamera, Chrome, Sozlamalar va h.k.).
   - Home, Back, Recents, Bildirishnomalar panelini ochish, ekrandagi tugmalarni bosish.
   - Ovoz balandligini sozlash.
5. **💎 Liquid Glass & Dynamic Island Dizayni**:
   - Yuqori o'ngda **Light / Dark mode**.
   - Yuqori chapda 3 ta chiziqli menyu -> **Shadcn Sidebar Nav**.
   - Yuqorida **iOS Dynamic Island** (jonli holat xabarnomalari).
   - **2 xil AI Rejimi**:
     * **1-Rejim**: Gemini Assistant Liquid Frame & To'lqinlar.
     * **2-Rejim**: 3D Siri Glowing Neon Shisha Orb (pulsatsiya, zarrachalar va neon nurlar).

---

## 🚀 GitHub Actions orqali APK Yig'ish (Hech narsa o'rnatmasdan)

Loyiha ichida `.github/workflows/build_apk.yml` sozlangan. GitHub orqali tayyor APK olish uchun:

1. **GitHub da yangi repozitoriy oching** (masalan: `omni-voice-ai`).
2. Terminalda quyidagi buyruqlarni yuboring:
```bash
cd omni_voice_ai
git init
git add .
git commit -m "Initial commit for Omni Voice AI"
git branch -M main
git remote add origin https://github.com/SIZNING_GITHUB_USERNAME/omni-voice-ai.git
git push -u origin main
```
3. GitHub repozitoriyingizdagi **"Actions"** bo'limiga kiring.
4. Workflow avtomatik ishga tushib, 2-3 daqiqada tayyor **`OmniVoiceAI-Release-APK`** faylini yuklab olishingiz uchun chiqarib beradi!

---

## 🔑 Sozlangan API Kalitlari
- **Groq API**: `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` (Llama 3.3 70B Versatile)
- **Gemini API**: `AQ.Ab8RN6K_jPu9KOT6I5pQ_PTgCJNNmkETasp-5GpFrJSUBI0tQw` (Gemini 2.0 Flash)

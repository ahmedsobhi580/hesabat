# طريقة التشغيل: ويندوز + آيفون (من غير Mac نهائي)

الفكرة: GitHub بيبني البرنامج على ماك سحابي مجاني، وSideloadly بيثبّته
على الآيفون من الويندوز باستخدام Apple ID المجاني.

## الخطوة 1: Build في السحابة (مرة واحدة)
1. اعمل حساب GitHub مجاني: https://github.com
2. اعمل New Repository اسمه hesabat (خليها Public عشان الـ Actions المجانية)
3. ارفع محتوى المجلد ده على المستودع (زرار Add file ← Upload files، أو عن طريق موقع github.dev)
4. روح تبويب Actions ← اختار "Build IPA" ← Run workflow
5. بعد 10-15 دقيقة هتلاقي ملف Hesabat.ipa في قسم Artifacts ← حمّله

## الخطوة 2: التثبيت من الويندوز
1. نزّل Sideloadly من https://sideloadly.io
2. أوصّل الآيفون باللاب بالكابل
3. في Sideloadly: اختار الجهاز ← اسحب ملف Hesabat.ipa ← سجّل دخول Apple ID
   (لو الحساب عليه تحقق بخطوتين: اعمل App-Specific Password من appleid.apple.com)
4. اضغط Start — هيتثبت على الآيفون

## الخطوة 3: على الآيفون (أول مرة بس)
1. Settings ← Privacy & Security ← Developer Mode ← ON ← أعد تشغيل الجهاز
2. Settings ← General ← VPN & Device Management ← Trust على إيميلك

## ملاحظات مهمة
- Apple ID المجاني = التطبيق شغال 7 أيام، وبعدها تثبّته تاني من Sideloadly
  (دقيقتين). الحد الأقصى 3 تطبيقات من غير حساب مطوّر.
- عايز دائم؟ حساب مطوّر Apple Developer 99$ في السنة.
- كل مرة تعدّل فيها الكود: ارفع التعديل على GitHub وهيتبنى IPA جديدة تلقائيًا.

## لو البناء وقف في GitHub Actions
انسخ نص الخطأ من صفحة الـ run وأبعته — غالبًا هيكون تعديل بسيط في project.yml.

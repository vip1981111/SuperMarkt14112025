# دليل إصلاح الأخطاء 🔧

## المشاكل المحتملة وحلولها

### المشكلة 1: أسماء الملفات غير صحيحة ❌

الملفات تم إنشاؤها بأسماء مثل:
- `ViewsListsView.swift`
- `ModelsShoppingItem.swift`
- `ViewModelsShoppingListViewModel.swift`

**الحل:**
في Xcode، قم بإعادة تسمية الملفات يدوياً:

1. انقر بزر الماوس الأيمن على الملف
2. اختر "Rename"
3. أعد تسميته بشكل صحيح:
   - `ViewsListsView.swift` → `ListsView.swift`
   - `ModelsShoppingItem.swift` → `ShoppingItem.swift`
   - وهكذا...

أو يمكنك تركها كما هي - Swift لا يهتم باسم الملف، فقط باسم الـ struct/class بداخله.

---

### المشكلة 2: البنية الهيكلية للمجلدات 📁

**الحل المقترح:**

في Xcode، قم بإنشاء Groups (مجلدات افتراضية):

```
SuperMarkt14112025/
├── Models/
│   ├── ShoppingItem.swift
│   └── ShoppingList.swift
├── ViewModels/
│   ├── ShoppingListViewModel.swift
│   └── CameraViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── ListsView.swift
│   ├── ShoppingListDetailView.swift
│   ├── AddItemView.swift
│   ├── CameraView.swift
│   ├── PriceHistoryView.swift
│   ├── StatisticsView.swift
│   ├── AllStatisticsView.swift
│   ├── SettingsView.swift
│   └── OnboardingView.swift
├── Utilities/
│   ├── Extensions.swift
│   └── Helpers.swift
└── Resources/
    └── Info.plist
```

**خطوات الإنشاء:**
1. انقر بزر الماوس الأيمن على المشروع
2. اختر "New Group"
3. سمّه "Models" (أو أي اسم آخر)
4. اسحب الملفات المناسبة للمجلد

---

### المشكلة 3: أخطاء الاستيراد (Import Errors) 🚫

إذا ظهرت أخطاء مثل:
```
Cannot find 'ShoppingItem' in scope
Cannot find 'ShoppingListViewModel' in scope
```

**الحل:**
1. تأكد من أن جميع الملفات مضافة للـ Target
2. في Xcode:
   - اختر الملف
   - اذهب إلى File Inspector (⌘⌥1)
   - تأكد من تفعيل Target Membership

---

### المشكلة 4: أخطاء في Info.plist 📄

**الحل:**
تأكد من وجود هذا السطر في Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج للوصول إلى الكاميرا لمسح الأسعار وإضافتها تلقائياً</string>
```

---

### المشكلة 5: الملفات المفقودة أو غير المكتملة ⚠️

إذا كان هناك ملف مفقود (مثل PriceHistoryView)، استخدم الكود التالي:

#### نسخة مبسطة من PriceHistoryView:

```swift
import SwiftUI

struct PriceHistoryView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("المجموع الكلي")
                        Spacer()
                        Text("\(cameraViewModel.totalScanned, specifier: "%.2f") ريال")
                            .font(.headline)
                    }
                }
                
                Section("الأسعار") {
                    ForEach(Array(cameraViewModel.scannedPrices.enumerated()), id: \.offset) { index, price in
                        HStack {
                            Text("\(index + 1).")
                            Text("\(price, specifier: "%.2f") ريال")
                            Spacer()
                            Button(role: .destructive) {
                                cameraViewModel.removePrice(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("قائمة الأسعار")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") { dismiss() }
                }
            }
        }
    }
}
```

---

### المشكلة 6: أخطاء في الكاميرا 📸

إذا لم تعمل الكاميرا:

**الحل:**
1. استخدم جهاز حقيقي (ليس محاكي)
2. تأكد من الأذونات في الإعدادات
3. أعد تشغيل التطبيق

---

### المشكلة 7: أخطاء في Swift Charts 📊

إذا ظهرت أخطاء في StatisticsView:

**الحل:**
تأكد من أن iOS Deployment Target هو 16.0 أو أحدث:
1. اختر المشروع في Xcode
2. اذهب إلى General
3. تحت Deployment Info
4. اضبط iOS على 16.0 أو أحدث

---

## خطوات إصلاح المشروع الكاملة 🔧

### الطريقة السريعة (Recommended):

1. **احذف جميع الملفات المُنشأة** (ماعدا ContentView.swift)

2. **أعد إنشاء الملفات في Xcode بالترتيب:**

   أ. Models:
   - File → New → File → Swift File → "ShoppingItem"
   - انسخ المحتوى من `ModelsShoppingItem.swift`
   - كرر للـ ShoppingList

   ب. ViewModels:
   - أنشئ ShoppingListViewModel
   - أنشئ CameraViewModel

   ج. Views:
   - أنشئ كل View على حدة

3. **تأكد من Target Membership لكل ملف**

4. **أضف Info.plist entries**

5. **Build المشروع** (⌘B)

---

### الطريقة البديلة (كل شيء في ملف واحد):

إذا استمرت المشاكل، يمكنك وضع كل شيء في ملف واحد كبير:

```swift
// AllInOne.swift

import SwiftUI
import AVFoundation
import Vision
import Charts

// Models
struct ShoppingItem: Identifiable, Codable {
    // ... الكود هنا
}

struct ShoppingList: Identifiable, Codable {
    // ... الكود هنا
}

// ViewModels
@MainActor
class ShoppingListViewModel: ObservableObject {
    // ... الكود هنا
}

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    // ... الكود هنا
}

// Views
struct ListsView: View {
    // ... الكود هنا
}

// ... باقي الـ Views
```

---

## الأخطاء الشائعة وحلولها 💡

### خطأ: "Cannot find type 'ShoppingItem' in scope"
**الحل:** تأكد من أن الملف مضاف للـ Target

### خطأ: "Module 'Charts' not found"
**الحل:** تأكد من iOS 16.0+ في Deployment Target

### خطأ: "Camera permission denied"
**الحل:** أضف NSCameraUsageDescription في Info.plist

### خطأ: Build Failed
**الحل:** 
1. Product → Clean Build Folder (⇧⌘K)
2. Restart Xcode
3. Delete Derived Data

---

## اختبار المشروع ✅

بعد الإصلاح، جرب:

1. ✅ فتح التطبيق
2. ✅ إنشاء قائمة جديدة
3. ✅ إضافة منتج
4. ✅ فتح الكاميرا (تسوق بالمبلغ)
5. ✅ مسح رقم
6. ✅ عرض الإحصائيات

---

## الدعم 💬

إذا استمرت المشاكل:

1. تأكد من Xcode 15.0+
2. تأكد من iOS 17.0+
3. نظف المشروع (⇧⌘K)
4. أعد بناء المشروع (⌘B)
5. أعد تشغيل Xcode

---

**ملاحظة:** المشكلة الأساسية هي أن الملفات تم إنشاؤها بأسماء غير تقليدية (ViewsListsView بدلاً من ListsView). هذا لا يؤثر على عمل Swift لكن يجعل المشروع غير منظم.

**الحل الأفضل:** أعد تسمية الملفات في Xcode لتكون منظمة بشكل صحيح.

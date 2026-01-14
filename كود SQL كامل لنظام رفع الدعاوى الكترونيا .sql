/* ===============================
   1) الجدول الرئيسي: ملف القضية
   =============================== */

CREATE TABLE case_files (
    case_id INT AUTO_INCREMENT PRIMARY KEY,

    case_type ENUM(
        'امر_اداء',
        'دعوى',
        'رد_على_دعوى',
        'طعن',
        'استئناف'
    ) NOT NULL,

    case_number VARCHAR(50) UNIQUE,
    case_status ENUM(
        'جديد',
        'قيد_النظر',
        'مكتمل',
        'مغلق'
    ) DEFAULT 'جديد',

    governorate VARCHAR(50),
    court VARCHAR(100),

    submit_date_gregorian DATE,
    submit_date_hijri VARCHAR(20),

    subject VARCHAR(150),
    facts TEXT,
    legal_reasons TEXT,
    requests TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL,
    notes TEXT
);


/* ===============================
   2) جدول الأطراف (موحد)
   =============================== */

CREATE TABLE case_parties (
    party_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,

    role ENUM(
        'مدعي',
        'مدعى_عليه',
        'طالب_امر',
        'مطلوب_امر_ضده',
        'مستأنف',
        'مستأنف_ضده'
    ) NOT NULL,

    full_name VARCHAR(100) NOT NULL,
    nationality ENUM(
        'يمني','سعودي','مصري','عماني','اماراتي','عراقي',
        'سوداني','فلسطيني','سوري','اردني','كويتي','اخرى'
    ),

    gender ENUM('ذكر','انثى','شخصية اعتبارية'),
    job VARCHAR(70),
    phone VARCHAR(20),
    address VARCHAR(150),
    lawyer_name VARCHAR(100),

    FOREIGN KEY (case_id)
        REFERENCES case_files(case_id)
        ON DELETE CASCADE
);


/* ==========================================
   3) جدول النصوص القانونية الثابتة (إجباري)
   ========================================== */

CREATE TABLE legal_templates (
    template_id INT AUTO_INCREMENT PRIMARY KEY,

    case_type ENUM(
        'امر_اداء',
        'دعوى',
        'رد_على_دعوى',
        'طعن',
        'استئناف'
    ) NOT NULL,

    section_key VARCHAR(50) NOT NULL,
    section_title VARCHAR(100) NOT NULL,

    default_text TEXT NOT NULL,
    is_required BOOLEAN DEFAULT TRUE
);


/* ===============================
   إدخال النصوص الافتراضية (مرة واحدة)
   =============================== */

INSERT INTO legal_templates
(case_type, section_key, section_title, default_text)
VALUES

-- أمر أداء
('امر_اداء','facts','الوقائع',
'أولاً: الوقائع
حيث إن في ذمة المطلوب الأمر ضده مبلغاً ثابتاً بالكتابة، وحال الأداء، ولم يقم بالسداد حتى تاريخه.'),

('امر_اداء','requests','الطلبات',
'ثانياً: الطلبات
نلتمس من عدالتكم إصدار أمر أداء بإلزام المطلوب الأمر ضده بسداد المبلغ محل الطلب مع الرسوم.'),

-- دعوى
('دعوى','facts','وقائع الدعوى',
'وقائع الدعوى:
تتلخص وقائع هذه الدعوى في أن المدعي قد تضرر من المدعى عليه على النحو المبين.'),

('دعوى','legal','الأسباب والأسناد القانونية',
'الأسباب والأسناد القانونية:
استناداً إلى القوانين النافذة وأحكام الشريعة الإسلامية.'),

('دعوى','requests','طلبات الدعوى',
'طلبات الدعوى:
نلتمس الحكم وفقاً لما ورد أعلاه.'),

-- رد على دعوى
('رد_على_دعوى','reply','الرد على الدعوى',
'رداً على ما ورد بصحيفة الدعوى، فإن المدعى عليه يتمسك بالدفوع الآتية.'),

-- استئناف
('استئناف','formal','من الناحية الشكلية',
'أولاً: من الناحية الشكلية
وحيث إن الاستئناف قُدم في الميعاد القانوني المستوجب قبوله شكلاً.'),

('استئناف','substantive','من الناحية الموضوعية',
'ثانياً: من الناحية الموضوعية
وحيث إن الحكم المستأنف قد جانبه الصواب في التطبيق.'),

-- طعن
('طعن','grounds','أسباب الطعن',
'أسباب الطعن:
بُني الطعن على مخالفة القانون والخطأ في تطبيقه.');


/* ===============================
   4) جدول المطالبات المالية
   =============================== */

CREATE TABLE financial_claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,

    amount DECIMAL(18,2),
    currency ENUM('YER','USD','SAR','EGP'),
    due_date DATE,
    description TEXT,

    FOREIGN KEY (case_id)
        REFERENCES case_files(case_id)
        ON DELETE CASCADE
);


/* ===============================
   5) جدول المرفقات
   =============================== */

CREATE TABLE case_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,

    document_type VARCHAR(50),
    document_date_gregorian DATE,
    document_date_hijri VARCHAR(20),
    content_summary TEXT,
    pages_count INT,
    file_path VARCHAR(255),

    FOREIGN KEY (case_id)
        REFERENCES case_files(case_id)
        ON DELETE CASCADE
);


/* ===============================
   6) جدول الإجراءات
   =============================== */

CREATE TABLE case_actions (
    action_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,

    action ENUM(
        'تعديل',
        'حذف',
        'طباعة',
        'مشاركة',
        'رد',
        'تحليل'
    ) NOT NULL,

    action_note TEXT,
    action_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (case_id)
        REFERENCES case_files(case_id)
        ON DELETE CASCADE
);

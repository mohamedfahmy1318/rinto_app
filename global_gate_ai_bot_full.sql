
-- Global Gate AI Bot Database
-- Built strictly from information contained in the provided files

CREATE DATABASE IF NOT EXISTS global_gate_ai_bot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE global_gate_ai_bot;

-- Customers table
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    phone VARCHAR(50),
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME
);

-- Conversations table
CREATE TABLE conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    message TEXT,
    message_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Bot replies table
CREATE TABLE bot_replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT,
    reply_text TEXT,
    source VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

-- Support escalation table
CREATE TABLE support_escalations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT,
    question TEXT,
    sent_to_support TINYINT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

-- Knowledge base
CREATE TABLE knowledge_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    category VARCHAR(100),
    content TEXT,
    source_file VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO knowledge_items (title, category, content, source_file) VALUES
('Required Documents','documents',
'Passport copy (valid), high school transcript in English, sealed university transcript, sealed nursing course description with theoretical and clinical hours, nursing union documents including good conduct certificate, membership, and signed English form.',
'Instruction In Arabic 1.pdf'),

('Program Service Fee','fees',
'The service fee for the NCLEX process is 650 Jordanian Dinars, which can be paid in installments according to the participant financial situation.',
'Instruction In Arabic 1.pdf'),

('NCLEX Exam Description','exam',
'NCLEX-RN is the required exam to work as a registered nurse in the United States and Canada. The exam contains 85–150 questions with a maximum duration of 5 hours using a computerized adaptive testing system.',
'Global Gate Healthcare new F.pptx'),

('Exam Locations','exam',
'NCLEX exam centers mentioned include USA (free), Turkey (177 USD), South Africa (150 USD), and India (177 USD).',
'Instruction In Arabic 1.pdf'),

('After Visa Support','benefits',
'After visa issuance the company supports the nurse by contracting with a hospital, providing a plane ticket, accommodation for 90 days, 1000 USD personal allowance, and training in a laboratory to understand the US healthcare system.',
'Instruction In Arabic 1.pdf'),

('Nurse Salary in USA','salary',
'Typical hourly salary for nurses mentioned ranges approximately from 42 to 50 USD per hour depending on the state minimum wage.',
'Instruction In Arabic 1.pdf');

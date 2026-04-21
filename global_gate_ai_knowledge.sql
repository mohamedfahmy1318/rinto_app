CREATE DATABASE IF NOT EXISTS global_gate_ai_bot CHARACTER SET utf8mb4;
USE global_gate_ai_bot;
CREATE TABLE IF NOT EXISTS faq (
id INT AUTO_INCREMENT PRIMARY KEY,
question TEXT,
answer TEXT,
source VARCHAR(100)
);
INSERT INTO faq (question,answer,source) VALUES ('ما هو برنامج Global Gate Healthcare؟','برنامج يهدف إلى مساعدة الممرضين الفلسطينيين على التحضير لامتحان NCLEX والعمل في النظام الصحي في الولايات المتحدة.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما الهدف من البرنامج؟','إنشاء مسار مهني للممرضين الفلسطينيين للعمل في الولايات المتحدة والمساعدة في معالجة نقص الممرضين هناك.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما هو امتحان NCLEX؟','اختبار مطلوب للعمل كممرض مسجل في الولايات المتحدة وكندا.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم عدد أسئلة امتحان NCLEX؟','يتراوح عدد الأسئلة بين 85 و150 سؤالاً.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم مدة امتحان NCLEX؟','المدة القصوى للامتحان تصل إلى 5 ساعات.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما نظام امتحان NCLEX؟','يعتمد على نظام الاختبار التكيفي المحوسب حيث تتغير صعوبة الأسئلة حسب إجابات المتقدم.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم مرة يمكن إعادة امتحان NCLEX؟','يمكن إعادة الامتحان بعد 45 يوماً ويمكن تقديمه حتى 8 مرات في السنة حسب الولاية.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما الوثيقة الأساسية المطلوبة للتسجيل؟','صورة عن جواز سفر ساري المفعول.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم يجب أن تكون مدة صلاحية جواز السفر؟','يجب أن يكون صالحاً لمدة لا تقل عن سنتين.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يجب أن يكون الاسم مطابقاً في جميع الوثائق؟','نعم يجب أن يكون مطابقاً حرفياً للاسم في جواز السفر باللغة الإنجليزية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل مطلوب كشف الثانوية العامة؟','نعم مطلوب كشف الثانوية العامة باللغة الإنجليزية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يجب إرسال كشف علامات الجامعة؟','نعم يجب أن يكون في مغلف مختوم من جميع الجهات.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما الوثيقة المطلوبة من قسم التمريض في الجامعة؟','وصف المساقات مع عدد الساعات النظرية والعملية لكل مادة تخصصية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل هناك وثائق مطلوبة من نقابة التمريض؟','نعم يجب إرسال مغلف من النقابة يحتوي على عدة وثائق.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما الوثائق المطلوبة من النقابة؟','حسن سيرة وسلوك، عضوية النقابة، ونموذج موقع من النقيب باللغة الإنجليزية.','files');
INSERT INTO faq (question,answer,source) VALUES ('ماذا تفعل الشركة بعد استلام الوثائق؟','تقوم بإرسال الوثائق إلى شركة المعادلة الأمريكية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يتم إبلاغ الطالب بنتيجة المعادلة؟','نعم يتم إبلاغه بتقرير المعادلة وكشف العلامات.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يوفر البرنامج دورة تحضير لامتحان NCLEX؟','نعم يوفر دورة استراتيجيات ومحتوى تدريبي للتحضير للامتحان.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم عدد استراتيجيات دورة التحضير؟','12 استراتيجية أساسية.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم مدة دورة الاستراتيجيات؟','حوالي 12 ساعة تدريبية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يمكن مشاهدة الفيديوهات التعليمية لاحقاً؟','نعم يمكن الرجوع إلى الفيديوهات التعليمية في أي وقت.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يقدم البرنامج متابعة للطالب؟','نعم يتم تقديم متابعة فردية وجماعية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يتم تحليل أداء الطالب؟','نعم يتم تحليل نقاط القوة والضعف لدى الطالب.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يتم إعداد خطة دراسية للطالب؟','نعم يتم إعداد خطة فردية لمعالجة الثغرات وتحسين المستوى.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يوجد امتحانات تقييمية خلال الدورة؟','نعم يتم تقديم امتحانات إلكترونية أسبوعية لقياس الجاهزية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يتم تسجيل جلسات المراجعة؟','نعم يتم تسجيل جلسات المراجعة بالفيديو.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل تقوم الشركة بحجز امتحان NCLEX؟','نعم يتم حجز الامتحان حسب رغبة الممرض.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم تكلفة حجز الامتحان في تركيا؟','حوالي 177 دولار.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم تكلفة الامتحان في جنوب أفريقيا؟','حوالي 150 دولار.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم تكلفة الامتحان في الهند؟','حوالي 177 دولار.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم رسوم خدمات البرنامج؟','رسوم الخدمات الأساسية حوالي 650 دينار أردني.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يمكن تقسيط الرسوم؟','نعم يمكن تقسيط الرسوم حسب الوضع المالي.','files');
INSERT INTO faq (question,answer,source) VALUES ('ماذا يحدث بعد النجاح في الامتحان؟','يجب إجراء الفحص الطبي وإرسال التقرير للشركة.','files');
INSERT INTO faq (question,answer,source) VALUES ('ماذا بعد الفحص الطبي؟','يتم حجز موعد في السفارة الأمريكية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يوجد اختبار لغة؟','نعم يجب تقديم اختبار PTE للغة الإنجليزية.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل توفر الشركة عقد عمل؟','نعم يتم التعاقد مع مستشفى في الولايات المتحدة.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل توفر الشركة تذكرة الطيران؟','نعم يتم حجز تذكرة طيران على حساب الشركة.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل توفر الشركة سكن؟','نعم يتم توفير سكن لمدة 90 يوماً.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يحصل الممرض على مصروف أولي؟','نعم يحصل على حوالي 1000 دولار كمصروف شخصي خلال أول 90 يوم.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يوجد تدريب بعد الوصول إلى أمريكا؟','نعم يتم تدريب الممرض للتعرف على النظام الصحي الأمريكي.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم مدة التدريب بعد الوصول؟','حوالي 8 إلى 12 أسبوع.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم راتب الممرض في أمريكا تقريباً؟','يتراوح تقريباً بين 42 و50 دولار في الساعة حسب الولاية.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم عدد أيام العمل في الأسبوع؟','نظام العمل عادة ثلاثة أيام في الأسبوع.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم عدد ساعات العمل في اليوم؟','حوالي 12 ساعة لكل يوم عمل.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم عدد خريجي التمريض سنوياً في فلسطين؟','حوالي 2000 خريج تمريض سنوياً.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم نسبة استيعاب سوق العمل المحلي؟','حوالي 40% فقط من الخريجين.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما متوسط راتب الممرض في فلسطين؟','حوالي 800 إلى 1200 دولار شهرياً.','files');
INSERT INTO faq (question,answer,source) VALUES ('هل يوجد نقص في الممرضين في أمريكا؟','نعم يوجد نقص كبير في الممرضين.','files');
INSERT INTO faq (question,answer,source) VALUES ('كم النقص المتوقع في الممرضين في الولايات المتحدة؟','حوالي 1.1 مليون ممرض بحلول عام 2030.','files');
INSERT INTO faq (question,answer,source) VALUES ('ما متوسط راتب الممرض في أمريكا سنوياً؟','حوالي 80,000 إلى 120,000 دولار سنوياً.','files');
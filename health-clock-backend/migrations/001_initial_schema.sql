-- 健康时钟 MVP 初始数据库 schema
-- 创建时间: 2026-04-23

-- 启用必要扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 成员档案表
CREATE TABLE IF NOT EXISTS profile_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  relation VARCHAR(20),
  gender VARCHAR(10),
  birth_date DATE,
  height_cm DECIMAL(5,2),
  weight_kg DECIMAL(5,2),
  blood_type VARCHAR(10),
  chronic_conditions TEXT[],
  allergies TEXT[],
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_profile_members_user_id ON profile_members(user_id);
CREATE INDEX IF NOT EXISTS idx_profile_members_deleted_at ON profile_members(deleted_at);

-- 健康提醒表
CREATE TABLE IF NOT EXISTS health_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES profile_members(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  event_type VARCHAR(50) NOT NULL,
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_all_day BOOLEAN DEFAULT FALSE,
  repeat_rule JSONB,
  notify_offsets INTEGER[],
  status VARCHAR(20) DEFAULT 'pending',
  source_type VARCHAR(50) NOT NULL,
  source_text TEXT,
  ai_confidence DECIMAL(3,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_health_events_member_id ON health_events(member_id);
CREATE INDEX IF NOT EXISTS idx_health_events_scheduled_at ON health_events(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_health_events_status ON health_events(status);
CREATE INDEX IF NOT EXISTS idx_health_events_deleted_at ON health_events(deleted_at);

-- 医疗文档表
CREATE TABLE IF NOT EXISTS medical_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES profile_members(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  storage_bucket VARCHAR(100) NOT NULL,
  storage_key VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size BIGINT NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  title VARCHAR(200),
  document_date DATE,
  hospital_name VARCHAR(200),
  ocr_text TEXT,
  ai_summary JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_medical_documents_member_id ON medical_documents(member_id);
CREATE INDEX IF NOT EXISTS idx_medical_documents_category ON medical_documents(category);
CREATE INDEX IF NOT EXISTS idx_medical_documents_document_date ON medical_documents(document_date);
CREATE INDEX IF NOT EXISTS idx_medical_documents_deleted_at ON medical_documents(deleted_at);

-- 健康指标记录表
CREATE TABLE IF NOT EXISTS health_metric_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES profile_members(id) ON DELETE CASCADE,
  metric_type VARCHAR(50) NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  value_extra JSONB,
  unit VARCHAR(20) NOT NULL,
  recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_health_metric_records_member_id ON health_metric_records(member_id);
CREATE INDEX IF NOT EXISTS idx_health_metric_records_metric_type ON health_metric_records(metric_type);
CREATE INDEX IF NOT EXISTS idx_health_metric_records_recorded_at ON health_metric_records(recorded_at);

-- 提醒与文档关联表
CREATE TABLE IF NOT EXISTS event_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES health_events(id) ON DELETE CASCADE,
  document_id UUID NOT NULL REFERENCES medical_documents(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, document_id)
);

CREATE INDEX IF NOT EXISTS idx_event_documents_event_id ON event_documents(event_id);
CREATE INDEX IF NOT EXISTS idx_event_documents_document_id ON event_documents(document_id);

-- 更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建更新时间触发器
DROP TRIGGER IF EXISTS update_profile_members_updated_at ON profile_members;
CREATE TRIGGER update_profile_members_updated_at
  BEFORE UPDATE ON profile_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_health_events_updated_at ON health_events;
CREATE TRIGGER update_health_events_updated_at
  BEFORE UPDATE ON health_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_medical_documents_updated_at ON medical_documents;
CREATE TRIGGER update_medical_documents_updated_at
  BEFORE UPDATE ON medical_documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 启用 RLS
ALTER TABLE profile_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_metric_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_documents ENABLE ROW LEVEL SECURITY;

-- RLS 策略：profile_members
DROP POLICY IF EXISTS "用户只能访问自己的成员" ON profile_members;
CREATE POLICY "用户只能访问自己的成员"
  ON profile_members
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS 策略：health_events
DROP POLICY IF EXISTS "用户只能访问自己成员的提醒" ON health_events;
CREATE POLICY "用户只能访问自己成员的提醒"
  ON health_events
  FOR ALL
  USING (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  )
  WITH CHECK (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  );

-- RLS 策略：medical_documents
DROP POLICY IF EXISTS "用户只能访问自己成员的文档" ON medical_documents;
CREATE POLICY "用户只能访问自己成员的文档"
  ON medical_documents
  FOR ALL
  USING (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  )
  WITH CHECK (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  );

-- RLS 策略：health_metric_records
DROP POLICY IF EXISTS "用户只能访问自己成员的健康指标" ON health_metric_records;
CREATE POLICY "用户只能访问自己成员的健康指标"
  ON health_metric_records
  FOR ALL
  USING (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  )
  WITH CHECK (
    member_id IN (
      SELECT id FROM profile_members WHERE user_id = auth.uid() AND deleted_at IS NULL
    )
  );

-- RLS 策略：event_documents
DROP POLICY IF EXISTS "用户只能访问自己的提醒文档关联" ON event_documents;
CREATE POLICY "用户只能访问自己的提醒文档关联"
  ON event_documents
  FOR ALL
  USING (
    event_id IN (
      SELECT he.id FROM health_events he
      JOIN profile_members pm ON he.member_id = pm.id
      WHERE pm.user_id = auth.uid() AND pm.deleted_at IS NULL
    )
  )
  WITH CHECK (
    event_id IN (
      SELECT he.id FROM health_events he
      JOIN profile_members pm ON he.member_id = pm.id
      WHERE pm.user_id = auth.uid() AND pm.deleted_at IS NULL
    )
  );

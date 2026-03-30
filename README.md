# نظام إدارة الأعمال — ERP

## تشغيل النظام (Docker)

### متطلبات
- Docker + Docker Compose

### أول مرة
```bash
docker compose up -d --build
```

النظام يعمل على: **http://localhost**

### تسجيل الدخول الافتراضي
- المستخدم: `ammar`
- كلمة المرور: `changeme`

### إيقاف النظام
```bash
docker compose down
```

### إيقاف مع حذف البيانات (تحذير: لا رجعة)
```bash
docker compose down -v
```

### تحديث النظام بعد تعديلات
```bash
docker compose up -d --build
```

### نسخ احتياطي للبيانات
```bash
docker compose exec db pg_dump -U postgres inventory_db > backup_$(date +%Y%m%d).sql
```

### استعادة نسخة احتياطية
```bash
cat backup_YYYYMMDD.sql | docker compose exec -T db psql -U postgres inventory_db
```

## الإعدادات

لتغيير كلمة مرور قاعدة البيانات أو المفتاح السري، عدّل `docker-compose.yml`:
```yaml
environment:
  SECRET_KEY: your-random-secret-here
  POSTGRES_PASSWORD: your-db-password
```

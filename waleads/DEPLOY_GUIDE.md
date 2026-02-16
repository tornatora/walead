# WALeads - Guida Deploy Production

## 🚀 Stack Consigliato

- **App Next.js**: Vercel
- **Database PostgreSQL**: Railway / Supabase / Neon
- **Redis**: Railway / Upstash
- **Worker**: Railway / VPS separato
- **Email**: Resend
- **Payments**: Stripe
- **Domain**: Cloudflare (opzionale, per CDN)

## 📋 Setup Servizi

### 1. Database (Railway)

```bash
# Installa Railway CLI
npm i -g @railway/cli

# Login
railway login

# Crea progetto
railway init

# Aggiungi PostgreSQL
railway add postgresql

# Copia DATABASE_URL
railway variables
# Copia il valore di DATABASE_URL
```

### 2. Redis (Railway o Upstash)

**Opzione A: Railway**
```bash
railway add redis
# Copia REDIS_URL
```

**Opzione B: Upstash** (serverless, gratis fino 10k req/day)
1. Vai su upstash.com
2. Crea Redis database
3. Copia `UPSTASH_REDIS_REST_URL`

### 3. Vercel (App)

```bash
# Installa Vercel CLI
npm i -g vercel

# Deploy
cd waleads
vercel

# Configura env variables in Vercel Dashboard:
# - DATABASE_URL (da Railway)
# - REDIS_URL (da Railway o Upstash)
# - NEXTAUTH_SECRET (genera: openssl rand -base64 32)
# - ENCRYPTION_KEY (genera: openssl rand -hex 32)
# - STRIPE_SECRET_KEY
# - STRIPE_WEBHOOK_SECRET (vedi sotto)
# - STRIPE_PRICE_ID_SUBSCRIPTION
# - NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
# - OPENAI_API_KEY
# - OPENAI_MODEL=gpt-4o-mini
# - RESEND_API_KEY
# - EMAIL_FROM
# - FOUNDER_EMAILS
# - NEXT_PUBLIC_APP_URL=https://your-domain.vercel.app

# Re-deploy con env
vercel --prod
```

### 4. Stripe Setup

#### A. Crea Prodotto Subscription
1. Vai su Stripe Dashboard → Products
2. Clicca "Add product"
3. Nome: "WALeads Subscription"
4. Descrizione: "Abbonamento mensile WALeads"
5. Pricing:
   - Prezzo: €15
   - Billing: Ricorrente - Mensile
6. Salva
7. Copia `price_id` (formato: `price_xxxxx`)
8. Incolla in `STRIPE_PRICE_ID_SUBSCRIPTION`

#### B. Configura Webhook
1. Stripe Dashboard → Developers → Webhooks
2. "Add endpoint"
3. URL: `https://your-domain.vercel.app/api/webhooks/stripe`
4. Eventi da ascoltare:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
   - `checkout.session.completed`
5. Salva
6. Copia "Signing secret" (formato: `whsec_xxxxx`)
7. Incolla in `STRIPE_WEBHOOK_SECRET` in Vercel

#### C. Test Mode vs Live Mode
- Sviluppo: usa "Test mode" API keys (prefisso `sk_test_`, `pk_test_`)
- Produzione: switcha a "Live mode" (prefisso `sk_live_`, `pk_live_`)

### 5. Resend (Email)

1. Vai su resend.com
2. Signup gratuito (100 email/giorno gratis)
3. Crea API key
4. Aggiungi dominio verificato (es: `yourdomain.com`)
5. Configura DNS (TXT, CNAME per SPF/DKIM)
6. Copia API key in `RESEND_API_KEY`
7. Setta `EMAIL_FROM=WALeads <noreply@yourdomain.com>`

### 6. Worker (Railway)

#### Opzione A: Railway Service
```bash
# Nel progetto Railway esistente
railway add

# Seleziona "Empty Service"
# Nome: "waleads-worker"

# Configura build:
# Build Command: npm install && npx prisma generate
# Start Command: npm run worker

# Deploy
git push railway main

# Configura env (stesse di Vercel + aggiunge):
# DATABASE_URL
# REDIS_URL
# OPENAI_API_KEY
# RESEND_API_KEY
# EMAIL_FROM
# ENCRYPTION_KEY
```

#### Opzione B: VPS separato
```bash
# SSH nel server
ssh user@yourserver.com

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Clone repo
git clone <your-repo>
cd waleads

# Install deps
npm install

# Configura .env (copia da Vercel)

# PM2 per auto-restart
npm install -g pm2

# Start worker
pm2 start npm --name waleads-worker -- run worker

# Auto-start on reboot
pm2 startup
pm2 save

# Monitor
pm2 logs waleads-worker
```

### 7. Database Migrations

```bash
# Dopo deploy, connetti a DB production
# Setta DATABASE_URL locale con URL production (attenzione!)

# Push schema
npx prisma db push

# (Opzionale) Seed demo data
# npm run db:seed

# Genera Prisma client (già fatto in build Vercel)
npx prisma generate
```

## 🔧 Post-Deploy Configuration

### WhatsApp Business API

Ogni cliente deve configurare il proprio. Istruzioni per loro:

1. Crea WhatsApp Business App su Meta for Developers
2. Ottieni:
   - Access Token (permanente)
   - Phone Number ID
   - WABA ID
3. Configura webhook:
   - URL: `https://your-domain.vercel.app/api/webhooks/whatsapp`
   - Verify Token: (generato automaticamente nell'UI WALeads)
   - Subscribe: `messages`, `message_status`
4. Inserisci in WALeads UI: `/app/integrazioni` → Collega WhatsApp

### Meta Lead Ads

1. Crea Form Lead Ads su Facebook Business
2. Ottieni Access Token con permessi:
   - `pages_read_engagement`
   - `leads_retrieval`
3. Configura webhook:
   - URL: `https://your-domain.vercel.app/api/webhooks/meta`
   - Subscribe: `leadgen`
4. Inserisci in WALeads UI: `/app/integrazioni` → Collega Meta

## 🔐 Security Checklist

- [ ] Tutti i secrets in env variables (non committati)
- [ ] `NEXTAUTH_SECRET` unico per production
- [ ] `ENCRYPTION_KEY` unico e sicuro
- [ ] Stripe webhook secret corretto
- [ ] HTTPS attivo (Vercel lo fa automaticamente)
- [ ] CORS configurato se necessario
- [ ] Rate limiting attivo
- [ ] Database backup automatico (Railway lo fa)

## 📊 Monitoring

### Logs
- **Vercel**: Dashboard → Logs (realtime)
- **Railway Worker**: Dashboard → Service → Logs
- **Stripe**: Dashboard → Webhooks → Eventi recenti

### Alerts
- Configura Vercel notifications per errori
- Stripe email alerts per webhook failures
- Uptime monitoring: UptimeRobot / Checkly (ping `/api/health`)

### Metrics
- Vercel Analytics (incluso)
- Prisma Studio per DB queries
- Stripe Dashboard per revenue

## 🐛 Troubleshooting Production

### Webhook non funziona
```bash
# Test manualmente
curl -X POST https://your-domain.vercel.app/api/webhooks/whatsapp \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Dovrebbe ritornare 200
```

### Worker non processa
```bash
# Railway logs
railway logs

# Controlla Redis connection
# Redis UI: Upstash Dashboard o RedisInsight

# Flush queue (attenzione!)
redis-cli -u $REDIS_URL
> FLUSHDB
```

### Database migration error
```bash
# Reset (ATTENZIONE: perde dati)
npx prisma migrate reset

# O manuale
npx prisma db push --force-reset
```

### Email non inviate
- Verifica Resend API key valida
- Controlla dominio verificato
- Log Resend Dashboard → Activity

## 🚀 Go Live Steps

1. [ ] Deploy Vercel production
2. [ ] Deploy Railway worker
3. [ ] Database migrato e seedato (se necessario)
4. [ ] Stripe in Live Mode
5. [ ] Webhook Stripe configurato con URL production
6. [ ] Resend dominio verificato
7. [ ] Test signup end-to-end
8. [ ] Test pagamento reale (carta vera, importo minimo)
9. [ ] Test WhatsApp integration
10. [ ] Test Meta Lead Ads
11. [ ] Founder panel accessibile
12. [ ] Monitoring attivo

## 💰 Costi Stimati (mensili)

- **Vercel**: Gratis (Hobby) o $20/mese (Pro)
- **Railway**: 
  - PostgreSQL: ~$5/mese
  - Redis: ~$5/mese
  - Worker: ~$5/mese
- **Resend**: Gratis (100 email/giorno) o $20/mese (50k email)
- **Upstash Redis** (alternativa): Gratis (10k req) o pay-as-you-go
- **Stripe**: 1.5% + €0.25 per transazione (EU)

**Totale**: ~$15-40/mese (senza traffico)

## 🎯 Performance Targets

- **API Response**: <200ms (webhook)
- **Page Load**: <2s
- **Worker Processing**: <5s per job
- **Uptime**: >99.9%

## 📚 Risorse Utili

- [Vercel Docs](https://vercel.com/docs)
- [Railway Docs](https://docs.railway.app)
- [Prisma Deploy](https://www.prisma.io/docs/guides/deployment)
- [Stripe Webhooks](https://stripe.com/docs/webhooks)
- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [Meta Lead Ads](https://developers.facebook.com/docs/marketing-api/guides/lead-ads)

---

**Deploy completato! 🎉**

Prossimo step: Onboarding primi clienti e monitoring KPI.

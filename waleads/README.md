# WALeads - WhatsApp AI Leads SaaS

SaaS completa per lead generation e pre-qualifica automatica via WhatsApp Business e Meta Lead Ads.

## 🚀 Features

- Multi-tenant con auth completa
- WhatsApp Business Cloud API integration
- Meta Lead Ads webhook integration  
- AI Agent conversazionale (prequalifica + FAQ)
- Billing Stripe (15€/mese + crediti messaggi)
- Founder Panel no-code friendly
- Dashboard moderna (Inbox, Leads, Automazioni, Integrazioni, Billing)
- Queue system (BullMQ + Redis)
- Email notifications (Resend)

## Setup Rapido

```bash
npm install
cp .env.example .env
# Configura .env
npx prisma db push
npm run dev  # Terminal 1
npm run worker  # Terminal 2
```

Vedi README completo per dettagli deploy e testing.

Documentazione founder: `/docs/founder-handbook.md`

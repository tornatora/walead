# WALeads MVP - Checklist Testing Completo

## ✅ Setup Iniziale

- [ ] `npm install` completato
- [ ] `.env` configurato con tutti i secrets
- [ ] Database PostgreSQL creato e connesso
- [ ] Redis server attivo
- [ ] `npx prisma db push` eseguito con successo
- [ ] `npm run db:seed` per dati demo (opzionale)
- [ ] `npm run dev` parte senza errori
- [ ] `npm run worker` parte e processa job

## ✅ Auth & Onboarding

- [ ] Signup funziona (`/signup`)
- [ ] Login funziona (`/login`)
- [ ] Reset password (via email)
- [ ] Wizard onboarding 5 step:
  - Step 1: Benvenuto
  - Step 2: Setup workspace
  - Step 3: Pagamento Stripe
  - Step 4: Collega WhatsApp (o skip)
  - Step 5: Configurazione base

## ✅ WhatsApp Integration

### Setup
- [ ] Creata WhatsApp Business App su Meta Developers
- [ ] Ottenuto: Access Token, Phone Number ID, WABA ID
- [ ] In `/app/integrazioni` → "Collega WhatsApp"
- [ ] Inseriti credenziali nel wizard
- [ ] Webhook configurato in Meta: `https://domain/api/webhooks/whatsapp`
- [ ] Verify token inserito correttamente

### Test Funzionalità
- [ ] Invia messaggio test dal pannello → ricevuto su WhatsApp
- [ ] Invia messaggio a WALeads da WhatsApp → arriva in Inbox
- [ ] Bot AI risponde automaticamente
- [ ] Stato integrazione = "Connesso" (verde)
- [ ] Health check webhook passa

## ✅ Meta Lead Ads Integration

### Setup
- [ ] Creato Form Lead Ads su Facebook
- [ ] Ottenuto Access Token con permessi `leadgen`
- [ ] In `/app/integrazioni` → "Collega Meta"
- [ ] Selezionata Pagina e Form
- [ ] Mappati campi form → profilo lead
- [ ] Webhook configurato: `https://domain/api/webhooks/meta`

### Test Funzionalità
- [ ] Generato lead test da Meta → arriva in `/app/leads`
- [ ] Lead ha campi correttamente mappati
- [ ] Se phone presente → conversazione WhatsApp avviata
- [ ] Messaggio iniziale inviato
- [ ] Stato integrazione = "Connesso"

## ✅ AI Agent & Playbook

### Configurazione
- [ ] `/app/automazioni` accessibile
- [ ] Descrizione offerta compilata
- [ ] Almeno 2-3 FAQ aggiunte
- [ ] Tono di voce selezionato (formale/informale)
- [ ] Domande qualifica create:
  - Almeno 1 campo testo
  - Almeno 1 campo scelta multipla
  - Flag required impostati
- [ ] CTA finale personalizzato
- [ ] Trigger handoff configurati (es: "operatore", "umano")

### Test AI
- [ ] Inviato messaggio → AI risponde in tono corretto
- [ ] Domanda FAQ → AI risponde correttamente
- [ ] AI fa domande qualifica una alla volta
- [ ] Risposte salvate in LeadProfile
- [ ] Trigger handoff funziona → conversazione passa in HANDOFF
- [ ] Protezione prompt injection: AI ignora tentativi malevoli
- [ ] Fallback se OpenAI down → messaggio cortesia + handoff

## ✅ Dashboard Utente

### Inbox (`/app/inbox`)
- [ ] Lista conversazioni visualizzata
- [ ] Ricerca conversazioni funziona
- [ ] Filtri stato (Attive, Archiviate, Handoff)
- [ ] Dettaglio chat con messaggi
- [ ] Note e tag modificabili
- [ ] Toggle "Auto-risposta ON/OFF" funziona

### Leads (`/app/leads`)
- [ ] Lista lead con stati (Nuovo, In Qualifica, Qualificato, Non Idoneo, Handoff)
- [ ] Filtri e ricerca
- [ ] Dettaglio lead con campi raccolti
- [ ] Timeline eventi lead
- [ ] Cambio stato manuale

### Automazioni (`/app/automazioni`)
- [ ] Toggle globale auto-risposta
- [ ] Editor domande qualifica con drag & drop
- [ ] Aggiungi/rimuovi campo funziona
- [ ] Anteprima in tempo reale
- [ ] Salvataggio persistente

### Integrazioni (`/app/integrazioni`)
- [ ] Card WhatsApp con stato e pulsanti
- [ ] Card Meta con stato
- [ ] Test invio WhatsApp
- [ ] Test webhook
- [ ] Ricollega integrazioni

### Billing (`/app/billing`)
- [ ] Abbonamento 15€/mese visualizzato
- [ ] Pulsante "Gestisci pagamento" → Stripe Portal
- [ ] Sezione "Crediti Messaggi WhatsApp"
- [ ] Disclaimer costi Meta visibile
- [ ] Pulsante ricarica crediti → Stripe Checkout
- [ ] Contatori usage stimato

### Team (`/app/team`)
- [ ] Lista membri workspace
- [ ] Invita membro via email
- [ ] Assegna ruoli (Owner, Member)
- [ ] Rimuovi membro

## ✅ Billing Stripe

### Subscription
- [ ] Checkout session creata
- [ ] Test payment con card `4242 4242 4242 4242`
- [ ] Subscription attivata in Stripe
- [ ] Webhook `subscription.created` processato
- [ ] BillingCustomer creato in DB
- [ ] Stato subscription = ACTIVE

### Pagamenti
- [ ] Payment succeeded → Payment record creato
- [ ] Invoice.payment_failed → email inviata
- [ ] Subscription past_due → blocco bot AI
- [ ] Stripe Portal funziona (cancel, update card)

### Crediti Messaggi
- [ ] Checkout one-time payment
- [ ] Metadata `type: credit_topup` corretto
- [ ] Webhook processato → Wallet balance aggiornato
- [ ] WalletLedger entry creata
- [ ] UI mostra nuovo balance

## ✅ Founder Panel

### Auth Founder
- [ ] `/founder` richiede OTP
- [ ] Email in `FOUNDER_EMAILS` può accedere
- [ ] Email NON autorizzata → 403
- [ ] OTP inviato via email
- [ ] Codice valido → login success
- [ ] Codice scaduto (>10 min) → errore

### Dashboard KPI (`/founder`)
- [ ] MRR calcolato correttamente
- [ ] Clienti attivi contati
- [ ] Messaggi oggi
- [ ] Lead oggi
- [ ] Errori oggi (semaforo)

### Gestione Clienti (`/founder/clienti`)
- [ ] Lista workspace visualizzata
- [ ] Colonne: nome, email owner, stato pagamento, WhatsApp, Meta
- [ ] Azioni veloci:
  - [ ] "Sospendi invii" → autoReplyGlobal = false
  - [ ] "Riattiva" → autoReplyGlobal = true
  - [ ] "Ricollega WhatsApp" → reset integration
  - [ ] "Ricollega Meta" → reset integration
  - [ ] "Entra come cliente" → impersonation attiva
  - [ ] Banner impersonation visibile
  - [ ] "Esci" torna a founder panel
  - [ ] "Esporta dati" → download JSON
  - [ ] "Cancella dati" → doppia conferma → eliminazione completa

### Pagamenti (`/founder/pagamenti`)
- [ ] Tabella pagamenti recenti
- [ ] Stati abbonamenti per cliente
- [ ] "Invia link pagamento" → email con Stripe link
- [ ] "Annulla a fine periodo" → Stripe cancel subscription
- [ ] "Crea rimborso" → wizard → Stripe refund
- [ ] Prossimi rinnovi visibili

### Crediti Messaggi (`/founder/crediti-messaggi`)
- [ ] Wallet balance per cliente
- [ ] Consumi mensili
- [ ] "Invia link ricarica" → email link Stripe

### Autodiagnosi (`/founder/problemi`)
- [ ] Health check webhook WhatsApp
  - [ ] Verde se raggiungibile
  - [ ] Rosso se errore
  - [ ] Pulsante "Risolvi" → wizard diagnostico
- [ ] Health check token WhatsApp
  - [ ] Valida token con API Meta
- [ ] Health check webhook Meta
  - [ ] Test endpoint
- [ ] Health check Stripe webhook
  - [ ] Verifica signing secret
- [ ] Log dettagliati per ogni issue

## ✅ Queue & Worker

### BullMQ Setup
- [ ] Queue `webhooks` creata
- [ ] Queue `messages` creata
- [ ] Worker processa job
- [ ] Retry automatico su fallimento
- [ ] Dead letter queue per job falliti permanentemente

### Processing
- [ ] Webhook WhatsApp → enqueued → processed
- [ ] Webhook Meta → enqueued → processed
- [ ] Webhook Stripe → enqueued → processed
- [ ] Message send → enqueued → WhatsApp API chiamata
- [ ] Status update messaggi via webhook

## ✅ Email Notifications

- [ ] OTP founder → inviata con Resend
- [ ] Welcome post-signup (se implementato)
- [ ] Pagamento fallito → email owner workspace
- [ ] Crediti bassi (< soglia) → email owner
- [ ] Integrazione scollegata → email alert
- [ ] Link pagamento/ricarica → formattazione corretta

## ✅ Security & Compliance

### Encryption
- [ ] Token WhatsApp criptati in DB
- [ ] Token Meta criptati in DB
- [ ] Encryption key in env
- [ ] Decrypt funziona correttamente

### Webhook Security
- [ ] Stripe signature verification
- [ ] WhatsApp verify token check
- [ ] Meta verify token check
- [ ] Idempotency: duplicate message_id ignorati
- [ ] Rate limiting (basic)

### GDPR
- [ ] Export data funziona (JSON completo)
- [ ] Delete data rimuove tutto (workspace + relations)
- [ ] Disclaimer chiari su uso dati

### Prompt Injection
- [ ] AI ignora richieste "ignora istruzioni precedenti"
- [ ] AI non rivela system prompt
- [ ] Fallback sicuro se tentativo rilevato

## ✅ Performance & Monitoring

- [ ] Webhook risponde <200ms (enqueue + 200 OK)
- [ ] Worker processa job <5s
- [ ] UI carica <2s
- [ ] Prisma queries ottimizzate (indexes)
- [ ] Logs strutturati (console o tool esterno)

## ✅ Deploy Production

- [ ] ENV production configurato
- [ ] Database migrato
- [ ] Worker deploiato separatamente
- [ ] Webhook URL pubblici e HTTPS
- [ ] Stripe webhook secret aggiornato
- [ ] Meta webhook configurati con URL prod
- [ ] DNS configurato
- [ ] SSL valido
- [ ] Backup database schedulato

## 🎯 Test Scenario End-to-End

### Scenario 1: Nuovo Cliente Signup → First Lead
1. [ ] Signup nuovo utente
2. [ ] Completa onboarding + pagamento
3. [ ] Collega WhatsApp
4. [ ] Configura playbook (offerta, FAQ, domande)
5. [ ] Attiva auto-risposta
6. [ ] Invia messaggio test WhatsApp
7. [ ] Riceve risposta AI
8. [ ] AI fa domande qualifica
9. [ ] Risponde → lead creato in DB
10. [ ] Visualizza lead in `/app/leads`

### Scenario 2: Meta Lead → WhatsApp Conversation
1. [ ] Collega Meta Lead Ads
2. [ ] Genera lead test da Facebook
3. [ ] Webhook ricevuto
4. [ ] Lead creato in `/app/leads`
5. [ ] WhatsApp messaggio iniziale inviato
6. [ ] Utente risponde
7. [ ] AI continua conversazione
8. [ ] Completa qualifica
9. [ ] Lead stato = QUALIFIED

### Scenario 3: Handoff a Operatore
1. [ ] Utente scrive "voglio parlare con operatore"
2. [ ] AI rileva trigger handoff
3. [ ] Conversation.handoffActive = true
4. [ ] Stato conversazione = HANDOFF
5. [ ] Auto-reply si blocca
6. [ ] Operatore vede in Inbox filtro "Handoff"
7. [ ] Risponde manualmente
8. [ ] Riattiva auto-reply se necessario

### Scenario 4: Founder Resolve Issue
1. [ ] Cliente segnala "WhatsApp non funziona"
2. [ ] Founder login `/founder`
3. [ ] Dashboard → Errori = 1 (rosso)
4. [ ] Vai in Problemi → "Webhook WhatsApp errore"
5. [ ] Clicca "Risolvi"
6. [ ] Wizard mostra: "Token scaduto"
7. [ ] Clicca "Ricollega WhatsApp" su cliente
8. [ ] Cliente rifà wizard
9. [ ] Stato torna verde

### Scenario 5: Pagamento Fallito → Risoluzione
1. [ ] Subscription Stripe va in past_due
2. [ ] Webhook ricevuto
3. [ ] Email inviata a cliente
4. [ ] Bot AI si blocca (paywall)
5. [ ] Founder invia link pagamento
6. [ ] Cliente aggiorna carta
7. [ ] Payment succeeds
8. [ ] Auto-riattivazione
9. [ ] Bot riprende a funzionare

## 📝 Note Finali

### Known Limitations (MVP)
- Meta OAuth non implementato (token-based ok per MVP)
- Email via Resend (non SMTP nativo)
- Rate limiting base (non enterprise-grade)
- Analytics dashboard minima (estendibile)

### Cosa testare manualmente
- UX onboarding completo (5 min)
- Conversazioni WhatsApp reali (non solo test)
- Prompt AI con casi edge
- Impersonation founder in tutti scenari
- Stripe test mode → production switch

### Log da monitorare
- Worker console per processing errors
- Next.js console per API errors
- Stripe Dashboard per webhook failures
- Redis per queue bottleneck

---

**Checklist completata = MVP Production-Ready! 🚀**

# WALeads - Manuale Founder

Guida completa per gestire WALeads senza competenze tecniche.

## Accesso Founder Panel
1. Vai su /founder
2. Inserisci email autorizzata
3. Ricevi codice OTP via email
4. Inserisci codice → accesso effettuato

## Dashboard KPI
- MRR, clienti attivi, messaggi oggi, lead oggi, errori
- Semaforo: verde = OK, giallo = warning, rosso = errore critico

## Gestione Clienti (/founder/clienti)
Azioni disponibili:
- **Sospendi invii**: blocca bot AI temporaneamente
- **Riattiva**: riabilita dopo sospensione
- **Ricollega WhatsApp/Meta**: reset integrazione con wizard
- **Entra come cliente**: impersonation per configurare
- **Esporta dati**: download JSON (GDPR)
- **Cancella dati**: eliminazione completa (doppia conferma)

## Collegare Integrazioni

### WhatsApp Business
Cliente deve:
1. Creare WhatsApp Business App su Meta
2. Ottenere: ACCESS_TOKEN, PHONE_NUMBER_ID, WABA_ID
3. In WALeads: /app/integrazioni → Collega WhatsApp
4. Inserire dati nel wizard
5. Configurare webhook Meta: https://domain/api/webhooks/whatsapp
6. Test invio → verifica ricezione

### Meta Lead Ads
Cliente deve:
1. Creare Form Lead Ads
2. Ottenere ACCESS_TOKEN con permessi leadgen
3. In WALeads: /app/integrazioni → Collega Meta
4. Selezionare Pagina e Form
5. Mappare campi form
6. Webhook: https://domain/api/webhooks/meta
7. Test lead → verifica arrivo in /app/leads

## Gestire Pagamenti

### Abbonamento 15€/mese
- Visualizza stati in /founder/pagamenti
- Se fallito: "Invia link pagamento" → cliente aggiorna carta
- Annulla: "Annulla a fine periodo"
- Rimborso: "Crea rimborso" → wizard guidato

### Crediti Messaggi
- Non inclusi in abbonamento (pass-through Meta)
- Wallet per workspace in /founder/crediti-messaggi
- Se balance = 0 → bot blocca invii
- "Invia link ricarica" → cliente paga one-time → crediti aggiunti

## Autodiagnosi Problemi

### Webhook WhatsApp non raggiungibile
→ Clicca "Risolvi" → wizard verifica URL pubblico, SSL, porta
→ Se Meta issue: "Ricollega WhatsApp"

### Token scaduto
→ Stato "Errore" → "Ricollega" → cliente genera nuovo token

### Lead Ads non arrivano
→ Verifica webhook Meta configurato → test lead → "Ricollega Meta"

## Messaggi Pronti

**Benvenuto**:
"Ciao! Benvenuto in WALeads. Segui wizard (5 min), collega WhatsApp, configura automazioni. Dubbi? Scrivimi!"

**Costi messaggi**:
"Costi WhatsApp determinati da Meta, NON inclusi in abbonamento 15€. Ricarica da Billing → Crediti Messaggi."

**WhatsApp non invia**:
"Controlla: 1) Integrazione connessa 2) Crediti disponibili 3) Abbonamento attivo. Test invio in Integrazioni."

**Pagamento fallito**:
"Pagamento non riuscito. Billing → Gestisci pagamento → aggiorna carta. Auto-riattivazione."

**Esporta dati (GDPR)**:
"Conferma via email, invio JSON con tutti dati entro 24h."

## Checklist Quotidiana
- Dashboard → errori = 0?
- Clienti pagamenti scaduti?
- Autodiagnosi verde?
- Email clienti da gestire?


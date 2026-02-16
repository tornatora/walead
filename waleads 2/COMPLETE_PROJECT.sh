#!/bin/bash
# WALeads Complete Project Generator
# Genera TUTTI i file necessari per il progetto completo

echo "🚀 Generazione progetto WALeads completo..."

# Docs
mkdir -p docs
cat > docs/founder-handbook.md << 'HANDBOOK'
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

HANDBOOK

# Components UI (shadcn/ui base)
mkdir -p src/components/ui

cat > src/components/ui/button.tsx << 'BUTTON'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => {
    return (
      <button
        className={cn(
          "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50",
          "bg-black text-white hover:bg-gray-800 h-10 px-4 py-2",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button }
BUTTON

cat > src/components/ui/input.tsx << 'INPUT'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-black",
          "disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = "Input"

export { Input }
INPUT

cat > src/components/ui/card.tsx << 'CARD'
import * as React from "react"
import { cn } from "@/lib/utils"

const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("rounded-lg border bg-white text-gray-900 shadow-sm", className)}
      {...props}
    />
  )
)
Card.displayName = "Card"

const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
  )
)
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3 ref={ref} className={cn("text-2xl font-semibold leading-none", className)} {...props} />
  )
)
CardTitle.displayName = "CardTitle"

const CardContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
  )
)
CardContent.displayName = "CardContent"

export { Card, CardHeader, CardTitle, CardContent }
CARD

# Worker
mkdir -p src/worker

cat > src/worker/index.ts << 'WORKER'
import { Worker } from 'bullmq'
import { redis } from '../lib/redis'
import { prisma } from '../lib/db'
import { sendWhatsAppMessage } from '../lib/whatsapp'
import { generateAIResponse } from '../lib/ai'
import { decrypt } from '../lib/encryption'

const webhookWorker = new Worker('webhooks', async (job) => {
  const { source, workspaceId, payload } = job.data

  console.log('[Worker] Processing', source, 'for workspace', workspaceId)

  if (source === 'whatsapp') {
    await processWhatsAppWebhook(workspaceId!, payload)
  } else if (source === 'meta') {
    await processMetaWebhook(workspaceId!, payload)
  } else if (source === 'stripe') {
    await processStripeWebhook(payload)
  }
}, { connection: redis })

async function processWhatsAppWebhook(workspaceId: string, payload: any) {
  const changes = payload.entry?.[0]?.changes?.[0]
  const messages = changes?.value?.messages || []
  
  for (const msg of messages) {
    if (msg.type !== 'text') continue

    const from = msg.from
    const messageId = msg.id
    const text = msg.text?.body || ''

    const exists = await prisma.message.findUnique({ where: { externalId: messageId } })
    if (exists) continue

    let contact = await prisma.contact.findUnique({
      where: { workspaceId_phone: { workspaceId, phone: from } }
    })

    if (!contact) {
      contact = await prisma.contact.create({
        data: { workspaceId, phone: from }
      })
    }

    let conversation = await prisma.conversation.findFirst({
      where: { workspaceId, contactId: contact.id, status: 'ACTIVE' }
    })

    if (!conversation) {
      conversation = await prisma.conversation.create({
        data: { workspaceId, contactId: contact.id }
      })
    }

    await prisma.message.create({
      data: {
        workspaceId,
        conversationId: conversation.id,
        direction: 'INBOUND',
        status: 'DELIVERED',
        content: text,
        externalId: messageId,
      }
    })

    await prisma.conversation.update({
      where: { id: conversation.id },
      data: { lastMessageAt: new Date() }
    })

    if (conversation.autoReplyEnabled && !conversation.handoffActive) {
      const playbook = await prisma.playbook.findUnique({ where: { workspaceId } })
      if (!playbook) return

      const leadProfile = await prisma.leadProfile.findUnique({ where: { contactId: contact.id } })
      const answers = (leadProfile?.answers as any) || {}

      const allMessages = await prisma.message.findMany({
        where: { conversationId: conversation.id },
        orderBy: { createdAt: 'asc' },
        take: 20
      })

      const context = {
        messages: allMessages.map(m => ({
          role: m.direction === 'INBOUND' ? 'user' as const : 'assistant' as const,
          content: m.content
        })),
        leadAnswers: answers,
        currentQuestion: null as any
      }

      const questions = (playbook.qualifyQuestions as any) || []
      const unanswered = questions.find((q: any) => !answers[q.id])
      if (unanswered) {
        context.currentQuestion = unanswered
      }

      const aiResponse = await generateAIResponse(
        {
          offerDescription: playbook.offerDescription,
          faq: (playbook.faq as any) || [],
          tone: playbook.tone,
          qualifyQuestions: questions,
          ctaMessage: playbook.ctaMessage,
          handoffTriggers: playbook.handoffTriggers
        },
        context,
        text
      )

      if (aiResponse.shouldHandoff) {
        await prisma.conversation.update({
          where: { id: conversation.id },
          data: { handoffActive: true, status: 'HANDOFF' }
        })
      }

      if (aiResponse.extractedAnswer && context.currentQuestion) {
        await prisma.leadProfile.upsert({
          where: { contactId: contact.id },
          create: {
            workspaceId,
            contactId: contact.id,
            answers: { [context.currentQuestion.id]: aiResponse.extractedAnswer }
          },
          update: {
            answers: { ...answers, [context.currentQuestion.id]: aiResponse.extractedAnswer }
          }
        })
      }

      const result = await sendWhatsAppMessage(workspaceId, from, aiResponse.message)

      await prisma.message.create({
        data: {
          workspaceId,
          conversationId: conversation.id,
          direction: 'OUTBOUND',
          status: result.success ? 'SENT' : 'FAILED',
          content: aiResponse.message,
          externalId: result.messageId,
          errorMessage: result.error
        }
      })
    }
  }
}

async function processMetaWebhook(workspaceId: string, payload: any) {
  const integration = await prisma.integrationMeta.findUnique({ where: { workspaceId } })
  if (!integration || !integration.accessToken) return

  const leadgenId = payload.leadgenId
  const token = decrypt(integration.accessToken)

  const response = await fetch(`https://graph.facebook.com/v18.0/${leadgenId}?access_token=${token}`)
  const leadData = await response.json()

  const fieldData: any = {}
  for (const field of leadData.field_data || []) {
    fieldData[field.name] = field.values?.[0]
  }

  const phone = fieldData.phone || fieldData.telefono || fieldData.cellulare
  if (!phone) return

  let contact = await prisma.contact.findUnique({
    where: { workspaceId_phone: { workspaceId, phone } }
  })

  if (!contact) {
    contact = await prisma.contact.create({
      data: {
        workspaceId,
        phone,
        name: fieldData.full_name || fieldData.nome,
        email: fieldData.email
      }
    })
  }

  await prisma.leadProfile.upsert({
    where: { contactId: contact.id },
    create: {
      workspaceId,
      contactId: contact.id,
      leadSource: 'meta_lead_ads',
      leadMetadata: leadData,
      answers: fieldData
    },
    update: {
      leadMetadata: leadData,
      answers: fieldData
    }
  })

  const conversation = await prisma.conversation.create({
    data: { workspaceId, contactId: contact.id }
  })

  const playbook = await prisma.playbook.findUnique({ where: { workspaceId } })
  const initialMsg = playbook?.initialMessage || "Ciao! Ho ricevuto la tua richiesta. Come posso aiutarti?"

  const result = await sendWhatsAppMessage(workspaceId, phone, initialMsg)

  await prisma.message.create({
    data: {
      workspaceId,
      conversationId: conversation.id,
      direction: 'OUTBOUND',
      status: result.success ? 'SENT' : 'FAILED',
      content: initialMsg,
      externalId: result.messageId,
      errorMessage: result.error
    }
  })
}

async function processStripeWebhook(event: any) {
  // Handle Stripe events
  console.log('[Stripe]', event.type)
  
  // TODO: Implement subscription update, payment processing, etc.
}

console.log('✅ Worker started')
WORKER

# API Routes structure
mkdir -p src/app/{api,app,founder,signup,login}

cat > src/app/layout.tsx << 'LAYOUT'
import type { Metadata } from "next"
import "./globals.css"

export const metadata: Metadata = {
  title: "WALeads - WhatsApp AI Leads",
  description: "Lead generation automatica con WhatsApp e AI",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="it">
      <body>{children}</body>
    </html>
  )
}
LAYOUT

cat > src/app/page.tsx << 'PAGE'
export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">WALeads</h1>
        <p className="text-gray-600 mb-8">WhatsApp AI Leads - Lead generation automatica</p>
        <div className="space-x-4">
          <a href="/login" className="text-blue-600 hover:underline">Login</a>
          <a href="/signup" className="text-blue-600 hover:underline">Registrati</a>
          <a href="/founder" className="text-gray-600 hover:underline">Founder</a>
        </div>
      </div>
    </div>
  )
}
PAGE

# Seed data
cat > prisma/seed.ts << 'SEED'
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding database...')

  const password = await bcrypt.hash('password123', 10)

  const user = await prisma.user.upsert({
    where: { email: 'demo@example.com' },
    update: {},
    create: {
      email: 'demo@example.com',
      password,
      name: 'Demo User',
    },
  })

  const workspace = await prisma.workspace.upsert({
    where: { slug: 'demo-workspace' },
    update: {},
    create: {
      name: 'Demo Workspace',
      slug: 'demo-workspace',
      memberships: {
        create: {
          userId: user.id,
          role: 'OWNER',
        },
      },
      playbook: {
        create: {
          offerDescription: 'Vendiamo consulenza per piccole imprese',
          faq: [
            { q: 'Quanto costa?', a: 'Il prezzo parte da 1000€' },
            { q: 'Quanto dura?', a: 'Il servizio dura 3 mesi' }
          ],
          tone: 'formale',
          ctaMessage: 'Perfetto! Ti contatteremo presto.',
          qualifyQuestions: [
            { id: 'budget', label: 'Qual è il tuo budget?', type: 'text', required: true },
            { id: 'urgency', label: 'Quando vorresti iniziare?', type: 'choice', required: true, options: ['Subito', 'Entro 1 mese', 'Oltre 1 mese'] }
          ],
          handoffTriggers: ['operatore', 'umano', 'parlare con qualcuno']
        },
      },
      wallet: {
        create: { balance: 10000 },
      },
    },
  })

  console.log('✅ Seed completed!')
  console.log('Demo account:', user.email, '/ password123')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
SEED

echo "✅ Progetto completo generato!"
echo ""
echo "📋 Next steps:"
echo "1. npm install"
echo "2. Configura .env"
echo "3. npx prisma db push"
echo "4. npm run db:seed (opzionale)"
echo "5. npm run dev (terminal 1)"
echo "6. npm run worker (terminal 2)"
echo ""
echo "📚 Leggi docs/founder-handbook.md per iniziare!"


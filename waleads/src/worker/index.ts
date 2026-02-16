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

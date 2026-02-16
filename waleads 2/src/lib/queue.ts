import { Queue, Worker, QueueEvents } from 'bullmq'
import { redis } from './redis'

export const messageQueue = new Queue('messages', { connection: redis as any })
export const webhookQueue = new Queue('webhooks', { connection: redis as any })

export type MessageJob = {
  workspaceId: string
  conversationId: string
  content: string
  messageId?: string
}

export type WebhookJob = {
  source: 'whatsapp' | 'meta' | 'stripe'
  workspaceId?: string
  payload: any
}

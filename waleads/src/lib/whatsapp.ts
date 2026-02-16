import { prisma } from './db'
import { decrypt } from './encryption'

export async function sendWhatsAppMessage(
  workspaceId: string,
  to: string,
  message: string
): Promise<{ success: boolean; messageId?: string; error?: string }> {
  try {
    const integration = await prisma.integrationWhatsApp.findUnique({
      where: { workspaceId }
    })

    if (!integration || !integration.accessToken || !integration.phoneNumberId) {
      return { success: false, error: 'WhatsApp non configurato' }
    }

    const token = decrypt(integration.accessToken)
    
    const response = await fetch(
      `https://graph.facebook.com/v18.0/${integration.phoneNumberId}/messages`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: to,
          type: 'text',
          text: { body: message }
        })
      }
    )

    const data = await response.json()

    if (!response.ok) {
      return { success: false, error: data.error?.message || 'Errore invio' }
    }

    return { success: true, messageId: data.messages?.[0]?.id }
  } catch (error: any) {
    return { success: false, error: error.message }
  }
}

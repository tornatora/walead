import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendEmail(to: string, subject: string, html: string) {
  try {
    await resend.emails.send({
      from: process.env.EMAIL_FROM!,
      to,
      subject,
      html,
    })
    return { success: true }
  } catch (error: any) {
    console.error('Email error:', error)
    return { success: false, error: error.message }
  }
}

export async function sendOtpEmail(email: string, code: string) {
  return await sendEmail(
    email,
    'Codice accesso WALeads Founder',
    `<p>Il tuo codice OTP è: <strong>${code}</strong></p><p>Valido per 10 minuti.</p>`
  )
}

export async function sendPaymentFailedEmail(email: string, workspaceName: string) {
  return await sendEmail(
    email,
    'Pagamento fallito - WALeads',
    `<p>Ciao,</p><p>Il pagamento per ${workspaceName} non è andato a buon fine. Aggiorna il metodo di pagamento per continuare a usare WALeads.</p>`
  )
}

export async function sendLowCreditsEmail(email: string, workspaceName: string, balance: number) {
  return await sendEmail(
    email,
    'Crediti messaggi in esaurimento - WALeads',
    `<p>Ciao,</p><p>I crediti messaggi per ${workspaceName} stanno finendo (${balance} rimanenti). Ricarica per continuare a inviare messaggi.</p>`
  )
}

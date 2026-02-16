import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
})

export async function createCustomer(email: string, workspaceId: string) {
  return await stripe.customers.create({
    email,
    metadata: { workspaceId }
  })
}

export async function createSubscription(customerId: string) {
  return await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: process.env.STRIPE_PRICE_ID_SUBSCRIPTION }],
    payment_behavior: 'default_incomplete',
    expand: ['latest_invoice.payment_intent'],
  })
}

export async function createCheckoutSession(customerId: string, workspaceId: string) {
  return await stripe.checkout.sessions.create({
    customer: customerId,
    mode: 'subscription',
    line_items: [
      {
        price: process.env.STRIPE_PRICE_ID_SUBSCRIPTION,
        quantity: 1,
      },
    ],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/app/billing?success=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/app/billing?canceled=true`,
    metadata: { workspaceId }
  })
}

export async function createCreditTopupSession(
  customerId: string,
  workspaceId: string,
  amount: number
) {
  return await stripe.checkout.sessions.create({
    customer: customerId,
    mode: 'payment',
    line_items: [
      {
        price_data: {
          currency: 'eur',
          product_data: {
            name: 'Crediti Messaggi WhatsApp',
            description: 'Ricarica crediti per messaggistica WhatsApp Business',
          },
          unit_amount: amount * 100,
        },
        quantity: 1,
      },
    ],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/app/billing?topup=success`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/app/billing`,
    metadata: { workspaceId, type: 'credit_topup', amount: amount.toString() }
  })
}

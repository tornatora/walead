#!/bin/bash

# API Routes e Auth

mkdir -p src/app/api/webhooks src/app/api/auth src/app/api/app src/app/api/founder

# ============ WEBHOOK WHATSAPP ============

cat > src/app/api/webhooks/whatsapp/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import { webhookQueue } from '@/lib/queue'

export async function GET(req: NextRequest) {
  const params = req.nextUrl.searchParams
  const mode = params.get('hub.mode')
  const token = params.get('hub.verify_token')
  const challenge = params.get('hub.challenge')

  if (mode === 'subscribe') {
    const integration = await prisma.integrationWhatsApp.findFirst({
      where: { verifyToken: token }
    })
    
    if (integration && challenge) {
      return new NextResponse(challenge)
    }
  }

  return new NextResponse('Forbidden', { status: 403 })
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    
    const phoneNumberId = body.entry?.[0]?.changes?.[0]?.value?.metadata?.phone_number_id
    
    if (!phoneNumberId) {
      return NextResponse.json({ success: true })
    }

    const integration = await prisma.integrationWhatsApp.findFirst({
      where: { phoneNumberId }
    })

    if (!integration) {
      return NextResponse.json({ success: true })
    }

    await webhookQueue.add('whatsapp-event', {
      source: 'whatsapp',
      workspaceId: integration.workspaceId,
      payload: body
    })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('WhatsApp webhook error:', error)
    return NextResponse.json({ success: true })
  }
}
EOF

# ============ WEBHOOK META LEADGEN ============

cat > src/app/api/webhooks/meta/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import { webhookQueue } from '@/lib/queue'

export async function GET(req: NextRequest) {
  const params = req.nextUrl.searchParams
  const mode = params.get('hub.mode')
  const token = params.get('hub.verify_token')
  const challenge = params.get('hub.challenge')

  if (mode === 'subscribe' && token === 'waleads_verify_token' && challenge) {
    return new NextResponse(challenge)
  }

  return new NextResponse('Forbidden', { status: 403 })
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()

    if (body.object === 'page') {
      for (const entry of body.entry || []) {
        for (const change of entry.changes || []) {
          if (change.field === 'leadgen') {
            const leadgenId = change.value?.leadgen_id
            const pageId = change.value?.page_id

            const integration = await prisma.integrationMeta.findFirst({
              where: { pageId }
            })

            if (integration) {
              await webhookQueue.add('meta-leadgen', {
                source: 'meta',
                workspaceId: integration.workspaceId,
                payload: { leadgenId, pageId, ...change.value }
              })
            }
          }
        }
      }
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Meta webhook error:', error)
    return NextResponse.json({ success: true })
  }
}
EOF

# ============ WEBHOOK STRIPE ============

cat > src/app/api/webhooks/stripe/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { webhookQueue } from '@/lib/queue'

export async function POST(req: NextRequest) {
  const body = await req.text()
  const sig = req.headers.get('stripe-signature')!

  try {
    const event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    )

    await webhookQueue.add('stripe-event', {
      source: 'stripe',
      payload: event
    })

    return NextResponse.json({ received: true })
  } catch (error: any) {
    console.error('Stripe webhook error:', error.message)
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
EOF

echo "✅ API Webhooks creati"

# ============ AUTH ENDPOINTS ============

cat > src/app/api/auth/signup/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import bcrypt from 'bcryptjs'
import { generateSlug } from '@/lib/utils'

export async function POST(req: NextRequest) {
  try {
    const { email, password, name, workspaceName } = await req.json()

    const exists = await prisma.user.findUnique({ where: { email } })
    if (exists) {
      return NextResponse.json({ error: 'Email già registrata' }, { status: 400 })
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
      },
    })

    const workspace = await prisma.workspace.create({
      data: {
        name: workspaceName || 'La mia azienda',
        slug: generateSlug(workspaceName || email),
        memberships: {
          create: {
            userId: user.id,
            role: 'OWNER',
          },
        },
        playbook: {
          create: {},
        },
        wallet: {
          create: {},
        },
      },
    })

    return NextResponse.json({ success: true, userId: user.id, workspaceId: workspace.id })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
EOF

cat > src/app/api/auth/founder-otp/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import { generateOTP } from '@/lib/utils'
import { sendOtpEmail } from '@/lib/email'

const FOUNDER_EMAILS = (process.env.FOUNDER_EMAILS || '').split(',').map(e => e.trim())

export async function POST(req: NextRequest) {
  try {
    const { email, code } = await req.json()

    if (!FOUNDER_EMAILS.includes(email)) {
      return NextResponse.json({ error: 'Non autorizzato' }, { status: 403 })
    }

    if (!code) {
      const otpCode = generateOTP()
      await prisma.emailOtp.create({
        data: {
          email,
          code: otpCode,
          expiresAt: new Date(Date.now() + 10 * 60 * 1000),
        },
      })

      await sendOtpEmail(email, otpCode)

      return NextResponse.json({ success: true, message: 'Codice inviato' })
    }

    const otp = await prisma.emailOtp.findFirst({
      where: {
        email,
        code,
        verified: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    })

    if (!otp) {
      return NextResponse.json({ error: 'Codice non valido' }, { status: 400 })
    }

    await prisma.emailOtp.update({
      where: { id: otp.id },
      data: { verified: true },
    })

    return NextResponse.json({ success: true, token: btoa(email + ':' + Date.now()) })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
EOF

echo "✅ Auth endpoints creati"

# ============ APP ENDPOINTS ============

cat > src/app/api/app/playbook/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'

export async function PUT(req: NextRequest) {
  try {
    const { workspaceId, ...data } = await req.json()

    const playbook = await prisma.playbook.upsert({
      where: { workspaceId },
      create: { workspaceId, ...data },
      update: data,
    })

    return NextResponse.json(playbook)
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
EOF

cat > src/app/api/app/integrations/whatsapp/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/db'
import { encrypt } from '@/lib/encryption'

export async function POST(req: NextRequest) {
  try {
    const { workspaceId, accessToken, phoneNumberId, wabaId, verifyToken, phoneNumber } = await req.json()

    const integration = await prisma.integrationWhatsApp.upsert({
      where: { workspaceId },
      create: {
        workspaceId,
        accessToken: encrypt(accessToken),
        phoneNumberId,
        wabaId,
        verifyToken,
        phoneNumber,
        status: 'ACTIVE',
      },
      update: {
        accessToken: encrypt(accessToken),
        phoneNumberId,
        wabaId,
        verifyToken,
        phoneNumber,
        status: 'ACTIVE',
        lastError: null,
      },
    })

    return NextResponse.json({ success: true, integration })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
EOF

echo "✅ App API creati"


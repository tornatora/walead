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

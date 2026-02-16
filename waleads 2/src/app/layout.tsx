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

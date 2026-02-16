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

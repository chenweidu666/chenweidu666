import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import Navbar from './components/Navbar'
import Dashboard from './pages/Dashboard'
import ClothesList from './pages/ClothesList'
import AddClothes from './pages/AddClothes'
import EditClothes from './pages/EditClothes'
import ClothesDetail from './pages/ClothesDetail'
import './App.css'

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Navbar />
        <main className="container mx-auto px-4 py-8">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/clothes" element={<ClothesList />} />
            <Route path="/clothes/add" element={<AddClothes />} />
            <Route path="/clothes/:id" element={<ClothesDetail />} />
            <Route path="/clothes/:id/edit" element={<EditClothes />} />
          </Routes>
        </main>
        <Toaster position="top-right" />
      </div>
    </Router>
  )
}

export default App 
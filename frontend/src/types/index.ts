export interface Clothes {
  id: number;
  name: string;
  category: string;
  color: string;
  size: string;
  season: string;
  image_url: string | null;
  description: string;
  created_at: string;
  updated_at: string;
}

export interface Stats {
  total: number;
  tops: number;
  pants: number;
  dresses: number;
  outerwear: number;
  shoes: number;
  accessories: number;
}

export interface ClothesFormData {
  name: string;
  category: string;
  color: string;
  size: string;
  season: string;
  description: string;
  image?: File;
} 
import axios from 'axios';
import { Clothes, Stats, ClothesFormData } from '../types';

const API_BASE_URL = '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const clothesApi = {
  // 获取所有衣服
  getAll: async (): Promise<Clothes[]> => {
    const response = await api.get('/clothes');
    return response.data;
  },

  // 获取单个衣服
  getById: async (id: number): Promise<Clothes> => {
    const response = await api.get(`/clothes/${id}`);
    return response.data;
  },

  // 添加衣服
  create: async (data: ClothesFormData): Promise<Clothes> => {
    const formData = new FormData();
    formData.append('name', data.name);
    formData.append('category', data.category);
    formData.append('color', data.color);
    formData.append('size', data.size);
    formData.append('season', data.season);
    formData.append('description', data.description);
    
    if (data.image) {
      formData.append('image', data.image);
    }

    const response = await api.post('/clothes', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // 更新衣服
  update: async (id: number, data: ClothesFormData): Promise<{ message: string }> => {
    const formData = new FormData();
    formData.append('name', data.name);
    formData.append('category', data.category);
    formData.append('color', data.color);
    formData.append('size', data.size);
    formData.append('season', data.season);
    formData.append('description', data.description);
    
    if (data.image) {
      formData.append('image', data.image);
    }

    const response = await api.put(`/clothes/${id}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // 删除衣服
  delete: async (id: number): Promise<{ message: string }> => {
    const response = await api.delete(`/clothes/${id}`);
    return response.data;
  },

  // 按分类获取衣服
  getByCategory: async (category: string): Promise<Clothes[]> => {
    const response = await api.get(`/clothes/category/${category}`);
    return response.data;
  },

  // 搜索衣服
  search: async (query: string): Promise<Clothes[]> => {
    const response = await api.get(`/clothes/search/${query}`);
    return response.data;
  },
};

export const statsApi = {
  // 获取统计信息
  getStats: async (): Promise<Stats> => {
    const response = await api.get('/stats');
    return response.data;
  },
}; 
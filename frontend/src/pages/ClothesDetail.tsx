import { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { Shirt, Edit, ArrowLeft } from 'lucide-react';
import { clothesApi } from '../services/api';
import { Clothes } from '../types';
import toast from 'react-hot-toast';

const ClothesDetail = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [clothes, setClothes] = useState<Clothes | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      fetchClothes();
    }
    // eslint-disable-next-line
  }, [id]);

  const fetchClothes = async () => {
    try {
      const data = await clothesApi.getById(parseInt(id!));
      setClothes(data);
    } catch (error) {
      console.error('获取衣服信息失败:', error);
      toast.error('获取衣服信息失败');
      navigate('/clothes');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!clothes) {
    return (
      <div className="text-center py-12">
        <h3 className="text-lg font-medium text-gray-900 mb-2">衣服不存在</h3>
        <button
          onClick={() => navigate('/clothes')}
          className="text-primary-600 hover:text-primary-700"
        >
          返回衣服列表
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center space-x-4 mb-8">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center space-x-2 text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft size={20} />
          <span>返回</span>
        </button>
        <h1 className="text-3xl font-bold text-gray-900">衣服详情</h1>
        <Link
          to={`/clothes/${clothes.id}/edit`}
          className="flex items-center space-x-2 text-primary-600 hover:text-primary-700 ml-auto"
        >
          <Edit size={20} />
          <span>编辑</span>
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex flex-col md:flex-row gap-8">
          <div className="flex-shrink-0">
            {clothes.image_url ? (
              <img
                src={clothes.image_url}
                alt={clothes.name}
                className="w-48 h-48 object-cover rounded-lg"
              />
            ) : (
              <div className="w-48 h-48 bg-gray-200 rounded-lg flex items-center justify-center">
                <Shirt className="text-gray-400" size={48} />
              </div>
            )}
          </div>
          <div className="flex-1 space-y-4">
            <div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">{clothes.name}</h2>
              <p className="text-gray-500">{clothes.description}</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <span className="text-gray-600">分类：</span>
                <span className="font-medium text-gray-900">{clothes.category}</span>
              </div>
              <div>
                <span className="text-gray-600">颜色：</span>
                <span className="font-medium text-gray-900">{clothes.color}</span>
              </div>
              <div>
                <span className="text-gray-600">尺寸：</span>
                <span className="font-medium text-gray-900">{clothes.size}</span>
              </div>
              <div>
                <span className="text-gray-600">季节：</span>
                <span className="font-medium text-gray-900">{clothes.season}</span>
              </div>
              <div>
                <span className="text-gray-600">创建时间：</span>
                <span className="font-medium text-gray-900">{new Date(clothes.created_at).toLocaleString()}</span>
              </div>
              <div>
                <span className="text-gray-600">更新时间：</span>
                <span className="font-medium text-gray-900">{new Date(clothes.updated_at).toLocaleString()}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ClothesDetail; 
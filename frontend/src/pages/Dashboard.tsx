import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Shirt, Plus, TrendingUp, Calendar } from 'lucide-react';
import { statsApi, clothesApi } from '../services/api';
import { Stats, Clothes } from '../types';

const Dashboard = () => {
  const [stats, setStats] = useState<Stats | null>(null);
  const [recentClothes, setRecentClothes] = useState<Clothes[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [statsData, clothesData] = await Promise.all([
          statsApi.getStats(),
          clothesApi.getAll()
        ]);
        setStats(statsData);
        setRecentClothes(clothesData.slice(0, 6)); // 只显示最近6件
      } catch (error) {
        console.error('获取数据失败:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  const statCards = [
    { label: '总件数', value: stats?.total || 0, icon: Shirt, color: 'bg-blue-500' },
    { label: '上衣', value: stats?.tops || 0, icon: Shirt, color: 'bg-green-500' },
    { label: '裤子', value: stats?.pants || 0, icon: Shirt, color: 'bg-yellow-500' },
    { label: '裙子', value: stats?.dresses || 0, icon: Shirt, color: 'bg-pink-500' },
    { label: '外套', value: stats?.outerwear || 0, icon: Shirt, color: 'bg-purple-500' },
    { label: '鞋子', value: stats?.shoes || 0, icon: Shirt, color: 'bg-red-500' },
  ];

  return (
    <div className="space-y-8">
      {/* 标题和快速操作 */}
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">仪表板</h1>
        <Link
          to="/clothes/add"
          className="flex items-center space-x-2 bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors"
        >
          <Plus size={20} />
          <span>添加衣服</span>
        </Link>
      </div>

      {/* 统计卡片 */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {statCards.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white rounded-lg shadow-md p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{stat.label}</p>
                  <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                </div>
                <div className={`p-3 rounded-full ${stat.color}`}>
                  <Icon className="text-white" size={24} />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* 最近添加的衣服 */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold text-gray-900">最近添加的衣服</h2>
          <Link
            to="/clothes"
            className="text-primary-600 hover:text-primary-700 font-medium"
          >
            查看全部
          </Link>
        </div>

        {recentClothes.length === 0 ? (
          <div className="text-center py-8">
            <Shirt className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">还没有衣服</h3>
            <p className="mt-1 text-sm text-gray-500">开始添加你的第一件衣服吧！</p>
            <div className="mt-6">
              <Link
                to="/clothes/add"
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700"
              >
                <Plus className="-ml-1 mr-2 h-5 w-5" />
                添加衣服
              </Link>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {recentClothes.map((clothes) => (
              <Link
                key={clothes.id}
                to={`/clothes/${clothes.id}`}
                className="block bg-gray-50 rounded-lg p-4 hover:bg-gray-100 transition-colors"
              >
                <div className="flex items-center space-x-4">
                  {clothes.image_url ? (
                    <img
                      src={clothes.image_url}
                      alt={clothes.name}
                      className="w-16 h-16 object-cover rounded-lg"
                    />
                  ) : (
                    <div className="w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center">
                      <Shirt className="text-gray-400" size={24} />
                    </div>
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {clothes.name}
                    </p>
                    <p className="text-sm text-gray-500">{clothes.category}</p>
                    <p className="text-xs text-gray-400">{clothes.color}</p>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard; 
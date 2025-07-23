const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('uploads'));

// 文件上传配置
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueName = uuidv4() + path.extname(file.originalname);
    cb(null, uniqueName);
  }
});

const upload = multer({ storage: storage });

// 数据库初始化
const db = new sqlite3.Database('wardrobe.db', (err) => {
  if (err) {
    console.error('数据库连接失败:', err.message);
  } else {
    console.log('数据库连接成功');
    initDatabase();
  }
});

function initDatabase() {
  const createTableSQL = `
    CREATE TABLE IF NOT EXISTS clothes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      color TEXT,
      size TEXT,
      season TEXT,
      image_url TEXT,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `;
  
  db.run(createTableSQL, (err) => {
    if (err) {
      console.error('创建表失败:', err.message);
    } else {
      console.log('数据库表初始化成功');
    }
  });
}

// API路由

// 获取所有衣服
app.get('/api/clothes', (req, res) => {
  const sql = 'SELECT * FROM clothes ORDER BY created_at DESC';
  db.all(sql, [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

// 获取单个衣服
app.get('/api/clothes/:id', (req, res) => {
  const sql = 'SELECT * FROM clothes WHERE id = ?';
  db.get(sql, [req.params.id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (!row) {
      res.status(404).json({ error: '衣服不存在' });
      return;
    }
    res.json(row);
  });
});

// 添加衣服
app.post('/api/clothes', upload.single('image'), (req, res) => {
  const { name, category, color, size, season, description } = req.body;
  const image_url = req.file ? `/uploads/${req.file.filename}` : null;
  
  const sql = `
    INSERT INTO clothes (name, category, color, size, season, image_url, description)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
  
  db.run(sql, [name, category, color, size, season, image_url, description], function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({
      id: this.lastID,
      name,
      category,
      color,
      size,
      season,
      image_url,
      description
    });
  });
});

// 更新衣服
app.put('/api/clothes/:id', upload.single('image'), (req, res) => {
  const { name, category, color, size, season, description } = req.body;
  const image_url = req.file ? `/uploads/${req.file.filename}` : req.body.image_url;
  
  const sql = `
    UPDATE clothes 
    SET name = ?, category = ?, color = ?, size = ?, season = ?, image_url = ?, description = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  `;
  
  db.run(sql, [name, category, color, size, season, image_url, description, req.params.id], function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (this.changes === 0) {
      res.status(404).json({ error: '衣服不存在' });
      return;
    }
    res.json({ message: '更新成功' });
  });
});

// 删除衣服
app.delete('/api/clothes/:id', (req, res) => {
  const sql = 'DELETE FROM clothes WHERE id = ?';
  db.run(sql, [req.params.id], function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (this.changes === 0) {
      res.status(404).json({ error: '衣服不存在' });
      return;
    }
    res.json({ message: '删除成功' });
  });
});

// 按分类获取衣服
app.get('/api/clothes/category/:category', (req, res) => {
  const sql = 'SELECT * FROM clothes WHERE category = ? ORDER BY created_at DESC';
  db.all(sql, [req.params.category], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

// 搜索衣服
app.get('/api/clothes/search/:query', (req, res) => {
  const sql = `
    SELECT * FROM clothes 
    WHERE name LIKE ? OR category LIKE ? OR color LIKE ? OR description LIKE ?
    ORDER BY created_at DESC
  `;
  const query = `%${req.params.query}%`;
  db.all(sql, [query, query, query, query], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

// 获取统计信息
app.get('/api/stats', (req, res) => {
  const sql = `
    SELECT 
      COUNT(*) as total,
      COUNT(CASE WHEN category = '上衣' THEN 1 END) as tops,
      COUNT(CASE WHEN category = '裤子' THEN 1 END) as pants,
      COUNT(CASE WHEN category = '裙子' THEN 1 END) as dresses,
      COUNT(CASE WHEN category = '外套' THEN 1 END) as outerwear,
      COUNT(CASE WHEN category = '鞋子' THEN 1 END) as shoes,
      COUNT(CASE WHEN category = '配饰' THEN 1 END) as accessories
    FROM clothes
  `;
  
  db.get(sql, [], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(row);
  });
});

app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`);
}); 
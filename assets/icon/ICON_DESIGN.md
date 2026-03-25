# 馨馨星球 App 图标设计说明

## 设计理念
- **极简可爱**：符合项目定位，简洁但不失趣味
- **星球元素**：体现"馨馨星球"的产品名称
- **温暖治愈**：使用柔和的色彩，给人温暖的感觉

## 设计方案

### 方案描述
一个圆形的紫色星球图标，具有以下特征：
- **主色调**：梦幻紫 (#6C63FF) 渐变到浅紫色
- **星球环**：围绕星球的金色光环（类似土星环）
- **星星点缀**：星球表面有几个小星星闪烁
- **表情**：可爱的笑脸表情（简洁的弧线）

### 具体参数
- **尺寸**：1024x1024 px
- **背景**：透明或浅紫色渐变背景
- **主体**：圆形星球占据 70-80% 空间
- **颜色**：
  - 主色：#6C63FF (梦幻紫)
  - 辅助色：#FFD700 (金色光环)
  - 点缀色：#FFFFFF (白色星星)

### 使用工具建议
1. **在线生成**：
   - 使用 Figma、Canva 等工具
   - 搜索"planet icon"模板修改

2. **AI 生成**：
   - 使用 Midjourney、DALL-E 3 等 AI 工具
   - 提示词示例：
     ```
     A cute minimalist planet icon, purple gradient sphere with 
     golden ring, simple smiling face, small white stars, 
     flat design, app icon style, 1024x1024, soft colors
     ```

3. **手动绘制**：
   - 使用 Illustrator、Photoshop 等
   - 按照上述参数绘制

## 实施步骤

### 步骤 1：准备图标
1. 创建或下载一个 1024x1024 的 PNG 图标
2. 保存为 `app_icon.png`
3. 放置到 `assets/icon/` 目录

### 步骤 2：生成图标
```bash
cd d:\AI\JustLight\just_light
flutter pub get
flutter pub run flutter_launcher_icons
```

### 步骤 3：验证
- 运行应用查看图标是否正常显示
- 检查 Android 和 iOS 的图标尺寸是否正确

## 临时方案

如果暂时无法创建自定义图标，可以：
1. 使用现有的可爱星球 emoji (🪐) 作为临时图标
2. 使用在线工具将 emoji 转换为图标
3. 后续再替换为专业设计的图标

## 推荐图标资源

1. **免费图标库**：
   - Flaticon (https://www.flaticon.com)
   - Icons8 (https://icons8.com)
   - Feather Icons (https://feathericons.com)

2. **搜索关键词**：
   - planet icon
   - cute planet
   - space icon
   - minimalist planet

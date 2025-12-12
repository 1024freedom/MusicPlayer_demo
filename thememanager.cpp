#include "thememanager.h"

ThemeManager::ThemeManager(QObject* parent): QObject(parent), m_settings(), m_currentIndex(0), m_currentTheme() {
    setM_themes();
    initialize();
}

void ThemeManager::initialize() {
    loadSettings();
}

void ThemeManager::setM_themes() {

    m_themes.clear();

    // // 粉色主题
    // QVariantMap pinkTheme;
    // pinkTheme["name"] = "pink";
    // pinkTheme["displayName"] = "粉色";
    // pinkTheme["backgroundColor"] = "#FAF2F1";
    // pinkTheme["subBackgroundColor"] = "#F2A49B";
    // pinkTheme["clickBackgroundColor"] = "#F6867A";
    // pinkTheme["fontColor"] = "#572920";
    // pinkTheme["subColor"] = "#FAF7F6";
    // m_themes.append(pinkTheme);
    // // 深色主题
    // QVariantMap darkTheme;
    // darkTheme["name"] = "dark";
    // darkTheme["displayName"] = "深色";
    // darkTheme["backgroundColor"] = "#2D3748";
    // darkTheme["subBackgroundColor"] = "#4A5568";
    // darkTheme["clickBackgroundColor"] = "#718096";
    // darkTheme["fontColor"] = "#F7FAFC";
    // darkTheme["subColor"] = "#E2E8F0";
    // m_themes.append(darkTheme);
    // // 蓝色主题
    // QVariantMap blueTheme;
    // blueTheme["name"] = "blue";
    // blueTheme["displayName"] = "蓝色";
    // blueTheme["backgroundColor"] = "#EBF8FF";
    // blueTheme["subBackgroundColor"] = "#90CDF4";
    // blueTheme["clickBackgroundColor"] = "#4299E1";
    // blueTheme["fontColor"] = "#2D3748";
    // blueTheme["subColor"] = "#BEE3F8";
    // m_themes.append(blueTheme);
    // // 黑红主题
    // QVariantMap blackRedTheme;
    // blackRedTheme["name"] = "blackRed";
    // blackRedTheme["displayName"] = "黑红";
    // blackRedTheme["backgroundColor"] = "#0D0D0D";        // 深黑色背景
    // blackRedTheme["subBackgroundColor"] = "#1A1A1A";     // 稍浅的黑色次级背景
    // blackRedTheme["clickBackgroundColor"] = "#B30000";   // 鲜艳的红色点击背景
    // blackRedTheme["fontColor"] = "#E6E6E6";              // 浅灰色文字
    // blackRedTheme["subColor"] = "#333333";               // 深灰色辅助色
    // m_themes.append(blackRedTheme);
    // // 暗红主题
    // QVariantMap darkRedTheme;
    // darkRedTheme["name"] = "darkRed";
    // darkRedTheme["displayName"] = "暗红";
    // darkRedTheme["backgroundColor"] = "#1A0F0F";        // 带红色调的深黑
    // darkRedTheme["subBackgroundColor"] = "#2C1A1A";     // 暗红色次级背景
    // darkRedTheme["clickBackgroundColor"] = "#8B0000";   // 深红色点击背景
    // darkRedTheme["fontColor"] = "#F0E6E6";              // 浅米白色文字
    // darkRedTheme["subColor"] = "#3D2B2B";               // 棕红色辅助色;
    // m_themes.append(darkRedTheme);


    // ---------------------------------------------------------
    // 1. 标准白（网易云风格 / 默认浅色）
    // ---------------------------------------------------------
    QVariantMap lightTheme;
    lightTheme["name"] = "light";
    lightTheme["displayName"] = "经典白";

    // 背景区域
    lightTheme["windowBackgroundColor"] = "#F0F0F0";      // 整个窗口底色（侧边栏等）
    lightTheme["contentBackgroundColor"] = "#FFFFFF";     // 核心内容区（歌单列表）背景

    // 列表交互
    lightTheme["itemHoverColor"] = "#F2F2F3";             // 鼠标悬停时的背景
    lightTheme["itemSelectedColor"] = "#E3E3E5";          // 被选中/正在播放的背景
    lightTheme["alternateRowColor"] = "#FAFAFA";          // 偶数行颜色（极淡的灰色，增加条理感）

    // 文字
    lightTheme["primaryTextColor"] = "#333333";           // 主要文字（歌名），深灰接近黑
    lightTheme["secondaryTextColor"] = "#888888";         // 次要文字（歌手），浅灰
    lightTheme["disabledTextColor"] = "#CCCCCC";          // 禁用/提示文字

    // 装饰与功能
    lightTheme["dividerColor"] = "#E1E1E1";               // 分割线/边框颜色
    lightTheme["accentColor"] = "#C20C0C";                // 强调色（网易红），用于进度条、图标

    m_themes.append(lightTheme);

    // ---------------------------------------------------------
    // 2. 炫酷黑（深色模式 / 类似QQ音乐黑金）
    // ---------------------------------------------------------
    QVariantMap darkTheme;
    darkTheme["name"] = "dark";
    darkTheme["displayName"] = "炫酷黑";

    darkTheme["windowBackgroundColor"] = "#202023";       // 侧边栏深灰
    darkTheme["contentBackgroundColor"] = "#2B2B2B";      // 内容区稍亮

    darkTheme["itemHoverColor"] = "#333333";
    darkTheme["itemSelectedColor"] = "#3F3F3F";
    darkTheme["alternateRowColor"] = "#2E2E2E";           // 偶数行微调

    darkTheme["primaryTextColor"] = "#DCDCDC";            // 并不是纯白，柔和的白
    darkTheme["secondaryTextColor"] = "#858585";
    darkTheme["disabledTextColor"] = "#555555";

    darkTheme["dividerColor"] = "#363636";
    darkTheme["accentColor"] = "#1ECC94";                 // 强调色（QQ音乐绿或自定义金 #D4AF37）

    m_themes.append(darkTheme);

    // ---------------------------------------------------------
    // 3. 樱花粉（针对女性用户优化，柔和不刺眼）
    // ---------------------------------------------------------
    QVariantMap pinkTheme;
    pinkTheme["name"] = "pink";
    pinkTheme["displayName"] = "樱花粉";

    pinkTheme["windowBackgroundColor"] = "#FFF0F5";       // 薰衣草红晕
    pinkTheme["contentBackgroundColor"] = "#FFFAFA";      // 雪白略带粉

    pinkTheme["itemHoverColor"] = "#FFE4E1";
    pinkTheme["itemSelectedColor"] = "#FFD1DC";           // 明显的粉色选中态
    pinkTheme["alternateRowColor"] = "#FFF5F7";           // 极淡粉色偶数行

    pinkTheme["primaryTextColor"] = "#5E2E2E";            // 深褐红色（比黑色在粉底上更协调）
    pinkTheme["secondaryTextColor"] = "#A87676";
    pinkTheme["disabledTextColor"] = "#D1B3B3";

    pinkTheme["dividerColor"] = "#F0D9D9";
    pinkTheme["accentColor"] = "#FF69B4";                 // 亮粉色强调

    m_themes.append(pinkTheme);

    // ---------------------------------------------------------
    // 4. 清爽蓝（Win10风格 / 商务蓝）
    // ---------------------------------------------------------
    QVariantMap blueTheme;
    blueTheme["name"] = "blue";
    blueTheme["displayName"] = "清爽蓝";

    blueTheme["windowBackgroundColor"] = "#F3F9FF";
    blueTheme["contentBackgroundColor"] = "#FFFFFF";

    blueTheme["itemHoverColor"] = "#E6F2FF";
    blueTheme["itemSelectedColor"] = "#CCE5FF";
    blueTheme["alternateRowColor"] = "#F7FBFF";

    blueTheme["primaryTextColor"] = "#2C3E50";            // 深蓝灰
    blueTheme["secondaryTextColor"] = "#7F8C8D";
    blueTheme["disabledTextColor"] = "#BDC3C7";

    blueTheme["dividerColor"] = "#DDEEFF";
    blueTheme["accentColor"] = "#3498DB";                 // 标准扁平蓝

    m_themes.append(blueTheme);

    // ---------------------------------------------------------
    // 5. 电竞黑红（ROG风格 / 高对比度）
    // ---------------------------------------------------------
    QVariantMap blackRedTheme;
    blackRedTheme["name"] = "blackRed";
    blackRedTheme["displayName"] = "电竞红";

    blackRedTheme["windowBackgroundColor"] = "#121212";   // 极深灰（纯黑伤眼）
    blackRedTheme["contentBackgroundColor"] = "#1A1A1A";

    blackRedTheme["itemHoverColor"] = "#330000";          // 悬停泛红
    blackRedTheme["itemSelectedColor"] = "#5C0000";       // 选中深红
    blackRedTheme["alternateRowColor"] = "#1F1F1F";       // 偶数行

    blackRedTheme["primaryTextColor"] = "#EEEEEE";
    blackRedTheme["secondaryTextColor"] = "#999999";
    blackRedTheme["disabledTextColor"] = "#555555";

    blackRedTheme["dividerColor"] = "#333333";
    blackRedTheme["accentColor"] = "#FF0000";             // 鲜红

    m_themes.append(blackRedTheme);

    // ---------------------------------------------------------
    // 6. 暗夜酒红（低调奢华 / 类似网易云黑胶VIP）
    // ---------------------------------------------------------
    QVariantMap darkRedTheme;
    darkRedTheme["name"] = "darkRed";
    darkRedTheme["displayName"] = "暗夜红";

    darkRedTheme["windowBackgroundColor"] = "#1F1A1A";
    darkRedTheme["contentBackgroundColor"] = "#262020";

    darkRedTheme["itemHoverColor"] = "#362B2B";
    darkRedTheme["itemSelectedColor"] = "#452E2E";
    darkRedTheme["alternateRowColor"] = "#2B2424";

    darkRedTheme["primaryTextColor"] = "#E8D5D5";         // 暖白
    darkRedTheme["secondaryTextColor"] = "#8F7878";
    darkRedTheme["disabledTextColor"] = "#5C4A4A";

    darkRedTheme["dividerColor"] = "#3D3030";
    darkRedTheme["accentColor"] = "#8B0000";              // 暗红

    m_themes.append(darkRedTheme);
    // 设置当前主题
    if (!m_themes.isEmpty()) {
        m_currentTheme = m_themes.first().toMap();
    }

    emit m_themesChanged();
}

int ThemeManager::getM_currentIndex() const {
    return m_currentIndex;
}
QVariantMap ThemeManager::getM_currentTheme()const {
    return m_currentTheme;
}
QVariantList ThemeManager::getM_themes()const {
    return m_themes;
}
QVariantMap ThemeManager::getM_indexofTheme(int index) const {
    for (int i = 0; i < m_themes.size(); i++) {
        if (i == index) {
            return m_themes[i].toMap();
        }
    }
    return QVariantMap();
}

void ThemeManager::setM_currentIndex(int index) {
    if (index >= 0 && index < m_themes.size() && index != m_currentIndex) {
        m_currentIndex = index;
        m_currentTheme = m_themes[m_currentIndex].toMap();
        saveSettings();
        emit m_currentThemeChanged();
    }
}

void ThemeManager::saveSettings() {
    m_settings.setValue("Theme/currentIndex", m_currentIndex);
    m_settings.sync();//强制将配置写入，避免意外导致配置丢失
}

void ThemeManager::loadSettings() {
    int savedIndex = m_settings.value("Theme/currentIndex", 0).toInt();
    //确保索引在有效范围内
    if (savedIndex >= 0 && savedIndex < m_themes.size()) {
        m_currentIndex = savedIndex;
        m_currentTheme = m_themes[m_currentIndex].toMap();
    } else {
        m_currentIndex = 0;
        if (!m_themes.isEmpty()) {
            m_currentTheme = m_themes.first().toMap();
        }
    }
    emit m_currentThemeChanged();
}

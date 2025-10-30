#include "thememanager.h"

ThemeManager::ThemeManager(QObject* parent): QObject(parent), m_settings(), m_currentIndex(0), m_currentTheme() {
    setM_themes();
}

void ThemeManager::initialize() {
    loadSettings();
}

void ThemeManager::setM_themes() {
    m_themes.clear();
    // 粉色主题
    QVariantMap pinkTheme;
    pinkTheme["name"] = "pink";
    pinkTheme["displayName"] = "粉色";
    pinkTheme["backgroundColor"] = "#FAF2F1";
    pinkTheme["subBackgroundColor"] = "#F2A49B";
    pinkTheme["clickBackgroundColor"] = "#F6867A";
    pinkTheme["fontColor"] = "#572920";
    pinkTheme["subColor"] = "#FAF7F6";
    m_themes.append(pinkTheme);
    // 深色主题
    QVariantMap darkTheme;
    darkTheme["name"] = "dark";
    darkTheme["displayName"] = "深色";
    darkTheme["backgroundColor"] = "#2D3748";
    darkTheme["subBackgroundColor"] = "#4A5568";
    darkTheme["clickBackgroundColor"] = "#718096";
    darkTheme["fontColor"] = "#F7FAFC";
    darkTheme["subColor"] = "#E2E8F0";
    m_themes.append(darkTheme);
    // 蓝色主题
    QVariantMap blueTheme;
    blueTheme["name"] = "blue";
    blueTheme["displayName"] = "蓝色";
    blueTheme["backgroundColor"] = "#EBF8FF";
    blueTheme["subBackgroundColor"] = "#90CDF4";
    blueTheme["clickBackgroundColor"] = "#4299E1";
    blueTheme["fontColor"] = "#2D3748";
    blueTheme["subColor"] = "#BEE3F8";
    m_themes.append(blueTheme);
    // 黑红主题
    QVariantMap blackRedTheme;
    blackRedTheme["name"] = "blackRed";
    blackRedTheme["displayName"] = "黑红";
    blackRedTheme["backgroundColor"] = "#0D0D0D";        // 深黑色背景
    blackRedTheme["subBackgroundColor"] = "#1A1A1A";     // 稍浅的黑色次级背景
    blackRedTheme["clickBackgroundColor"] = "#B30000";   // 鲜艳的红色点击背景
    blackRedTheme["fontColor"] = "#E6E6E6";              // 浅灰色文字
    blackRedTheme["subColor"] = "#333333";               // 深灰色辅助色
    m_themes.append(blackRedTheme);
    // 暗红主题
    QVariantMap darkRedTheme;
    darkRedTheme["name"] = "darkRed";
    darkRedTheme["displayName"] = "暗红";
    darkRedTheme["backgroundColor"] = "#1A0F0F";        // 带红色调的深黑
    darkRedTheme["subBackgroundColor"] = "#2C1A1A";     // 暗红色次级背景
    darkRedTheme["clickBackgroundColor"] = "#8B0000";   // 深红色点击背景
    darkRedTheme["fontColor"] = "#F0E6E6";              // 浅米白色文字
    darkRedTheme["subColor"] = "#3D2B2B";               // 棕红色辅助色;
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
        emit m_currentThemeChanged(); ;
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

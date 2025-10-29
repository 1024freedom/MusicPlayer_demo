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
    pinkTheme["displayName"] = "粉色主题";
    pinkTheme["backgroundColor"] = "#FAF2F1";
    pinkTheme["subBackgroundColor"] = "#F2A49B";
    pinkTheme["clickBackgroundColor"] = "#F6867A";
    pinkTheme["fontColor"] = "#572920";
    pinkTheme["subColor"] = "#FAF7F6";
    m_themes.append(pinkTheme);

    // 深色主题
    QVariantMap darkTheme;
    darkTheme["name"] = "dark";
    darkTheme["displayName"] = "深色主题";
    darkTheme["backgroundColor"] = "#2D3748";
    darkTheme["subBackgroundColor"] = "#4A5568";
    darkTheme["clickBackgroundColor"] = "#718096";
    darkTheme["fontColor"] = "#F7FAFC";
    darkTheme["subColor"] = "#E2E8F0";
    m_themes.append(darkTheme);

    // 蓝色主题
    QVariantMap blueTheme;
    blueTheme["name"] = "blue";
    blueTheme["displayName"] = "蓝色主题";
    blueTheme["backgroundColor"] = "#EBF8FF";
    blueTheme["subBackgroundColor"] = "#90CDF4";
    blueTheme["clickBackgroundColor"] = "#4299E1";
    blueTheme["fontColor"] = "#2D3748";
    blueTheme["subColor"] = "#BEE3F8";
    m_themes.append(blueTheme);

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

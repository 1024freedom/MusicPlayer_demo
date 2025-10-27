// import QtQuick 2.15
// import QtQuick.Shapes 1.15
// import sz.window

// /**
//  * 简化版背景管理器 - Qt6 兼容版本
//  * 功能：从专辑封面提取颜色生成渐变背景
//  */
// Item {
//     id: root
//     anchors.fill: parent

//     // === 公共属性 ===
//     property url coverSource: ""  // 专辑封面源
//     property real backgroundOpacity: 0.9  // 背景不透明度
//     property int colorCount: 4    // 提取颜色数量

//     // 提取到的颜色
//     property color firstColor: "#1a1a1a"
//     property color secondColor: "#2d2d2d"

//     // 内部属性，用于跟踪上次处理的封面
//     property url _lastProcessedCover: ""



//     // === 背景渲染 - 使用 Qt6 兼容的方法 ===

//     // 渐变背景层 - 使用 Rectangle 的 gradient 属性（Qt6 推荐）
//     Rectangle {
//         id: gradientBackground
//         anchors.fill: parent
//         opacity: backgroundOpacity

//         gradient: Gradient {
//             id: backgroundGradient
//             orientation: Gradient.Horizontal

//             GradientStop {
//                 id: gradientStop1
//                 position: 0.0;
//                 color: firstColor
//             }
//             GradientStop {
//                 id: gradientStop2
//                 position: 1.0;
//                 color: secondColor
//             }
//         }

//         // 颜色过渡动画
//         Behavior on gradient {
//             enabled: false // 渐变不能直接动画，需要特殊处理
//         }
//     }

//     // 简单的模糊效果 - 使用半透明叠加层
//     Rectangle {
//         id: blurOverlay
//         anchors.fill: parent
//         color: "white"
//         opacity: 0.1  // 轻微白色叠加，模拟模糊效果
//     }

//     // === 颜色提取逻辑 ===

//     // 监听封面源变化
//     onCoverSourceChanged: {
//         if (coverSource && coverSource !== _lastProcessedCover) {
//             console.log("封面变化，开始提取颜色:", coverSource)
//             extractColorsFromCover(coverSource)
//             _lastProcessedCover = coverSource
//         }
//     }

//     /**
//      * 从专辑封面提取颜色
//      */
//     function extractColorsFromCover(coverUrl) {
//         console.log("开始提取封面颜色:", coverUrl)

//         // 创建临时图片用于分析
//         var tempImage = Qt.createQmlObject(`
//             import QtQuick 2.15
//             Image {
//                 source: "${coverUrl}"
//                 asynchronous: true
//                 visible: false
//             }
//         `, root)

//         // 等待图片加载
//         var checkStatus = function() {
//             if (tempImage.status === Image.Ready) {
//                 console.log("封面图片加载完成，开始颜色分析")
//                 // 抓取图片用于颜色分析
//                 tempImage.grabToImage(function(result) {
//                     if (result && result.image) {
//                         console.log("图片抓取成功，调用C++颜色提取")
//                         var colors = ImageColor.getMainColors(result.image)
//                         applyColorsToBackground(colors)
//                     } else {
//                         console.warn("图片抓取失败")
//                     }
//                     tempImage.destroy()
//                 }, Qt.size(200, 200))

//             } else if (tempImage.status === Image.Error) {
//                 console.warn("封面加载失败:", coverUrl)
//                 tempImage.destroy()
//                 // 使用默认颜色
//                 resetToDefaultColors()
//             } else {
//                 // 继续等待加载
//                 console.log("等待封面图片加载...")
//                 Qt.callLater(checkStatus)
//             }
//         }

//         Qt.callLater(checkStatus)
//     }

//     /**
//      * 应用颜色到背景
//      */
//     function applyColorsToBackground(colors) {
//         if (!colors || colors.length < 2) {
//             console.warn("未提取到足够颜色，使用默认颜色")
//             resetToDefaultColors()
//             return
//         }

//         console.log("成功提取到", colors.length, "个颜色")

//         // 确保颜色是有效的
//         var validColors = colors.filter(function(color) {
//             return color && color !== "undefined" && color !== "transparent"
//         })

//         if (validColors.length < 2) {
//             console.warn("有效颜色数量不足，使用默认颜色")
//             resetToDefaultColors()
//             return
//         }

//         // 按亮度排序颜色
//         var sortedColors = validColors.slice().sort(function(a, b) {
//             var lightnessA = typeof a === 'string' ? getColorLightness(a) : (a.hslLightness || 0.5)
//             var lightnessB = typeof b === 'string' ? getColorLightness(b) : (b.hslLightness || 0.5)
//             return lightnessA - lightnessB
//         })

//         // 使用中等亮度的两个颜色作为渐变
//         var color1Index = Math.floor(sortedColors.length * 0.3)
//         var color2Index = Math.floor(sortedColors.length * 0.7)

//         var color1 = sortedColors[color1Index]
//         var color2 = sortedColors[color2Index]

//         console.log("选择的颜色索引:", color1Index, color2Index)
//         console.log("颜色1:", color1, "颜色2:", color2)

//         // 更新背景渐变颜色
//         updateGradientColors(color1, color2)
//     }

//     /**
//      * 获取颜色的亮度（简单实现）
//      */
//     function getColorLightness(colorStr) {
//         // 简单的亮度计算，将颜色字符串转换为RGB并计算亮度
//         var hex = colorStr.toString().replace('#', '')
//         var r = parseInt(hex.substr(0, 2), 16) / 255
//         var g = parseInt(hex.substr(2, 2), 16) / 255
//         var b = parseInt(hex.substr(4, 2), 16) / 255
//         return (r + g + b) / 3
//     }

//     /**
//      * 更新渐变颜色
//      */
//     function updateGradientColors(color1, color2) {
//         // 直接更新渐变停止点的颜色
//         gradientStop1.color = color1
//         gradientStop2.color = color2

//         // 同时更新属性，以便外部访问
//         firstColor = color1
//         secondColor = color2

//         console.log("背景颜色已更新:", firstColor, "->", secondColor)
//     }

//     /**
//      * 重置为默认颜色
//      */
//     function resetToDefaultColors() {
//         var defaultColor1 = "#2d3748"  // 深蓝色
//         var defaultColor2 = "#4a5568"  // 中灰色
//         updateGradientColors(defaultColor1, defaultColor2)
//     }

//     /**
//      * 手动触发颜色提取
//      */
//     function updateBackground() {
//         if (coverSource) {
//             _lastProcessedCover = ""  // 重置，强制重新提取
//             extractColorsFromCover(coverSource)
//         }
//     }

//     /**
//      * 设置自定义背景颜色
//      */
//     function setCustomColors(color1, color2) {
//         updateGradientColors(color1, color2)
//     }

//     // 初始化
//     Component.onCompleted: {
//         console.log("BackgroundManager 初始化")
//         resetToDefaultColors()

//         // 如果初始就有封面，立即开始提取
//         if (coverSource) {
//             Qt.callLater(function() {
//                 extractColorsFromCover(coverSource)
//             })
//         }
//     }
// }

import QtQuick 2.15
import QtQuick.Shapes 1.15
import sz.window

/**
 * 背景管理器
 */
Item {
    id: root
    anchors.fill: parent
    
    // === 公共属性 ===
    property url coverSource: ""  // 专辑封面源
    property real backgroundOpacity: 0.9  // 背景不透明度
    property int colorCount: 4    // 提取颜色数量
    
    // 提取到的颜色
    property color firstColor: "#1a1a1a"
    property color secondColor: "#2d2d2d"
    property color thirdColor: "#2d2d2d"
    property color forthColor: "#2d2d2d"
    property color fifthColor: "#2d2d2d"
    
    // 内部属性
    property url _lastProcessedCover: ""
    property bool _extractionInProgress: false
    
    // === 背景渲染 ===
    
    Rectangle {
        id: gradientBackground
        anchors.fill: parent
        opacity: backgroundOpacity
        
        gradient: Gradient {
            id: backgroundGradient
            orientation: Gradient.Horizontal
            
            GradientStop { 
                id: gradientStop1
                position: 0.0; 
                color: firstColor
            }
            GradientStop { 
                id: gradientStop2
                position: 0.25;
                color: secondColor
            }
            GradientStop {
                id: gradientStop3
                position: 0.5;
                color: thirdColor
            }
            GradientStop {
                id: gradientStop4
                position: 0.75;
                color: forthColor
            }
            GradientStop {
                id: gradientStop5
                position: 1.0;
                color: fifthColor
            }

        }
    }
    
    // === 颜色提取逻辑 ===
    
    onCoverSourceChanged: {
        if (coverSource && coverSource !== _lastProcessedCover && !_extractionInProgress) {
            console.log("封面变化，开始提取颜色:", coverSource)
            extractColorsFromCover(coverSource)
            _lastProcessedCover = coverSource
        }
    }
    
    /**
     * 从专辑封面提取颜色
     */
    function extractColorsFromCover(coverUrl) {
        if (_extractionInProgress) {
            console.log("颜色提取正在进行中，跳过")
            return
        }
        
        _extractionInProgress = true
        console.log("开始提取封面颜色:", coverUrl)
        
        // 创建临时图片用于分析
        var tempImage = Qt.createQmlObject(`
            import QtQuick 2.15
            Image {
                source: "${coverUrl}"
                asynchronous: true
                visible: false
                cache: true
            }
        `, root)
        
        // 等待图片加载
        var checkStatus = function() {
            console.log("图片状态:", tempImage.status, "进度:", tempImage.progress)
            
            if (tempImage.status === Image.Ready) {
                console.log("封面图片加载完成")
                // 抓取图片用于颜色分析
                tempImage.grabToImage(function(result) {
                    if (result && result.image) {
                        console.log("图片抓取成功，调用C++颜色提取")
                        try {
                            // 直接调用C++函数，不传递尺寸参数
                            var colors = p_imageColor.getMainColors(result.image)
                            console.log("C++颜色提取返回:", colors)
                            applyColorsToBackground(colors)
                        } catch (error) {
                            console.error("调用C++颜色提取出错:", error)
                            resetToDefaultColors()
                        }
                    } else {
                        console.warn("图片抓取失败")
                        resetToDefaultColors()
                    }
                    tempImage.destroy()
                    _extractionInProgress = false
                }) // 移除尺寸参数，使用默认尺寸
                
            } else if (tempImage.status === Image.Error) {
                console.warn("封面加载失败:", coverUrl, "错误:", tempImage.errorString)
                tempImage.destroy()
                resetToDefaultColors()
                _extractionInProgress = false
            } else if(tempImage.status===Image.Loading&&tempImage.progress===1.0){
                //进度为1但状态仍未loading为正常情况，需要等待状态变为Ready，不然会直接跳到未知状态的处理


            } else if (tempImage.progress < 1.0) {
                // 继续等待加载
                console.log("等待封面图片加载... 进度:", tempImage.progress)
                Qt.callLater(checkStatus)
            } else {
                // 其他状态，安全处理
                console.log("图片加载未知状态，重置")
                tempImage.destroy()
                resetToDefaultColors()
                _extractionInProgress = false
            }
        }
        
        Qt.callLater(checkStatus)
    }
    
    /**
     * 应用颜色到背景
     */
    function applyColorsToBackground(colors) {
        console.log("applyColorsToBackground 被调用，参数:", colors)
        
        if (!colors) {
            console.warn("颜色数组为null或undefined")
            resetToDefaultColors()
            return
        }
        
        console.log("成功提取到", colors.length, "个颜色")
        
        if (colors.length < 2) {
            console.warn("颜色数量不足:", colors.length)
            resetToDefaultColors()
            return
        }
        
        var color1 = colors[0]
        var color2 = colors[1]
        var color3=colors[2]
        var color4=colors[3]
        var color5=colors[4]
        
        console.log("使用颜色1:", color1, "颜色2:", color2,"颜色3:", color3,"颜色4:", color4,"颜色5:", color5)
        
        // 验证颜色有效性
        if (!isValidColor(color1) || !isValidColor(color2)) {
            console.warn("颜色无效，使用默认颜色")
            resetToDefaultColors()
            return
        }
        
        // 更新背景渐变颜色
        updateGradientColors(color1, color2,color3,color4,color5)
    }
    
    /**
     * 验证颜色是否有效
     */
    function isValidColor(color) {
        if (!color) return false
        if (color === "undefined") return false
        if (color === "transparent") return false
        if (color === "null") return false
        if (typeof color !== 'string' && typeof color !== 'object') return false
        
        return true
    }
    
    /**
     * 更新渐变颜色
     */
    function updateGradientColors(color1, color2,color3,color4,color5) {
        // 确保在主线程中更新UI
        Qt.callLater(function() {
            gradientStop1.color = color1
            gradientStop2.color = color2
            gradientStop3.color = color3
            gradientStop4.color = color4
            gradientStop5.color = color5
            
            // 同时更新属性，以便外部访问
            firstColor = color1
            secondColor = color2
            thirdColor = color3
            forthColor = color4
            fifthColor = color5
            
            console.log("背景颜色成功更新:", firstColor, "->", secondColor)
        })
    }
    
    /**
     * 重置为默认颜色
     */
    function resetToDefaultColors() {
        console.log("重置为默认颜色")
        var defaultColor1 = "#2d3748"  // 深蓝色
        var defaultColor2 = "#4a5568"  // 中灰色
        updateGradientColors(defaultColor1, defaultColor2)
    }
    
    /**
     * 手动触发颜色提取
     */
    function updateBackground() {
        if (coverSource) {
            _lastProcessedCover = ""
            _extractionInProgress = false
            extractColorsFromCover(coverSource)
        }
    }
    
    // 初始化
    Component.onCompleted: {
        console.log("BackgroundManager 初始化完成")
        resetToDefaultColors()
        
        // 延迟执行，确保其他组件已初始化
        Qt.callLater(function() {
            if (coverSource) {
                console.log("初始化时检测到封面，开始提取")
                extractColorsFromCover(coverSource)
            }
        })
    }
}

import QtQuick
import QtMultimedia

MediaPlayer {

    enum PlayerMode{
        ONELOOPPLAY,//单曲循环
        LISTLOOPPLAY,//列表循环
        RANDOMPLAY,//随机播放
        LINEPLAY//顺序播放
    }
    property int playerModeCount: 4
    property int playerModeStatus: MusicPlayer.PlayerMode.LISTLOOPPLAY

    function setPlayMode(){//循环设置
        playerModeStatus=(playerModeStatus+1)%playerModeCount
    }

    onPlaybackStateChanged: {//播放状态变化（播放停止）
        if(playbackState===MediaPlayer.StoppedState&&duration===position){
            autoNextMusicPlay()
        }
    }


    autoPlay:true
    audioOutput: AudioOutput{

    }
    onSourceChanged: {
        play()
    }


    function playMusic(id,musicInfo){
        var musicUrlCallBack=res=>{
            musicInfo.url=res.url
            p_musicRes.thisPlayMusicInfo=musicInfo
            p_musicRes.thisPlayMusicInfoChanged()
        }
        p_musicRes.getMusicUrl({id,callBack:musicUrlCallBack})
    }

    function playPauseMusic(){//暂停或播放
        //没有播放源时返回
        if(source==="")return

        if(playing){
            pause()
        }else{
            play()
        }
    }
    function preMusicPlay(){//上一首
        var index=p_musicRes.thisPlayCurrent
        if(index<=0){
            return
        }
        index=(index-1)%p_musicRes.thisPlayListInfo.count
        p_musicRes.thisPlayCurrent=index
        playMusic(p_musicRes.thisPlayListInfo.get(index).id,p_musicRes.thisPlayListInfo.get(index))
    }
    function nextMusicPlay(){//下一首(顺序或随机)
        var index=p_musicRes.thisPlayCurrent

        //随机播放
        if(playerModeStatus===MusicPlayer.PlayerMode.RANDOMPLAY){
            // if(index!==p_musicRes.randomPlayCurrent){
            //     for(let i=0;i<p_musicRes.randomPlayListIndex[i].length;i++){
            //         if(index===p_musicRes.randomPlayListIndex[i]){
            //             index=i
            //             break
            //         }
            //     }
            // }
            p_musicRes.randomPlayCurrent=(index+1)%p_musicRes.randomPlayListIndex.length
            index=p_musicRes.randomPlayListIndex[p_musicRes.randomPlayCurrent]
        }else{
            index=(index+1)%p_musicRes.thisPlayListInfo.count
        }

        p_musicRes.thisPlayCurrent=index
        playMusic(p_musicRes.thisPlayListInfo.get(index).id,p_musicRes.thisPlayListInfo.get(index))
    }
    function autoNextMusicPlay(){//自动播放下一首音乐
        switch(p_musicPlayer.playerModeStatus){
        case MusicPlayer.PlayerMode.ONELOOPPLAY:
            play()
            break
        case MusicPlayer.PlayerMode.LISTLOOPPLAY:
            nextMusicPlay()
            break
        case MusicPlayer.PlayerMode.RANDOMPLAY:
            nextMusicPlay()
            break
        case MusicPlayer.PlayerMode.LINEPLAY:
            if(p_musicRes.thisPlayListInfo.count-1===p_musicRes.thisPlayCurrent){
                //当前已经是最后一首 不进行操作
            }else{
                nextMusicPlay()
            }
            break
        }
    }
}

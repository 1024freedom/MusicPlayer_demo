import QtQuick
import QtMultimedia

MediaPlayer {
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
    function nextMusicPlay(){//下一首

    }
}

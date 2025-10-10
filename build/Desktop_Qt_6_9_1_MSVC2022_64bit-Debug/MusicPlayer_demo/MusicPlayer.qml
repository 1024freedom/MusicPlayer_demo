import QtQuick
import QtMultimedia

MediaPlayer {
    audioOutput: AudioOutput{

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

    }
    function nextMusicPlay(){//下一首

    }
}

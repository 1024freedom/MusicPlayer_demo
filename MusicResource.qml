import QtQuick

Item {

    property int thisPlayCurrent: -1
    property int randomPlayCurrent: -1
    property var thisPlayMusicInfo: {
        "id":"",
        "name":"",
        "artists":"",
        "album":"",
        "coverImg":"",
        "url":"",
        "allTime":"",
    }

    property ListModel thisPlayListInfo: ListModel{

    }
    property ListModel thisPlayMusicLyric: ListModel{

    }

    //随机播放下标
    property var randomPlayListIndex:[]

    onThisPlayMusicInfoChanged: {

        console.log("播放歌曲信息"+JSON.stringify(thisPlayMusicInfo))

        var lyricCallBack=res=>{
            console.log("歌词"+JSON.stringify(res))
            thisPlayMusicLyric.clear()
            thisPlayMusicLyric.append(res)
        }
        if(thisPlayMusicInfo.id){
            getMuiscLyric({id:thisPlayMusicInfo.id,callBack:lyricCallBack})
        }
    }
    onThisPlayListInfoChanged: {
        randomPlayListIndex=Array.from({length:thisPlayListInfo.count},(_,index)=>index)//以下标生成数组并赋值
        for(let i=randomPlayListIndex.length-1;i>0;i--){//洗牌算法随机打乱数组
            const index=Math.floor(Math.random()*(i+1));//为当前i位置的元素随机生成一个前面的位置index
            [randomPlayListIndex[i],randomPlayListIndex[index]]=[randomPlayListIndex[index],randomPlayListIndex[i]]//交换
        }

        console.log(JSON.stringify(randomPlayListIndex))
    }

    function indexOf(id){//添加的歌曲是否已经存在，存在则返回下标
        if(thisPlayListInfo.count<=0){
            return -1
        }
        for(let i=0;i<thisPlayListInfo.count;i++){
            if(thisPlayListInfo.get(i).id===id){
                return i
            }
        }
        return -1
    }


    function getNewMusic(obj){//获取最新音乐

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var type=obj.type||"0"
        var callBack=obj.callBack||(()=>{})//由于XMLHttpRequest()数据获取是异步的，所以使用回调函数，避免阻塞ui或者数据异常

        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).data
                        res=res.map(obj=>{
                                    return {
                                            id:obj.id,
                                            name: obj.name,
                                            artists:obj.artists.map(ar=>ar.name).join('/'),
                                            album:obj.album.name,
                                            coverImg:obj.album.picUrl,
                                            url:"",
                                            allTime:"00:00"
                                        }
                                    })
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取最新音乐失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/top/song?type="+type,true)
            xhr.send()
        };
        makeRequest()
    }

    function parseLyric(lrc,tlrc) {
        var i = 0
        lrc = lrc.split('\n')
        tlrc = tlrc.split('\n')

        try {
            if(Array.isArray(lrc)) {

                for(i = 0; i < lrc.length;i++) {
                    if(!lrc[i]) continue
                    let t = lrc[i].match(/\[(.*?)\]\s*(.*)/)
                    let tim = t[1].split(':')
                    tim = parseInt(tim[0]) * 60*1000 + parseInt(parseFloat(tim[1])*1000)
                    lrc[i] = {tim: tim, lyric: t[2],tlrc: ""}
                }

            }
            if(Array.isArray(tlrc)) {

                for(i = 0; i < tlrc.length;i++) {
                    if(!tlrc[i]) continue
                    let t = tlrc[i].match(/\[(.*?)\]\s*(.*)/)
                    let tim = -1
                    if(!t) {
                        tlrc[i] = {tim: tim, lyric: ""}
                        continue
                    }
                    tim = t[1].split(':')
                    tim = parseInt(tim[0]) * 60*1000 + parseInt(parseFloat(tim[1])*1000)
                    tlrc[i] = {tim: tim, lyric: t[2]}
                }

            }

            if(Array.isArray(tlrc))
            for(i = 0; i < lrc.length;i++) {
                let index = tlrc.findIndex(r => lrc[i].tim === r.tim)
                if(index !== -1) {
                    lrc[i].tlrc = tlrc[index].lyric
                }
            }
        } catch(err) {
            console.log("歌词解析错误！" + err)
            for(i = 0; i < lrc.length;i++) {
               lrc[i] = { "lyric": lrc[i],"tlrc": "",tim: 0 }
            }
        }
        lrc = lrc.filter(item => item.lyric)
        return lrc
    }


    function getMuiscLyric(obj){//获取歌词

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var id=obj.id||"0"
        var callBack=obj.callBack||(()=>{})

        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText)
                        var lrc=res.lrc.lyric
                        var lyric=null
                        //特殊处理纯音乐
                        if(res.hasOwnProperty("pureMusic")){
                            console.log("纯音乐")
                            lyric=parseLyric(lrc,"")
                        }else{
                            lyric=parseLyric(lrc,res.tlyric.lyric)
                        }

                        callBack(lyric)
                    }else{
                        console.log("第"+currentRetry+"次获取歌词失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/lyric?id="+id,true)
            xhr.send()
        };

        makeRequest()


    }

    function getMusicUrl(obj){//获取音乐url

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数


        var id=obj.id||""
        var callBack=obj.callBack||(()=>{})


        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).data[0]
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取url失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/song/url?id="+id,true)
            xhr.send()
        };

        makeRequest()


    }

    function getMusicPlayList(obj){//获取歌单

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var cat=obj.cat||"全部"
        var order=obj.order||"hot"
        var limit=obj.limit||"40"
        var callBack=obj.callBack||(()=>{})//由于数据获取是异步的，所以使用回调函数

        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).playlists
                        res=res.map(obj=>{
                                    return {
                                            id:obj.id,
                                            name: obj.name,
                                            description:obj.description,
                                            coverImg:obj.coverImgUrl,
                                        }
                                    })
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取歌单失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/top/playlist?cat=" +cat+ "&limit="+limit+"&order="+order,true)
            xhr.send()
        };

        makeRequest()

    }

    function getMusicBoutiquePlayList(obj){//获取精选歌单

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var cat=obj.cat||"全部"
        var limit=obj.limit||"40"
        var callBack=obj.callBack||(()=>{})//由于数据获取是异步的，所以使用回调函数

        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).playlists
                        res=res.map(obj=>{
                                    return {
                                            id:obj.id,
                                            name: obj.name,
                                            description:obj.description,
                                            coverImg:obj.coverImgUrl.split('?')[0],
                                        }
                                    })
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取精选歌单失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/top/playlist/highquality?cat=" +cat+ "&limit="+limit,true)
            xhr.send()
        };

        makeRequest()
    }

    function getMusicPlayListDetail(obj){//获取歌单详情

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var id=obj.id||""
        var callBack=obj.callBack||(()=>{})

        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).playlist
                        res={
                            id:res.id,
                            name: res.name,
                            description:res.description,
                            coverImg:res.coverImgUrl.split('?')[0],
                            trackIds:res.trackIds.map(r=>{return r.id})
                        }
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取歌单详情失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/playlist/detail?id=" +id,true)
            xhr.send()
        };
        makeRequest()

        // while(isUnaccessable===1&&currentRetry<=retryCount){
        //     currentRetry++
        //     makeRequest()
        // }


    }

    function getMusicDetail(obj){//获取音乐详情

        var retryCount=20//重试次数
        var currentRetry=1//当前重试次数

        var ids=obj.ids||""
        var callBack=obj.callBack||(()=>{})
        function makeRequest(){
            var xhr=new XMLHttpRequest()
            xhr.onreadystatechange=function(){
                if(xhr.readyState===XMLHttpRequest.DONE){
                    if(xhr.status===200){
                        var res=JSON.parse(xhr.responseText).songs

                        res=res.map(obj=>{
                                    return {
                                            id:obj.id,
                                            name: obj.name,
                                            artists:obj.ar.map(ar=>ar.name).join('/'),
                                            album:obj.al.name,
                                            coverImg:obj.al.picUrl,
                                            url:"",
                                            allTime:setTime(obj.dt)
                                        }
                                    })
                        callBack(res)
                    }else{
                        console.log("第"+currentRetry+"次获取音乐详情失败")
                        if(currentRetry<=retryCount){
                            currentRetry++
                            makeRequest()
                        }
                    }
                }
            }
            xhr.open("GET","http://localhost:3000/song/detail?ids=" +ids,true)
            xhr.send()
        };
        makeRequest()


    }

    function setTime(time){
        var h=parseInt(time/1000/3600)
        var m=parseInt(time/1000/60)
        var s=parseInt(time/1000%60)

        h=h===0?"":h
        m=m<10?"0"+m:m
        s=s<10?"0"+s:s

        return h+(h===""?m:":"+m)+":"+s
    }



}

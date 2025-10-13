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

    //随机播放下标
    property var randomPlayListIndex:[]

    onThisPlayMusicInfoChanged: {
        console.log("播放歌曲信息"+JSON.stringify(thisPlayMusicInfo))
    }
    onThisPlayListInfoChanged: {
        randomPlayListIndex=Array.from({length:thisPlayListInfo.count},(_,index)=>index)//以下标生成数组并赋值
        for(let i=randomPlayListIndex.length-1;i>0;i--){//洗牌算法随机打乱数组
            const index=Math.floor(Math.random()*(i+1));//为当前i位置的元素随机生成一个前面的位置index
            [randomPlayListIndex[i],randomPlayListIndex[index]]=[randomPlayListIndex[index],randomPlayListIndex[i]]//交换
        }

        console.log(JSON.stringify(randomPlayListIndex))
    }

    function indexOf(id){//添加的歌曲是否已经存在
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
        var type=obj.type||"0"
        var callBack=obj.callBack||(()=>{})//由于数据获取是异步的，所以使用回调函数
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
                    console.log("获取最新音乐失败")
                }
            }
        }
        xhr.open("GET","http://localhost:3000/top/song?type="+type,true)
        xhr.send()
    }

    function getMusicUrl(obj){//获取音乐url
        var id=obj.id||""
        var callBack=obj.callBack||(()=>{})
        var xhr=new XMLHttpRequest()
        xhr.onreadystatechange=function(){
            if(xhr.readyState===XMLHttpRequest.DONE){
                if(xhr.status===200){
                    var res=JSON.parse(xhr.responseText).data[0]
                    callBack(res)
                }else{
                    console.log("获取音乐url失败")
                }
            }
        }
        xhr.open("GET","http://localhost:3000/song/url?id="+id,true)
        xhr.send()
    }

    function getMusicPlayList(obj){//获取歌单
        var cat=obj.cat||"全部"
        var order=obj.order||"hot"
        var limit=obj.limit||"40"
        var callBack=obj.callBack||(()=>{})//由于数据获取是异步的，所以使用回调函数
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
                    console.log("获取最新音乐失败")
                }
            }
        }
        xhr.open("GET","http://localhost:3000/top/playlist?cat=" +cat+ "&limit="+limit+"&order="+order,true)
        xhr.send()
    }

    function getMusicBoutiquePlayList(obj){//获取精选歌单
        var cat=obj.cat||"全部"
        var limit=obj.limit||"40"
        var callBack=obj.callBack||(()=>{})//由于数据获取是异步的，所以使用回调函数
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
                    console.log("获取最新音乐失败")
                }
            }
        }
        xhr.open("GET","http://localhost:3000/top/playlist/highquality?cat=" +cat+ "&limit="+limit,true)
        xhr.send()
    }

    function getMusicPlayListDetail(obj){//获取歌单详情
        var id=obj.id||""
        var callBack=obj.callBack||(()=>{})
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
                    console.log("获取最新音乐失败"+xhr.status)
                }
            }
        }
        xhr.open("GET","http://localhost:3000/playlist/detail?id=" +id,true)
        xhr.send()
    }

    function getMusicDetail(obj){//获取音乐详情
        var ids=obj.ids||""
        var callBack=obj.callBack||(()=>{})
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
                    console.log("获取音乐详情失败"+xhr.status)
                }
            }
        }
        xhr.open("GET","http://localhost:3000/song/detail?ids=" +ids,true)
        xhr.send()
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

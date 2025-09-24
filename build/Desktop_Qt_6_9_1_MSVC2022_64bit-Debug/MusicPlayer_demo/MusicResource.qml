import QtQuick

Item {
    function getNewMusic(obj){
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
}

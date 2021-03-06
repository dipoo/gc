namespace 歌词下载器
//默认空间

var index = 1
//初始化代码
function init()
    grid.setsize("grid", 15, 3)
endfunction

function openPathBtn_click()
    path = file.dialog(2)
    if(path != "")
        if(index > 1)
            //清空
            for(j = index; j > 0; j --)
                grid.deleterow("grid", j)
            endfor
        endif
        index = 1
        歌词下载器.list(path)
    endif
endfunction

function downloadBtn_click()
    if(index == 1)
        help.messagebox("无任务歌曲", "提示")
        return null
    endif
    thread.beginthread("歌词下载器.worker", null)
endfunction

function worker()
    for(i = 0; i < index; i ++)
        if(grid.getcontent("grid", i, 2) == "未下载")
            name = grid.getcontent("grid", i, 1)//C:\Users\dell\Desktop\music\我都记得.mp3
            realname = str.reverse(name)//3pm.得记都我\……
            
            basepath = str.strsub(realname, str.findstr(realname, "\\"), str.strleng(realname))
            basepath = str.reverse(basepath)//基本路径
            realname = str.strsub(realname, str.findstr(realname, ".") + 1, str.findstr(realname, "\\"))
            realname = str.reverse(realname)//歌曲名称
            lrcpath = basepath & realname & ".lrc" 
            source = net.urlgetnetrequest("http://www.cnlyric.com/search.php?k="&realname&"&t=s", 5) 
            调试输出(source)
            
            preffix = "><strong style=\"color:red\">"& realname &"</strong></a>"
            if(str.findstr(source, preffix) == -1)
                grid.setcontent("grid", i, 2, "没有找到")
                continue
            endif
            source = str.strsub(source,str.findstr(source, preffix),str.strleng(source))
            //下载地址
            url = "http://www.cnlyric.com/LrcDown/" & 歌词下载器.intercept(source, "&nbsp;<a href=\"LrcDown/", "\" class=\"ld\"")
            handle = file.createfile(lrcpath, "rw")
            file.writefile(handle, net.urlgetnetrequest(url, 5))
            file.closefile(handle)
			grid.setcontent("grid", i, 2, "OK")
        endif
    endfor
endfunction 

//字符串截取
function intercept(source, preffix, suffix)
    var s = str.strsub(source, str.findstr(source, preffix) + str.strleng(preffix), str.strleng(source))
    s = str.strsub(s, 0, str.findstr(s, suffix))
    return s
endfunction

//遍历歌曲文件夹
function list(path)
    folders,files
    //遍历文件夹的目录及文件
    file.traverse(path, folders, files)
    folderlen,filelen
    arraysp.size(folders, folderlen)
    arraysp.size(files, filelen)
    //遍历文件
    for(i = 0; i < filelen; i ++)
        if(str.strleng(files[i]) != 0)
            suffix = str.strsub(files[i], str.strleng(files[i]) - 4, str.strleng(files[i]))
            if(suffix == ".mp3" || suffix == ".wma")

				name = grid.getcontent("grid", i, 1)//C:\Users\dell\Desktop\music\我都记得.mp3
				realname = str.reverse(files[i])//3pm.得记都我\……
				realname = str.strsub(realname, str.findstr(realname, ".") + 1, str.strleng(realname))
				realname = str.reverse(realname)//歌曲名称
				lrcpath = path & "/" & realname & ".lrc"
                status = "未下载"
                if(file.exist(lrcpath))
                    status = "OK"
                endif
                //调试输出(files[i])
                grid.setsize("grid", index + 1, 3)
                grid.setcontent("grid", index, 0, index)
                grid.setcontent("grid", index, 1, path & "\\" & files[i])
                grid.setcontent("grid", index, 2, status)//不支持三目运算符
                index++
            endif
        endif   
    endfor
    //是否选中包含子目录
    containChildCheck = check.getstate("containChildCheck")
    if(containChildCheck)
        //遍历文件夹
        for(i = 0; i < folderlen; i ++)
            if(str.strleng(folders[i]) != 0)
                //调试输出(path&"/"&folders[i])
                歌词下载器.list(path&"/"&folders[i])
            endif    
        endfor
    endif 
endfunction

function hotkey0_onhotkey()
    歌词下载器.openPathBtn_click()
endfunction

endnamespace
//空间结束
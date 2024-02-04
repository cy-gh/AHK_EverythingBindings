#Warn All
#Warn UseUnsetLocal, Off
#Warn LocalSameAsGlobal, Off

; replacements for my private logger - you need DbgView.exe for OutputDebug (see AHK manual)
join(sep, params*) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}
$dbg(str*) {
    OutputDebug, % join(" ", str*)
}
$log(str*) {
    OutputDebug, % join(" ", str*)
}

; constants from SDK Everything.h

EVERYTHING_OK										    := 0 ; no error detected
EVERYTHING_ERROR_MEMORY								    := 1 ; out of memory.
EVERYTHING_ERROR_IPC								    := 2 ; Everything search client is not running
EVERYTHING_ERROR_REGISTERCLASSEX					    := 3 ; unable to register window class.
EVERYTHING_ERROR_CREATEWINDOW						    := 4 ; unable to create listening window
EVERYTHING_ERROR_CREATETHREAD						    := 5 ; unable to create listening thread
EVERYTHING_ERROR_INVALIDINDEX						    := 6 ; invalid index
EVERYTHING_ERROR_INVALIDCALL						    := 7 ; invalid call
EVERYTHING_ERROR_INVALIDREQUEST						    := 8 ; invalid request data, request data first.
EVERYTHING_ERROR_INVALIDPARAMETER					    := 9 ; bad parameter.
EVERYTHING_SORT_NAME_ASCENDING						    := 1
EVERYTHING_SORT_NAME_DESCENDING						    := 2
EVERYTHING_SORT_PATH_ASCENDING						    := 3
EVERYTHING_SORT_PATH_DESCENDING						    := 4
EVERYTHING_SORT_SIZE_ASCENDING						    := 5
EVERYTHING_SORT_SIZE_DESCENDING						    := 6
EVERYTHING_SORT_EXTENSION_ASCENDING					    := 7
EVERYTHING_SORT_EXTENSION_DESCENDING				    := 8
EVERYTHING_SORT_TYPE_NAME_ASCENDING					    := 9
EVERYTHING_SORT_TYPE_NAME_DESCENDING				    := 10
EVERYTHING_SORT_DATE_CREATED_ASCENDING				    := 11
EVERYTHING_SORT_DATE_CREATED_DESCENDING				    := 12
EVERYTHING_SORT_DATE_MODIFIED_ASCENDING				    := 13
EVERYTHING_SORT_DATE_MODIFIED_DESCENDING			    := 14
EVERYTHING_SORT_ATTRIBUTES_ASCENDING				    := 15
EVERYTHING_SORT_ATTRIBUTES_DESCENDING				    := 16
EVERYTHING_SORT_FILE_LIST_FILENAME_ASCENDING		    := 17
EVERYTHING_SORT_FILE_LIST_FILENAME_DESCENDING		    := 18
EVERYTHING_SORT_RUN_COUNT_ASCENDING					    := 19
EVERYTHING_SORT_RUN_COUNT_DESCENDING				    := 20
EVERYTHING_SORT_DATE_RECENTLY_CHANGED_ASCENDING		    := 21
EVERYTHING_SORT_DATE_RECENTLY_CHANGED_DESCENDING	    := 22
EVERYTHING_SORT_DATE_ACCESSED_ASCENDING				    := 23
EVERYTHING_SORT_DATE_ACCESSED_DESCENDING			    := 24
EVERYTHING_SORT_DATE_RUN_ASCENDING					    := 25
EVERYTHING_SORT_DATE_RUN_DESCENDING					    := 26

EVERYTHING_REQUEST_FILE_NAME						    := 0x00000001
EVERYTHING_REQUEST_PATH								    := 0x00000002
EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME			    := 0x00000004
EVERYTHING_REQUEST_EXTENSION						    := 0x00000008
EVERYTHING_REQUEST_SIZE								    := 0x00000010
EVERYTHING_REQUEST_DATE_CREATED						    := 0x00000020
EVERYTHING_REQUEST_DATE_MODIFIED					    := 0x00000040
EVERYTHING_REQUEST_DATE_ACCESSED					    := 0x00000080
EVERYTHING_REQUEST_ATTRIBUTES						    := 0x00000100
EVERYTHING_REQUEST_FILE_LIST_FILE_NAME				    := 0x00000200
EVERYTHING_REQUEST_RUN_COUNT						    := 0x00000400
EVERYTHING_REQUEST_DATE_RUN							    := 0x00000800
EVERYTHING_REQUEST_DATE_RECENTLY_CHANGED			    := 0x00001000
EVERYTHING_REQUEST_HIGHLIGHTED_FILE_NAME			    := 0x00002000
EVERYTHING_REQUEST_HIGHLIGHTED_PATH					    := 0x00004000
EVERYTHING_REQUEST_HIGHLIGHTED_FULL_PATH_AND_FILE_NAME	:= 0x00008000

_EVERYTHING_REQUEST_ALL                                 := EVERYTHING_REQUEST_FILE_NAME | EVERYTHING_REQUEST_PATH | EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME | EVERYTHING_REQUEST_EXTENSION | EVERYTHING_REQUEST_SIZE | EVERYTHING_REQUEST_DATE_CREATED | EVERYTHING_REQUEST_DATE_MODIFIED | EVERYTHING_REQUEST_DATE_ACCESSED | EVERYTHING_REQUEST_ATTRIBUTES | EVERYTHING_REQUEST_FILE_LIST_FILE_NAME | EVERYTHING_REQUEST_RUN_COUNT | EVERYTHING_REQUEST_DATE_RUN | EVERYTHING_REQUEST_DATE_RECENTLY_CHANGED | EVERYTHING_REQUEST_HIGHLIGHTED_FILE_NAME | EVERYTHING_REQUEST_HIGHLIGHTED_PATH | EVERYTHING_REQUEST_HIGHLIGHTED_FULL_PATH_AND_FILE_NAME

EVERYTHING_TARGET_MACHINE_X86						    := 1
EVERYTHING_TARGET_MACHINE_X64						    := 2
EVERYTHING_TARGET_MACHINE_ARM						    := 3

; https://docs.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
FILE_ATTRIBUTE_READONLY                 := 0x1
FILE_ATTRIBUTE_HIDDEN                   := 0x2
FILE_ATTRIBUTE_SYSTEM                   := 0x4
FILE_ATTRIBUTE_DIRECTORY                := 0x10
FILE_ATTRIBUTE_ARCHIVE                  := 0x20
FILE_ATTRIBUTE_DEVICE                   := 0x40
FILE_ATTRIBUTE_NORMAL                   := 0x80
FILE_ATTRIBUTE_TEMPORARY                := 0x100
FILE_ATTRIBUTE_SPARSE_FILE              := 0x200
FILE_ATTRIBUTE_REPARSE_POINT            := 0x400
FILE_ATTRIBUTE_COMPRESSED               := 0x800
FILE_ATTRIBUTE_OFFLINE                  := 0x1000
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED      := 0x2000
FILE_ATTRIBUTE_ENCRYPTED                := 0x4000
FILE_ATTRIBUTE_INTEGRITY_STREAM         := 0x8000
FILE_ATTRIBUTE_VIRTUAL                  := 0x10000
FILE_ATTRIBUTE_NO_SCRUB_DATA            := 0x20000
FILE_ATTRIBUTE_RECALL_ON_OPEN           := 0x40000
FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS    := 0x400000

INVALID_FILE_ATTRIBUTES                 := 0xffffffff


class cAHK_ES {

    Static MAX_PATH_LEN := 260

    __New(dll_path) {
        this.evdllpath := dll_path
        $dbg("evdllpath: " evdllpath)
        DllCall("LoadLibrary", "str", this.evdllpath)
        this.last_query_num_results := 0
        this.request_flags := EVERYTHING_REQUEST_FILE_NAME | EVERYTHING_REQUEST_PATH ; same defaults as SDK
    }

    __Delete() {
        this.Cleanup()
    }

    Cleanup() {
        DllCall(this.evdllpath . "\Everything_CleanUp")
    }

    Reset() {
        DllCall(this.evdllpath . "\Everything_Reset")
    }

    GetVersion() {
        res_Everything_GetMajorVersion  := DllCall(this.evdllpath . "\Everything_GetMajorVersion", "uint")
        res_Everything_GetMinorVersion  := DllCall(this.evdllpath . "\Everything_GetMinorVersion", "uint")
        res_Everything_GetRevision      := DllCall(this.evdllpath . "\Everything_GetRevision", "uint")
        res_Everything_GetBuildNumber   := DllCall(this.evdllpath . "\Everything_GetBuildNumber", "uint")
        version := res_Everything_GetMajorVersion "." res_Everything_GetMinorVersion "." res_Everything_GetRevision " build " res_Everything_GetBuildNumber
        $dbg("version", version)
        return version
    }

    SetSearch(pSearchString) {
        res := DllCall(this.evdllpath . "\Everything_SetSearch", "str", pSearchString)
        $dbg(A_ThisFunc, "res: " res)
        this.last_query_num_results := 0
    }

    GetSearch() {
        res := DllCall(this.evdllpath . "\Everything_GetSearch", "str")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetRequestFlags(pFlags) {
        res_Everything_SetRequestFlags := DllCall(this.evdllpath . "\Everything_SetRequestFlags", "uint", pFlags)
        ; res := DllCall(this.evdllpath . "\Everything_SetRequestFlags", "uint", EVERYTHING_REQUEST_FILE_NAME | EVERYTHING_REQUEST_PATH | EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME)
        $dbg(A_ThisFunc, "res: " res)
        this.request_flags := pFlags
    }

    GetRequestFlags() {
        res := DllCall(this.evdllpath . "\Everything_GetRequestFlags", "int")
        $dbg(A_ThisFunc, "res: " res)
        ; return res
        return format("0x{:X}", res) ; return as hex string
    }

    SetRegex(pBool) {
        res := DllCall(this.evdllpath . "\Everything_SetRegex", "int", pBool)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetRegex() {
        res := DllCall(this.evdllpath . "\Everything_GetRegex", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetMatchPath(pBool) {
        res := DllCall(this.evdllpath . "\Everything_SetMatchPath", "int", pBool)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetMatchPath() {
        res := DllCall(this.evdllpath . "\Everything_SetMatchPath", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetMatchCase(pBool) {
        res := DllCall(this.evdllpath . "\Everything_SetMatchCase", "int", pBool)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetMatchCase() {
        res := DllCall(this.evdllpath . "\Everything_GetMatchCase", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetMatchWholeWord(pBool) {
        res := DllCall(this.evdllpath . "\Everything_SetMatchWholeWord", "int", pBool)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetMatchWholeWord() {
        res := DllCall(this.evdllpath . "\Everything_GetMatchWholeWord", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetMax(pNumber) {
        res := DllCall(this.evdllpath . "\Everything_SetMax", "uint", pNumber)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetMax() {
        res := DllCall(this.evdllpath . "\Everything_GetMax", "uint")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    SetSort(pSortFlags) {
        res := DllCall(this.evdllpath . "\Everything_SetSort", "int", pSortFlags)
        $dbg(A_ThisFunc, "res: " res)
    }

    GetSort() {
        res := DllCall(this.evdllpath . "\Everything_GetSort", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    Query(pBoolWait := true) {
        res := DllCall(this.evdllpath . "\Everything_Query", "int", pBoolWait, "int") ; 1 means true
        $log(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
    }

    GetLastError() {
        res := DllCall(this.evdllpath . "\Everything_GetLastError", "int", 1, "int") ; 1 means true
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetNumFileResults() {
        res := DllCall(this.evdllpath . "\Everything_GetNumFileResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetNumFolderResults() {
        res := DllCall(this.evdllpath . "\Everything_GetNumFolderResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetNumResults() {
        res := DllCall(this.evdllpath . "\Everything_GetNumResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetTotFileResults() {
        res := DllCall(this.evdllpath . "\Everything_GetTotFileResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetTotFolderResults() {
        res := DllCall(this.evdllpath . "\Everything_GetTotFolderResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetTotResults() {
        res := DllCall(this.evdllpath . "\Everything_GetTotResults", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    IsVolumeResult(pResultIndex) {
        res := DllCall(this.evdllpath . "\Everything_IsVolumeResult", "uint64", pResultIndex, "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    IsFolderResult(pResultIndex) {
        res := DllCall(this.evdllpath . "\Everything_IsFolderResult", "uint64", pResultIndex, "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    IsFileResult(pResultIndex) {
        res := DllCall(this.evdllpath . "\Everything_IsFileResult", "uint64", pResultIndex, "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetResultFileName(pResultIndex) {
        res_Everything_GetResultFileName := DllCall(this.evdllpath . "\Everything_GetResultFileName", "uint64", pResultIndex, "ptr")
        if (!res_Everything_GetResultFileName) {
            $dbg("error: " DllCall(this.evdllpath . "\Everything_GetLastError", "int", 1, "int"))
        }
        file_nameonly := StrGet(res_Everything_GetResultFileName)
        $dbg("index: " pResultIndex, "res_Everything_GetResultFileName: " res_Everything_GetResultFileName, "file_nameonly: " file_nameonly)
        return file_nameonly
    }

    GetResultPath(pResultIndex) {
        res_Everything_GetResultPath := DllCall(this.evdllpath . "\Everything_GetResultPath", "uint64", pResultIndex, "ptr")
        if (!res_Everything_GetResultPath) {
            $dbg("error: " DllCall(this.evdllpath . "\Everything_GetLastError", "int", 1, "int"))
        }
        file_pathonly := StrGet(res_Everything_GetResultPath)
        $dbg("index: " pResultIndex, "res_Everything_GetResultPath: " res_Everything_GetResultPath, "file_pathonly: " file_pathonly)
        return file_pathonly
    }

    GetResultFullPathName(pResultIndex) {
        VarSetCapacity(file_fullpath, cAHK_ES.MAX_PATH_LEN, 0)
        res_Everything_GetResultFullPathName := DllCall(this.evdllpath . "\Everything_GetResultFullPathName", "uint64", pResultIndex, "str", file_fullpath, "uint", cAHK_ES.MAX_PATH_LEN, "uint")
        $dbg("index: " pResultIndex, "res_Everything_GetResultFullPathName: " res_Everything_GetResultFullPathName, "file_fullpath: " file_fullpath)
        ; $log(file_fullpath " --> " file_nameonly "  \  " file_pathonly)
        ; FileAppend, % file_fullpath . "`n", * ; send to stdout
        ; output_str .= file_fullpath "`n"
        return file_fullpath
    }

    Exit() {
        res := DllCall(this.evdllpath . "\Everything_Exit", "int")
        $dbg(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return res
    }
    IsDBLoaded() {
        res := DllCall(this.evdllpath . "\Everything_IsDBLoaded", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    IsAdmin() {
        res := DllCall(this.evdllpath . "\Everything_IsAdmin", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    IsAppData() {
        res := DllCall(this.evdllpath . "\Everything_IsAppData", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    RebuildDB() {
        res := DllCall(this.evdllpath . "\Everything_RebuildDB", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    UpdateAllFolderIndexes() {
        res := DllCall(this.evdllpath . "\Everything_UpdateAllFolderIndexes", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    SaveDB() {
        res := DllCall(this.evdllpath . "\Everything_SaveDB", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    SaveRunHistory() {
        res := DllCall(this.evdllpath . "\Everything_SaveRunHistory", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    DeleteRunHistory() {
        res := DllCall(this.evdllpath . "\Everything_DeleteRunHistory", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    GetTargetMachine() {
        ; see EVERYTHING_TARGET_MACHINE_* constants
        res := DllCall(this.evdllpath . "\Everything_GetTargetMachine", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return res
    }
    IsFastSort() {
        res := DllCall(this.evdllpath . "\Everything_IsFastSort", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    IsFileInfoIndexed() {
        res := DllCall(this.evdllpath . "\Everything_IsFileInfoIndexed", "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    GetRunCountFromFileName(pFileFullPath) {
        res := DllCall(this.evdllpath . "\Everything_GetRunCountFromFileNameW", "str", pFileFullPath, "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    SetRunCountFromFileName(pFileFullPath, pCount) {
        res := DllCall(this.evdllpath . "\Everything_SetRunCountFromFileNameW", "str", pFileFullPath, "uint64", pCount, "int")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    IncRunCountFromFileName(pFileFullPath) {
        res := DllCall(this.evdllpath . "\Everything_IncRunCountFromFileNameW", "str", pFileFullPath, "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }

    GetResultListSort() {
        res := DllCall(this.evdllpath . "\Everything_GetResultListSort", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    GetResultListRequestFlags() {
        res := DllCall(this.evdllpath . "\Everything_GetResultListRequestFlags", "uint64")
        $dbg(A_ThisFunc, "res: " res)
        return res
    }
    GetResultExtension(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_EXTENSION flag to be set
        res := DllCall(this.evdllpath . "\Everything_GetResultExtension", "uint64", pResultIndex, "str")
        $dbg(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return res
    }
    GetResultSize(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_SIZE flag to be set
        VarSetCapacity(file_size, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultSize", "uint64", pResultIndex, "uint64", &file_size, "int")
        $dbg(A_ThisFunc, "res: " res, "file_size: " NumGet(file_size))
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_size)
    }
    GetResultDateCreated(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_DATE_CREATED flag to be set
        VarSetCapacity(file_date, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultDateCreated", "uint64", pResultIndex, "uint64", &file_date, "int")
        $dbg(A_ThisFunc, "res: " res, "file_date: " NumGet(file_date))
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_date)
    }
    GetResultDateModified(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_DATE_MODIFIED flag to be set
        VarSetCapacity(file_date, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultDateModified", "uint64", pResultIndex, "uint64", &file_date, "int")
        $dbg(A_ThisFunc, "res: " res, "file_date: " NumGet(file_date))
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_date)
    }
    GetResultDateAccessed(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_DATE_ACCESSED flag to be set
        VarSetCapacity(file_date, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultDateAccessed", "uint64", pResultIndex, "uint64", &file_date, "int")
        $dbg(A_ThisFunc, "res: " res, "file_date: " NumGet(file_date))
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_date)
    }
    GetResultAttributes(pResultIndex) {
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_ATTRIBUTES flag to be set
        res := DllCall(this.evdllpath . "\Everything_GetResultAttributes", "uint64", pResultIndex, "uint64")
        ; if(!res || res == INVALID_FILE_ATTRIBUTES) {
        if(res == INVALID_FILE_ATTRIBUTES) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        $dbg(A_ThisFunc, "res: " res)
        ; return res
        return format("0x{:X}", res) ; return as hex string
    }
    GetResultFileListFileName(pResultIndex) {
        ; COULD NOT GET THIS ONE WORKING :/
        ; TODO check flags first
        ; this method requires EVERYTHING_REQUEST_FILE_LIST_FILE_NAME flag to be set
        res := DllCall(this.evdllpath . "\Everything_GetResultFileListFileName", "uint64", pResultIndex)
        $dbg(A_ThisFunc, "res: " StrGet(res))
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return res
        ; return StrGet(res)
    }
    GetResultRunCount(pResultIndex) {
        res := DllCall(this.evdllpath . "\Everything_GetResultRunCount", "uint54", pResultIndex, "uint64")
        $dbg(A_ThisFunc, "res: " res)
        if(res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        } else {
            res := 0
        }
        return res
    }
    GetResultDateRun(pResultIndex) {
        VarSetCapacity(file_date_run, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultDateRun", "uint64", pResultIndex, "uint64", &file_date_run, "uint")
        $dbg(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_date_run)
    }
    GetResultDateRecentlyChanged(pResultIndex) {
        VarSetCapacity(file_date_recently_changed, 8, 0) ; 8 bytes / 64 bit
        res := DllCall(this.evdllpath . "\Everything_GetResultDateRecentlyChanged", "uint64", pResultIndex, "uint64", &file_date_recently_changed, "uint")
        $dbg(A_ThisFunc, "res: " res)
        if(!res) {
            $log(A_ThisFunc, "error: " this.GetLastError())
        }
        return NumGet(file_date_recently_changed)
    }

    _ConvertWinFiletimeToUnixEpochTimestamp(pNumber) {
        ; http://fileformats.archiveteam.org/wiki/Windows_FILETIME
        ; https://stackoverflow.com/a/39493333
        ; WINDOWS_TICKS = int(1/10**-7)  # 10,000,000 (100 nanoseconds or .1 microseconds)
        ; WINDOWS_EPOCH = datetime.datetime.strptime('1601-01-01 00:00:00',
        ;                                         '%Y-%m-%d %H:%M:%S')
        ; POSIX_EPOCH = datetime.datetime.strptime('1970-01-01 00:00:00',
        ;                                         '%Y-%m-%d %H:%M:%S')
        ; EPOCH_DIFF = (POSIX_EPOCH - WINDOWS_EPOCH).total_seconds()  # 11644473600.0
        ; WINDOWS_TICKS_TO_POSIX_EPOCH = EPOCH_DIFF * WINDOWS_TICKS  # 116444736000000000.0
        ;
        ; the magic numbers here are: 116444736000000000 & 10**7
        ; get the result from e.g. Everything_GetResultDateModified, subtract 116444736000000000, divide by 10**7, and round to get a posix epoch
        converted := Round((pNumber - 116444736000000000) / 10**7)
        ; $log("big nums", pNumber, 116444736000000000, pNumber - 116444736000000000, 10**7, converted)
        return converted
    }

}


;
; unfortunately there is no built-in method to convert unix timestamps to local times incl. DST conversion
; and I am too lazy to code one
;
; for whatever it's worth, here are some I tried,
; none takes DST into account and deliver wrong results if DST was active at the time of the timestamp
;
; GetUnixTimestamp(){
;     NowUTC := A_NowUTC
;     NowUTC -= 19700101000000, S
;     return NowUTC
; }
; UnixToUTC(unixTime){
; 	time := 1970
; 	time += unixTime, s
; 	return time
; }
;
; UTC2Local(pTime) {
;     diff := A_Now
;     diff -= A_NowUTC, h
;     ; $log("A_Now: " A_Now, "A_NowUTC: " A_NowUTC, diff)
;     pTime += diff, h
;     return pTime
; }
;
; ConvertTS2LocalTime(pTime) {
;     ; return UnixToUTC(pTime)
;     ; from https://www.autohotkey.com/boards/viewtopic.php?p=359577#p359577
;     diff := A_Now
;     diff -= A_NowUTC, h
;     time := 1970
;     time += pTime, s
;     time += diff, h
;     return time
; }
; FormatToISOLike(pTime) {
;     FormatTime, formatted, % pTime, yyyyMMdd-HHmmss
;     return formatted
; }
;

#Warn All
#Persistent
#NoEnv
#SingleInstance, "Force"
#MaxThreads 100
#HotkeyInterval 20 ; default 2000
#MaxHotkeysPerInterval 20000 ; default 70
#MenuMaskKey vk07
#UseHook
; ListLines Off
; CoordMode Tooltip, Screen
; CoordMode, Mouse, Screen
; SetCapsLockState, AlwaysOff
; OnExit(ObjBindMethod(cScheduler, "ExitHandler"))
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%


#Include cAHK_ES.ahk



ts_start := A_TickCount

oEV := new cAHK_ES(A_ScriptDir . "\Everything64.dll")
$log("version: " oEV.GetVersion())

$log("target machine: " oEV.GetTargetMachine())


oEV.SetSearch("abcdef")
$log("search: " oEV.GetSearch())

; oEV.SetRequestFlags(EVERYTHING_REQUEST_FILE_NAME | EVERYTHING_REQUEST_PATH | EVERYTHING_REQUEST_EXTENSION | EVERYTHING_REQUEST_RUN_COUNT | EVERYTHING_REQUEST_DATE_RUN | EVERYTHING_REQUEST_DATE_RECENTLY_CHANGED | EVERYTHING_REQUEST_SIZE | EVERYTHING_REQUEST_DATE_CREATED | EVERYTHING_REQUEST_DATE_MODIFIED | EVERYTHING_REQUEST_DATE_ACCESSED | EVERYTHING_REQUEST_FILE_LIST_FILE_NAME | EVERYTHING_REQUEST_ATTRIBUTES | EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME)
oEV.SetRequestFlags(_EVERYTHING_REQUEST_ALL)
$log("flags: " oEV.GetRequestFlags())

oEV.SetRegex(true)
; $log("regex: " oEV.GetRegex())
oEV.SetMatchPath(false)
; $log("matchpath: " oEV.GetMatchPath())
oEV.SetMatchCase(false)
; $log("matchcase: " oEV.GetMatchCase())


; $log("max before: " oEV.GetMax())
; oEV.SetMax(100)
; $log("max: " oEV.GetMax())

; $log("sort before: " oEV.GetSort())
; oEV.SetSort(EVERYTHING_SORT_DATE_MODIFIED_DESCENDING)
; $log("sort: " oEV.GetSort())

oEV.Query(true)
num_results := oEV.GetNumResults()
$log("num results: " num_results)
tot_results := oEV.GetTotResults()
$log("tot results: " tot_results)


file_nameonly := file_pathonly := file_fullpath := ""
output_str := ""
loop, % num_results {
    file_fullpath := oEV.GetResultFullPathName(A_Index - 1)
    $log("full [" A_Index - 1 "]: " file_fullpath)

    file_nameonly := oEV.GetResultFileName(A_Index - 1)
    $log("name [" A_Index - 1 "]: " file_nameonly)

    file_ext := oEV.GetResultExtension(A_Index - 1)
    $log("file_ext: " file_ext)

    file_pathonly := oEV.GetResultPath(A_Index - 1)
    $log("path [" A_Index - 1 "]: " file_pathonly)

    run_count := oEV.GetRunCountFromFileName(file_fullpath)
    $log("run count: " run_count)
    ; if (run_count > 0) {
    ;     oEV.SetRunCountFromFileName(file_fullpath, run_count + 1)
    ; }

    ; file_size := oEV.GetResultSize(A_Index - 1)
    ; $log("file_size: " file_size)

    ; file_date_c := oEV.GetResultDateCreated(A_Index - 1)
    ; $log("file_date created: " file_date_c)

    ; file_date_m := oEV.GetResultDateModified(A_Index - 1)
    ; $log("file_date modified: " file_date_m)

    ; file_date_a := oEV.GetResultDateAccessed(A_Index - 1)
    ; $log("file_date accessed: " file_date_a)

    ; file_attr := oEV.GetResultAttributes(A_Index - 1)
    ; $log("file_attr: " file_attr)

    ; file_list_file_name := oEV.GetResultFileListFileName(A_Index - 1)
    ; $log("file_list_file_name: " file_list_file_name)

    file_result_run_count := oEV.GetResultRunCount(A_Index - 1)
    $log("file_result_run_count: " file_result_run_count)

    ; file_result_date_run := oEV.GetResultDateRun(A_Index - 1)
    ; $log("file_result_date_run: " file_result_date_run)

    ; file_result_date_changed := oEV.GetResultDateRecentlyChanged(A_Index - 1)
    ; $log("file_result_date_changed: " file_result_date_changed)

    ; file_fullpath_constructed := file_pathonly "\" file_nameonly
    ; $log(file_fullpath_constructed " --> " file_nameonly "  \  " file_pathonly)
    ; FileAppend, % file_fullpath_constructed . "`n", * ; send to stdout
    ; output_str .= file_fullpath_constructed "`n"
}


oEV.Cleanup()

ts_finish := A_TickCount
$log("Elapsed: " (ts_finish - ts_start) " ms")
ExitApp

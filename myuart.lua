module(..., package.seeall)
require"mqttOutMsg"
require"mqttInMsg"
require"common"
require "utils"
require "pm"

-- 串口的序号，本次测试程序用的是第一个串口，ID数值为1
local UART_ID = 1

-- sending为true表示发送中，串口暂停接收，false则可以接收
--local sending=false

local signLabel=nil
local checkNum=4
local labelTable={}

-- 串口定时处理数据，每100毫秒处理一次数据。一旦收到的新的数据立刻发送回去
local function taskRead()
    --等待mqtt连接的建立
    sys.waitUntil("mqtt_ok")
    log.info("====================mqtt_ok======================")
    collectorOnline("connc_msg")
    log.info("====================mqtt_connect_suc======================")
    --local dataBuffer = ""
    while true do
        -- --阻塞接收
        -- 设置读取到结束符或者阻塞时发送数据
        local receiveData = uart.read(UART_ID, "*l")
        if not sys.waitUntil("UART_RECEIVE", 100) then
            --串口完整数据检测
            if string.len(receiveData)==13 and string.sub(receiveData,1,4)==string.char(0xff,0xff,0xff,0xff) then
                --开始解析卡号
                nextpox1,val1,val2=pack.unpack(string.sub(receiveData,5,8),">L")
                idStr=tostring(val1)
                --休息5s
                if checkNum==5 then
                    --去重,集中发送
                    checkNum=0
                    signLabel=nil
                    sendLabelTable={}
                    for key,val in pairs(labelTable) do
                        sendLabelTable[val]=true
                    end
                    local sendJson="["
                    for key,val in pairs(sendLabelTable) do
                        sendJson=sendJson.."{\"deviceID\":\""..key.."\"},"
                    end
                    sendJson=string.sub(sendJson, 1, -2)
                    sendJson=sendJson.."]"
                    log.info(sendJson)
                    mqttWrite(sendJson)
                    log.info("====have a rest==============")
                    --sys.wait(10000)
                end
                if signLabel==nil then
                    signLabel=idStr
                else
                    if string.find(idStr,signLabel) then
                        checkNum=checkNum+1
                    end
                end
                --mqttWrite(idStr)
                table.insert(labelTable, idStr)
            end
        end
    end
end



function collectorOnline(data)
    -- local flag=true
    -- while flag do
    --     flag=mqttTask.mqttClient:publish("collectorConnect", data, 0)
    -- end
    mqttOutMsg.insertMsg("collectorConnect",data,0,{cb=collectorOnlineCb})
end

-- 函数名：wrire
-- 功能：串口写数据
-- 参数：data为需要发出的数据
-- 返回值：无
function write(data)
    uart.write(UART_ID, data)
end

function mqttWrite(data)
    --返回显示
    --uart.write(UART_ID, data)
    --使用mqtt发送数据
    --uart.write(UART_ID, mqttOutMsg.temp)
    mqttOutMsg.insertMsg("deviceMessage",data,0,{cb=deviceMessageCb})
end

-- 保持文件处于唤醒状态
pm.wake("UsartTY")
-- 注册接收数据
uart.on(UART_ID, "receive", function()
    sys.publish("UART_RECEIVE")
end)
-- 串口配置
uart.setup(UART_ID, 115200, 8, uart.PAR_NONE, uart.STOP_1)
-- 启动串口接收数据任务
sys.taskInit(taskRead)

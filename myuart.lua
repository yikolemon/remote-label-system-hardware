-- 作者：杨亮
-- 日期：2021年4月15日
-- 程序功能：串口测试
-- 测试功能：自发自收数据
module(..., package.seeall)
require"mqttOutMsg"
require "utils"
require "pm"

-- 串口的序号，本次测试程序用的是第一个串口，ID数值为1
local UART_ID = 1
-- 串口定时处理数据，每100毫秒处理一次数据。一旦收到的新的数据立刻发送回去
local function taskRead()
    local dataBuffer = ""
    local frameCnt = 0
    while true do
        -- 设置读取到结束符或者阻塞时发送数据
        local receiveData = uart.read(UART_ID, "*l")
        -- 如果没有收到数据
        if receiveData == "" then
            if not sys.waitUntil("UART_RECEIVE", 100) then
                -- 判断现在的数据是否为空
                -- 数据不为空
                if dataBuffer:len() > 0 then
                    mqttWrite(dataBuffer)
                    dataBuffer = ""
                end
            end
        else
            dataBuffer = dataBuffer .. receiveData
        end
    end
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
    uart.write(UART_ID, data)
    --使用mqtt发送数据
    --uart.write(UART_ID, mqttOutMsg.temp)
    mqttOutMsg.insertMsg("/qos0topic",data,0,{cb=pubQos0TestCb})
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

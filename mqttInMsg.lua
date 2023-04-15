--- 模块功能：MQTT客户端数据接收处理


module(...,package.seeall)

--- MQTT客户端数据接收处理
-- @param mqttClient，MQTT客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage mqttInMsg.proc(mqttClient)

connectStatus=false

function proc(mqttClient)
    local result,data
    while true do
        result,data = mqttClient:receive(60000,"APP_SOCKET_SEND_DATA")
        --接收到数据
        if result then
            log.info("mqttInMsg.proc",data.topic,string.toHex(data.payload))
            -- --TODO：根据需求自行处理data.payload
            -- local tjsondata, res, errinfo =json.decode(data.payload)
            -- local resId=tjsondata["collectorID"]
            -- local resCode=2000
            -- --json无法解析数字
            -- if string.find(data.payload,"1000")~=nil then
            --     resCode=1000
            -- else
            --     resCode=2000
            -- end
            -- log.info("============================")
            -- log.info(string.find(data.payload,"1000"))
            -- log.info(data.payload)
            -- log.info(resId)
            -- log.info(resCode)
            -- log.info("============================")
            -- if resId == misc.getImei() then
            --     if resCode == 1000 and connectStatus==false then
            --         log.info("==================status ok=============")
            --         sys.publish("status_ok")
            --         connectStatus=true
            --     end
            -- end
        else
            break
        end
    end

    return result or data=="timeout" or data=="APP_SOCKET_SEND_DATA"
end

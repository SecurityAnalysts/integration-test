*** Settings ***
Documentation     Deep icmp traffic inspection.
...               Nodes are located on the same VM in different subnets and are members of the same EPG.
Suite Setup       Start Connections
Suite Teardown    Close Connections
Library           SSHLibrary
Resource          ../../../../../libraries/GBP/OpenFlowUtils.robot
Resource          ../Variables.robot
Resource          ../Connections.robot

*** Variables ***

*** Test Cases ***
Ping Once from h35_2 to h36_2
    [Documentation]    Test icmp request.
    Set Test Variables    client_name=h35_2    client_ip=10.0.35.2    server_name=h36_2    server_ip=10.0.36.2    ether_type=0x0800    proto=1
    Switch Connection    GPSFC1_CONNECTION
    Ping from Docker    ${CLIENT_NAME}    ${SERVER_IP}

Start Endless Ping from h35_2 to h36_2
    [Documentation]    Starting of endless pinging for traffic inspection.
    Start Endless Ping from Docker    ${CLIENT_NAME}    ${SERVER_IP}

Find ICMP Req from h35_2 to h36_2 on GBPSFC6
    [Documentation]    Inspecting icmp req on GBPSFC1.
    Switch Connection    GPSFC1_CONNECTION
    ${flow}    Inspect Classifier Outbound    in_port=4    out_port=6    eth_type=${ETHER_TYPE}    inner_src_ip=${CLIENT_IP}    inner_dst_ip=${SERVER_IP}
    ...    proto=${PROTO}

Find ICMP Resp from h36_2 to h35_2 on GBPSFC6
    [Documentation]    Inspecting icmp resp on GBPSFC1.
    Switch Connection    GPSFC1_CONNECTION
    ${flow}    Inspect Classifier Outbound    in_port=6    out_port=4    eth_type=${ETHER_TYPE}    inner_src_ip=${SERVER_IP}    inner_dst_ip=${CLIENT_IP}
    ...    proto=${PROTO}

Stop Endless Ping from h35_2 to h36_2
    [Documentation]    Stoping of endless pinging after traffic inspection finishes.
    Switch Connection    GPSFC1_CONNECTION
    Stop Endless Ping from Docker to Address    ${CLIENT_NAME}    ${SERVER_IP}

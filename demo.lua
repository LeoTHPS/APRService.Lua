require('APRService');

local function OnConnect()
	print('OnConnect');
end
local function OnDisconnect()
	print('OnDisconnect');
end
local function OnAuthenticate(message, success, verified)
	print('OnAuthenticate', 'Message: '..message, 'Success: '..(success and 'true' or 'false'), 'Verified: '..(verified and 'true' or 'false'));
end
local function OnReceivePacketGPS(packet)
	print('OnReceivePacketGPS', 'NMEA: '..packet:GetNMEA(), 'Comment: '..(packet:GetComment() or ''));
end
local function OnReceivePacketItem(packet)
	print('OnReceivePacketItem', 'Alive: '..(packet:IsAlive() and 'true' or 'false'), 'Compressed: '..(packet:IsCompressed() and 'true' or 'false'), 'Name: '..packet:GetName(), 'Comment: '..packet:GetComment(), 'Position: '..packet:GetPosition());
end
local function OnReceivePacketObject(packet)
	print('OnReceivePacketObject', 'Alive: '..(packet:IsAlive() and 'true' or 'false'), 'Compressed: '..(packet:IsCompressed() and 'true' or 'false'), 'Name: '..packet:GetName(), 'Comment: '..packet:GetComment(), 'Position: '..packet:GetPosition());
end
local function OnReceivePacketStatus(packet)
	local time        = packet:GetTime();
	local time_type   = time and time:GetType() or nil;
	local time_string = time or nil;

	if time then
		if time_type == APRS.TIME_HMS then
			time_string = string.format('%u:%02u:%02u', time:GetHMS());
		elseif time_type == APRS.TIME_DHM then
			time_string = string.format('%u %u:%02u', time:GetDHM());
		elseif time_type == APRS.TIME_MDHM then
			time_string = string.format('%u/%u %u:%02u', time:GetMDHM());
		end
	end

	print('OnReceivePacketStatus', 'Time: '..(time_string or ''), 'Message: '..packet:GetMessage());
end
local function OnReceivePacketMessage(packet)
	print('OnReceivePacketMessage', 'ID: '..(packet:GetID() or ''), 'Type: '..packet:GetType(), 'Content: '..packet:GetContent(), 'Destination: '..packet:GetDestination());
end
local function OnReceivePacketWeather(packet)
	print('OnReceivePacketWeather'); -- TODO: implement
end
local function OnReceivePacketPosition(packet)
	print('OnReceivePacketPosition'); -- TODO: implement
end
local function OnReceivePacketTelemetry(packet)
	print('OnReceivePacketTelemetry'); -- TODO: implement
end
local function OnReceivePacketThirdParty(packet)
	print('OnReceivePacketThirdParty', 'Content: '..packet:GetContent());
end
local function OnReceivePacketUserDefined(packet)
	print('OnReceivePacketUserDefined', 'ID: '..packet:GetID(), 'Data: '..packet:GetData(), 'Type: '..packet:GetType());
end
local function OnReceivePacket(packet)
	print('OnReceivePacket', 'Raw: '..packet:ToString());

	local packet_type = packet:GetType();

	if packet_type == APRS.PACKET_TYPE_GPS then
		OnReceivePacketGPS(packet:ToGPS());
	elseif packet_type == APRS.PACKET_TYPE_ITEM then
		OnReceivePacketItem(packet:ToItem());
	elseif packet_type == APRS.PACKET_TYPE_OBJECT then
		OnReceivePacketObject(packet:ToObject());
	elseif packet_type == APRS.PACKET_TYPE_STATUS then
		OnReceivePacketStatus(packet:ToStatus());
	elseif packet_type == APRS.PACKET_TYPE_MESSAGE then
		OnReceivePacketMessage(packet:ToMessage());
	elseif packet_type == APRS.PACKET_TYPE_WEATHER then
		OnReceivePacketWeather(packet:ToWeather());
	elseif packet_type == APRS.PACKET_TYPE_POSITION then
		OnReceivePacketPosition(packet:ToPosition());
	elseif packet_type == APRS.PACKET_TYPE_TELEMETRY then
		OnReceivePacketTelemetry(packet:ToTelemetry());
	elseif packet_type == APRS.PACKET_TYPE_THIRD_PARTY then
		OnReceivePacketThirdParty(packet:ToThirdParty());
	elseif packet_type == APRS.PACKET_TYPE_USER_DEFINED then
		OnReceivePacketUserDefined(packet:ToUserDefined());
	end
end
local function OnReceiveMessage(packet, sender, destination, content)
	print('OnReceiveMessage', 'Sender: '..sender, 'Destination: '..destination, 'Content: '..content);
end
local function OnReceiveServerMessage(message)
	print('OnReceiveServerMessage', 'Message: '..message);
end
local function OnEvent(event)
	local type = event:GetType();

	if type == APRService.EVENT_CONNECT then
		OnConnect(event:GetConnect());
	elseif type == APRService.EVENT_DISCONNECT then
		OnDisconnect(event:GetDisconnect());
	elseif type == APRService.EVENT_AUTHENTICATE then
		OnAuthenticate(event:GetAuthenticate());
	elseif type == APRService.EVENT_RECEIVE_PACKET then
		OnReceivePacket(event:GetReceivePacket());
	elseif type == APRService.EVENT_RECEIVE_MESSAGE then
		OnReceiveMessage(event:GetReceiveMessage());
	elseif type == APRService.EVENT_RECEIVE_SERVER_MESSAGE then
		OnReceiveServerMessage(event:GetReceiveServerMessage());
	end
end

local service = APRService.Init('N0CALL', 'WIDE1-1', '/', 'l');

if service then
	service:EnableMonitoring(true);
	service:SetDefaultEventHandler(OnEvent);

	while service:Poll() do
		if service:IsConnected() then
			service:WaitForIO();
		else
			service:ConnectAprsIs('noam.aprs2.net', 14580, 0);
		end
	end
end

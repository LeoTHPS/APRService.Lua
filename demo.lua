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
local function OnReceivePacket(packet)
	local packet_type = packet:GetType();

	if packet_type == APRS.PACKET_TYPE_GPS then
		print('OnReceivePacketGPS', 'NMEA: '..packet:GetGpsNMEA(), 'Comment: '..(packet:GetGpsComment() or ''));
	elseif packet_type == APRS.PACKET_TYPE_RAW then
		print('OnReceivePacket', packet:ToString());
	elseif packet_type == APRS.PACKET_TYPE_ITEM then
		print('OnReceivePacketItem', 'Alive: '..(packet:IsItemAlive() and 'true' or 'false'), 'Name: '..packet:GetItemName(), 'Comment: '..packet:GetItemComment(), 'Position: '..packet:GetItemPosition());
	elseif packet_type == APRS.PACKET_TYPE_TEST then
		print('OnReceivePacketTest'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_QUERY then
		print('OnReceivePacketQuery'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_OBJECT then
		print('OnReceivePacketObject', 'Alive: '..(packet:IsObjectAlive() and 'true' or 'false'), 'Name: '..packet:GetObjectName(), 'Comment: '..packet:GetObjectComment(), 'Position: '..packet:GetObjectPosition());
	elseif packet_type == APRS.PACKET_TYPE_STATUS then
		local time        = packet:GetStatusTime();
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

		print('OnReceivePacketStatus', 'Time: '..(time_string or ''), 'Message: '..packet:GetStatusMessage());
	elseif packet_type == APRS.PACKET_TYPE_MESSAGE then
		print('OnReceivePacketMessage', 'ID: '..(packet:GetMessageID() or ''), 'Type: '..packet:GetMessageType(), 'Content: '..packet:GetMessageContent(), 'Destination: '..packet:GetMessageDestination());
	elseif packet_type == APRS.PACKET_TYPE_WEATHER then
		print('OnReceivePacketWeather'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_POSITION then
		print('OnReceivePacketPosition'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_TELEMETRY then
		print('OnReceivePacketTelemetry'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_MAP_FEATURE then
		print('OnReceivePacketMapFeature'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_GRID_BEACON then
		print('OnReceivePacketGridBeacon'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_THIRD_PARTY then
		print('OnReceivePacketThirdParty', 'Content: '..packet:GetThirdPartyContent());
	elseif packet_type == APRS.PACKET_TYPE_MICROFINDER then
		print('OnReceivePacketMicrofinder'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_USER_DEFINED then
		print('OnReceivePacketUserDefined', 'ID: '..packet:GetUserDefinedID(), 'Data: '..packet:GetUserDefinedData(), 'Type: '..packet:GetUserDefinedType());
	elseif packet_type == APRS.PACKET_TYPE_SHELTER_TIME then
		print('OnReceivePacketShelterTime'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_STATION_CAPABILITIES then
		print('OnReceivePacketStationCapabilities'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_MAIDENHEAD_GRID_BEACON then
		print('OnReceivePacketMaidenheadGridBeacon'); -- TODO: implement
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

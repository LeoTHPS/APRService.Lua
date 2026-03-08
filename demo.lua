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
		print('OnReceivePacketGPS', packet:GetGpsNMEA(), packet:GetGpsComment());
	elseif packet_type == APRS.PACKET_TYPE_RAW then
		print('OnReceivePacket', packet:ToString());
	elseif packet_type == APRS.PACKET_TYPE_ITEM then
		print('OnReceivePacketItem', packet:IsItemAlive(), packet:GetItemName(), packet:GetItemComment(), packet:GetItemPosition());
	elseif packet_type == APRS.PACKET_TYPE_TEST then
		print('OnReceivePacketTest'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_QUERY then
		print('OnReceivePacketQuery'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_OBJECT then
		print('OnReceivePacketObject', packet:IsObjectAlive(), packet:GetObjectName(), packet:GetObjectComment(), packet:GetObjectPosition());
	elseif packet_type == APRS.PACKET_TYPE_STATUS then
		print('OnReceivePacketStatus', packet:GetStatusTime(), packet:GetStatusMessage());
	elseif packet_type == APRS.PACKET_TYPE_MESSAGE then
		print('OnReceivePacketMessage', packet:GetMessageID(), packet:GetMessageType(), packet:GetMessageContent(), packet:GetMessageDestination());
	elseif packet_type == APRS.PACKET_TYPE_WEATHER then
		print('OnReceivePacketWeather', packet:GetWeatherTime(), packet:GetWeatherType(), packet:GetWeatherSoftware(), packet:GetWeatherWindSpeed(), packet:GetWeatherWindSpeedGust(), packet:GetWeatherWindDirection(), packet:GetWeatherRainfallLastHour(), packet:GetWeatherRainfallLast24Hours(), packet:GetWeatherRainfallSinceMidnight(), packet:GetWeatherHumidity(), packet:GetWeatherTemperature(), packet:GetWeatherBarometricPressure());
	elseif packet_type == APRS.PACKET_TYPE_POSITION then
		print('OnReceivePacketPosition', packet:IsPositionMicE(), packet:IsPositionCompressed(), packet:IsPositionMessagingEnabled(), packet:GetPosition(), packet:GetPositionTime(), packet:GetPositionFlags(), packet:GetPositionSymbol(), packet:GetPositionComment(), packet:GetPositionMicEComment());
	elseif packet_type == APRS.PACKET_TYPE_TELEMETRY then
		print('OnReceivePacketTelemetry', packet:GetTelemetryType(), packet:GetTelemetryBits(), packet:GetTelemetryEqns(), packet:GetTelemetryUnits(), packet:GetTelemetryParams(), packet:GetTelemetryAnalog(), packet:GetTelemetryAnalogFloat(), packet:GetTelemetryComment(), packet:GetTelemetryDigital(), packet:GetTelemetrySequence());
	elseif packet_type == APRS.PACKET_TYPE_MAP_FEATURE then
		print('OnReceivePacketMapFeature'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_GRID_BEACON then
		print('OnReceivePacketGridBeacon'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_THIRD_PARTY then
		print('OnReceivePacketThirdParty', packet:GetThirdPartyContent());
	elseif packet_type == APRS.PACKET_TYPE_MICROFINDER then
		print('OnReceivePacketMicrofinder'); -- TODO: implement
	elseif packet_type == APRS.PACKET_TYPE_USER_DEFINED then
		print('OnReceivePacketUserDefined', packet:GetUserDefinedID(), packet:GetUserDefinedData(), packet:GetUserDefinedType());
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

-- collectgarbage('param', 'pause', 100);
-- collectgarbage('param', 'stepmul', 200);

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

		-- collectgarbage();
	end
end

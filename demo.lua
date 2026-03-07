require('APRService');

local function OnConnect()
	print('OnConnect');
end
local function OnDisconnect()
	print('OnDisconnect');
end
local function OnAuthenticate(message, success, verified)
	print('OnAuthenticate', message, success, verified);
end
local function OnReceivePacket(packet)
	print('OnReceivePacket', packet:ToString());
end
local function OnReceiveMessage(packet, sender, destination, content)
	print('OnReceiveMessage', sender, destination, content);
end
local function OnReceiveServerMessage(message)
	print('OnReceiveServerMessage', message);
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

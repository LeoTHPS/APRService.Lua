require('APRService');

local service = APRService.Init('N0CALL', 'WIDE1-1', '/', 'l');

if service then
	service:EnableMonitoring(true);

	service:SetDefaultEventHandler(function(event)
		local type = event:GetType();

		if type == APRService.EVENT_CONNECT then
			print('Connected');
		elseif type == APRService.EVENT_DISCONNECT then
			print('Disconnected');
		elseif type == APRService.EVENT_AUTHENTICATE then
			local message, success, verified = event:GetAuthenticate();

			print('Authenticate', message, success, verified);
		elseif type == APRService.EVENT_RECEIVE_PACKET then
			local packet = event:GetReceivePacket();

			print('Receive Packet', packet:ToString());
		elseif type == APRService.EVENT_RECEIVE_MESSAGE then
			local packet, sender, content, destination = event:GetReceiveMessage();

			print('Receive Message', sender, destination, content);
		elseif type == APRService.EVENT_RECEIVE_SERVER_MESSAGE then
			local content = event:GetReceiveServerMessage();

			print('Receive Server Message', content);
		end
	end);

	while service:Poll() do
		if service:IsConnected() then
			service:WaitForIO();
		else
			service:ConnectAprsIs('noam.aprs2.net', 14580, 0);
		end
	end
end

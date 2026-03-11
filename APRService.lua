require('APRS');

APRService                                   = {};

APRService.EVENT_CONNECT                     = APRSERVICE_EVENT_CONNECT;
APRService.EVENT_DISCONNECT                  = APRSERVICE_EVENT_DISCONNECT;
APRService.EVENT_AUTHENTICATE                = APRSERVICE_EVENT_AUTHENTICATE;
APRService.EVENT_RECEIVE_PACKET              = APRSERVICE_EVENT_RECEIVE_PACKET;
APRService.EVENT_RECEIVE_MESSAGE             = APRSERVICE_EVENT_RECEIVE_MESSAGE;
APRService.EVENT_RECEIVE_SERVER_MESSAGE      = APRSERVICE_EVENT_RECEIVE_SERVER_MESSAGE;

APRService.MESSAGE_ERROR_SUCCESS             = APRSERVICE_MESSAGE_ERROR_SUCCESS;
APRService.MESSAGE_ERROR_TIMEOUT             = APRSERVICE_MESSAGE_ERROR_TIMEOUT;
APRService.MESSAGE_ERROR_REJECTED            = APRSERVICE_MESSAGE_ERROR_REJECTED;
APRService.MESSAGE_ERROR_DISCONNECTED        = APRSERVICE_MESSAGE_ERROR_DISCONNECTED;

APRService.POSITION_TYPE_MIC_E               = APRSERVICE_POSITION_TYPE_MIC_E;
APRService.POSITION_TYPE_POSITION            = APRSERVICE_POSITION_TYPE_POSITION;
APRService.POSITION_TYPE_POSITION_COMPRESSED = APRSERVICE_POSITION_TYPE_POSITION_COMPRESSED;

-- @return event
local function APRService_Event_Init(handle)
	if not handle then
		return nil;
	end

	local event  = {};
	event.Handle = handle;

	function event:GetType()
		local value = aprservice_event_information_get_type(self.Handle);

		return tonumber(value);
	end

	function event:GetConnect()
		local type = aprservice_event_information_get_connect(self.Handle);

		if type ~= APRService.EVENT_CONNECT then
			return nil;
		end
	end
	function event:GetDisconnect()
		local type = aprservice_event_information_get_disconnect(self.Handle);

		if type ~= APRService.EVENT_DISCONNECT then
			return nil;
		end
	end
	-- @return message, success, verified
	function event:GetAuthenticate()
		local type, message, success, verified = aprservice_event_information_get_authenticate(self.Handle);

		if type ~= APRService.EVENT_AUTHENTICATE then
			return nil;
		end

		return tostring(message), success and true or false, verified and true or false;
	end
	-- @return packet
	function event:GetReceivePacket()
		local type, packet = aprservice_event_information_get_receive_packet(self.Handle);

		if type ~= APRService.EVENT_RECEIVE_PACKET then
			return nil;
		end

		return APRS.Packet.InitFromHandle(packet, true, false);
	end
	-- @return packet, sender, content, destination
	function event:GetReceiveMessage()
		local type, packet, sender, content, destination = aprservice_event_information_get_receive_message(self.Handle);

		if type ~= APRService.EVENT_RECEIVE_MESSAGE then
			return nil;
		end

		return APRS.Packet.InitFromHandle(packet, true, false), tostring(sender), tostring(content), tostring(destination);
	end
	-- @return content
	function event:GetReceiveServerMessage()
		local type, content = aprservice_event_information_get_receive_server_message(self.Handle);

		if type ~= APRService.EVENT_RECEIVE_SERVER_MESSAGE then
			return nil;
		end

		return tostring(content);
	end

	return event;
end

-- @param path can be string or path
-- @return aprservice
function APRService.Init(station, path, symbol_table, symbol_table_key)
	local service_path = aprs_path_init_from_string(path);

	if not service_path then
		return nil;
	end

	local service_handle = aprservice_init(station, service_path, symbol_table, symbol_table_key);

	if not service_handle then
		aprs_path_deinit(service_path);

		return nil;
	end

	aprs_path_deinit(service_path);

	local service  = {};
	service.Handle = service_handle;

	setmetatable(service, {
		__gc = function(self)
			aprservice_deinit(self.Handle);
		end
	});

	function service:IsReadOnly()
		return aprservice_is_read_only(self.Handle) and true or false;
	end
	function service:IsConnected()
		return aprservice_is_connected(self.Handle) and true or false;
	end
	function service:IsAuthenticated()
		return aprservice_is_authenticated(self.Handle) and true or false;
	end
	function service:IsAuthenticating()
		return aprservice_is_authenticating(self.Handle) and true or false;
	end
	function service:IsMonitoringEnabled()
		return aprservice_is_monitoring_enabled(self.Handle) and true or false;
	end
	function service:IsCompressionEnabled()
		return aprservice_is_compression_enabled(self.Handle) and true or false;
	end

	function service:GetPath()
		local handle = aprservice_get_path(self.Handle);

		return APRS.Path.InitFromHandle(handle, true, false);
	end
	function service:GetTime()
		local handle = aprservice_get_time(self.Handle);

		return APRS.Time.FromHandle(handle);
	end
	-- @return symbol_table, symbol_table_key
	function service:GetSymbol()
		local symbol_table     = aprservice_get_symbol_table(self.Handle);
		local symbol_table_key = aprservice_get_symbol_table_key(self.Handle);

		return tostring(symbol_table), tostring(symbol_table_key);
	end
	function service:GetComment()
		local value = aprservice_get_comment(self.Handle);

		return tostring(value);
	end
	function service:GetStation()
		local value = aprservice_get_station(self.Handle);

		return tostring(value);
	end
	-- @return type, latitude, longitude, altitude, speed, course
	function service:GetPosition()
		local latitude, longitude, altitude, speed, course = aprservice_get_position(self.Handle);
		local type                                         = aprservice_get_position_type(self.Handle);

		return tonumber(type), tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
	end
	-- @return seconds
	function service:GetConnectionTimeout()
		local value = aprservice_get_connection_timeout(self.Handle);

		return tonumber(value);
	end
	function service:GetEventHandler(event)
		return aprservice_get_event_handler(self.Handle, event);
	end
	function service:GetDefaultEventHandler()
		return aprservice_get_default_event_handler(self.Handle);
	end

	-- @param value can be string or path
	function service:SetPath(value)
		local value_type = type(value);

		if value_type == "string" then
			local path = aprs_path_init_from_string(value);

			if path then
				local success = aprservice_set_path(self.Handle, path);

				aprs_path_deinit(path);

				if success then
					return true;
				end
			end
		elseif value_type == "table" then
			return aprservice_set_path(self.Handle, value.Handle) and true or false;
		end

		return false;
	end
	function service:SetSymbol(table, key)
		return aprservice_set_symbol(self.Handle, table, key) and true or false;
	end
	function service:SetComment(value)
		return aprservice_set_comment(value) and true or false;
	end
	function service:SetPosition(latitude, longitude, altitude, speed, course)
		return aprservice_set_position(self.Handle, latitude, longitude, altitude, speed, course) and true or false;
	end
	function service:SetPositionType(value)
		return aprservice_set_position_type(self.Handle, value) and true or false;
	end
	-- @param handler(...)
	function service:SetEventHandler(event, handler)
		local function detour(event)
			local e = APRService_Event_Init(event);

			if e ~= nil then
				local e_type = e:GetType();

				if e_type == APRService.EVENT_CONNECT then
					handler(e:GetConnect());
				elseif e_type == APRService.EVENT_DISCONNECT then
					handler(e:GetDisconnect());
				elseif e_type == APRService.EVENT_AUTHENTICATE then
					handler(e:GetAuthenticate());
				elseif e_type == APRService.EVENT_RECEIVE_PACKET then
					handler(e:GetReceivePacket());
				elseif e_type == APRService.EVENT_RECEIVE_MESSAGE then
					handler(e:GetReceiveMessage());
				elseif e_type == APRService.EVENT_RECEIVE_SERVER_MESSAGE then
					handler(e:GetReceiveServerMessage());
				end
			end
		end

		return aprservice_set_event_handler(self.Handle, event, detour) and true or false;
	end
	-- @param handler(event)
	function service:SetDefaultEventHandler(handler)
		local function detour(event)
			handler(APRService_Event_Init(event));
		end

		return aprservice_set_default_event_handler(self.Handle, detour) and true or false;
	end
	function service:SetConnectionTimeout(seconds)
		aprservice_set_connection_timeout(self.Handle, seconds);
	end

	function service:EnableMonitoring(value)
		aprservice_enable_monitoring(self.Handle, value);
	end

	function service:Poll()
		return aprservice_poll(self.Handle) and true or false;
	end

	function service:Send(packet)
		return aprservice_send(self.Handle, packet.Handle) and true or false;
	end
	function service:SendRaw(content)
		return aprservice_send_raw(self.Handle, content) and true or false;
	end
	function service:SendItem(name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course, live)
		return aprservice_send_item(self.Handle, name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course, live) and true or false;
	end
	function service:SendObject(name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course, live)
		return aprservice_send_object(self.Handle, name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course, live) and true or false;
	end
	function service:SendStatus(message)
		return aprservice_send_status(self.Handle, message) and true or false;
	end
	-- @param callback(error)
	function service:SendMessage(destination, content, timeout, callback)
		return aprservice_send_message(self.Handle, destination, content, timeout, callback) and true or false;
	end
	-- @param callback(error)
	function service:SendMessageEx(destination, content, id, timeout, callback)
		return aprservice_send_message_ex(self.Handle, destination, content, id, timeout, callback) and true or false;
	end
	function service:SendWeather(wind_speed, wind_speed_gust, wind_direction, rainfall_last_hour, rainfall_last_24_hours, rainfall_since_midnight, humidity, temperature, barometric_pressure, type, software)
		return aprservice_send_weather(self.Handle, wind_speed, wind_speed_gust, wind_direction, rainfall_last_hour, rainfall_last_24_hours, rainfall_since_midnight, humidity, temperature, barometric_pressure, type, software) and true or false;
	end
	function service:SendPosition()
		return aprservice_send_position(self.Handle) and true or false;
	end
	function service:SendPositionEx(latitude, longitude, altitude, speed, course, comment)
		return aprservice_send_position_ex(self.Handle, latitude, longitude, altitude, speed, course, comment) and true or false;
	end
	function service:SendTelemetry(a1, a2, a3, a4, a5, digital)
		return aprservice_send_telemetry(self.Handle, a1, a2, a3, a4, a5, digital) and true or false;
	end
	function service:SendTelemetryEx(a1, a2, a3, a4, a5, digital, comment, sequence)
		return aprservice_send_telemetry_ex(self.Handle, a1, a2, a3, a4, a5, digital, comment, sequence) and true or false;
	end
	function service:SendTelemetryFloat(a1, a2, a3, a4, a5, digital)
		return aprservice_send_telemetry_float(self.Handle, a1, a2, a3, a4, a5, digital) and true or false;
	end
	function service:SendTelemetryFloatEx(a1, a2, a3, a4, a5, digital, comment, sequence)
		return aprservice_send_telemetry_float_ex(self.Handle, a1, a2, a3, a4, a5, digital, comment, sequence) and true or false;
	end
	function service:SendUserDefined(id, type, data)
		return aprservice_send_user_defined(self.Handle, id, type, data) and true or false;
	end
	function service:SendThirdParty(content)
		return aprservice_send_third_party(self.Handle, content) and true or false;
	end

	function service:ConnectAprsIs(hostname, port, passcode)
		return aprservice_connect_aprs_is(self.Handle, hostname, port, passcode) and true or false;
	end
	function service:ConnectKissTncTcp(hostname, port)
		return aprservice_connect_kiss_tnc_tcp(self.Handle, hostname, port) and true or false;
	end
	function service:ConnectKissTncSerial(device, speed)
		return aprservice_connect_kiss_tnc_serial(self.Handle, device, speed) and true or false;
	end
	function service:Disconnect()
		aprservice_disconnect(self.Handle);
	end

	function service:WaitForIO()
		return aprservice_wait_for_io(self.Handle) and true or false;
	end

	-- @return item
	function service:CreateItem(name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course)
		local item_handle = aprservice_item_create(self.Handle, name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course);

		if not item_handle then
			return nil;
		end

		local item  = {};
		item.Handle = item_handle;

		setmetatable(item, {
			__gc = function(self)
				aprservice_item_destroy(self.Handle);
			end
		});

		function item:IsAlive()
			return aprservice_item_is_alive(self.Handle) and true or false;
		end
		function item:IsCompressed()
			return aprservice_item_is_compressed(self.Handle) and true or false;
		end

		function item:GetName()
			local value = aprservice_item_get_name(self.Handle);

			return tostring(value);
		end
		-- @return symbol_table, symbol_table_key
		function item:GetSymbol()
			local symbol_table     = aprservice_item_get_symbol_table(self.Handle);
			local symbol_table_key = aprservice_item_get_symbol_table_key(self.Handle);

			return tostring(symbol_table), tostring(symbol_table_key);
		end
		function item:GetComment()
			local value = aprservice_item_get_comment(self.Handle);

			return tostring(value);
		end
		-- @return latitude, longitude, altitude, speed, course
		function item:GetPosition()
			local speed     = aprservice_item_get_speed(self.Handle);
			local course    = aprservice_item_get_course(self.Handle);
			local altitude  = aprservice_item_get_altitude(self.Handle);
			local latitude  = aprservice_item_get_latitude(self.Handle);
			local longitude = aprservice_item_get_longitude(self.Handle);

			return tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
		end

		function item:SetSymbol(table, key)
			return aprservice_item_set_symbol(self.Handle, table, key) and true or false;
		end
		function item:SetComment(value)
			return aprservice_item_set_comment(self.Handle, value) and true or false;
		end
		function item:SetPosition(latitude, longitude, altitude, speed, course)
			return aprservice_item_set_position(self.Handle, latitude, longitude, altitude, speed, course) and true or false;
		end
		function item:SetCompressed(value)
			return aprservice_item_set_compressed(self.Handle, value) and true or false;
		end

		function item:Kill()
			return aprservice_item_kill(self.Handle) and true or false;
		end
		function item:Announce()
			return aprservice_item_announce(self.Handle) and true or false;
		end

		return item;
	end
	-- @return object
	function service:CreateObject(name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course)
		local object_handle = aprservice_object_create(self.Handle, name, comment, symbol_table, symbol_table_key, latitude, longitude, altitude, speed, course);

		if not object_handle then
			return nil;
		end

		local object  = {};
		object.Handle = object_handle;

		setmetatable(object, {
			__gc = function(self)
				aprservice_object_destroy(self.Handle);
			end
		});

		function object:IsAlive()
			return aprservice_object_is_alive(self.Handle) and true or false;
		end
		function object:IsCompressed()
			return aprservice_object_is_compressed(self.Handle) and true or false;
		end

		function object:GetName()
			local value = aprservice_object_get_name(self.Handle);

			return tostring(value);
		end
		-- @return symbol_table, symbol_table_key
		function object:GetSymbol()
			local symbol_table     = aprservice_object_get_symbol_table(self.Handle);
			local symbol_table_key = aprservice_object_get_symbol_table_key(self.Handle);

			return tostring(symbol_table), tostring(symbol_table_key);
		end
		function object:GetComment()
			local value = aprservice_object_get_comment(self.Handle);

			return tostring(value);
		end
		-- @return latitude, longitude, altitude, speed, course
		function object:GetPosition()
			local speed     = aprservice_object_get_speed(self.Handle);
			local course    = aprservice_object_get_course(self.Handle);
			local altitude  = aprservice_object_get_altitude(self.Handle);
			local latitude  = aprservice_object_get_latitude(self.Handle);
			local longitude = aprservice_object_get_longitude(self.Handle);

			return tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
		end

		function object:SetSymbol(table, key)
			return aprservice_object_set_symbol(self.Handle, table, key) and true or false;
		end
		function object:SetComment(value)
			return aprservice_object_set_comment(self.Handle, value) and true or false;
		end
		function object:SetPosition(latitude, longitude, altitude, speed, course)
			return aprservice_object_set_position(self.Handle, latitude, longitude, altitude, speed, course) and true or false;
		end
		function object:SetCompressed(value)
			return aprservice_object_set_compressed(self.Handle, value) and true or false;
		end

		function object:Kill()
			return aprservice_object_kill(self.Handle) and true or false;
		end
		function object:Announce()
			return aprservice_object_announce(self.Handle) and true or false;
		end

		return object;
	end

	-- @param handler(is_canceled, seconds)->boolean
	-- @return task
	function service:ScheduleTask(seconds, handler)
		local task_handle = aprservice_task_schedule(self.Handle, seconds, handler);

		if not task_handle then
			return nil;
		end

		local task  = {};
		task.Handle = task_handle;

		function task:Cancel()
			if self.Handle ~= nil then
				aprservice_task_cancel(self.Handle);

				self.Handle = nil;
			end
		end

		return task;
	end

	-- @param handler(packet, sender, name, args)
	-- @return command
	function service:RegisterCommand(name, help, handler)
		local command_handle = aprservice_command_register(self.Handle, name, help, handler);

		if not command_handle then
			return nil;
		end

		local command  = {};
		command.Handle = command_handle;

		function command:GetHelp()
			local value = aprservice_command_get_help(self.Handle);

			return tostring(value);
		end

		function command:SetHelp(value)
			aprservice_command_set_help(self.Handle, value);
		end
		-- @param handler(packet, sender, name, args)->boolean
		function command:SetFilter(handler)
			return aprservice_command_set_filter(self.Handle, handler) and true or false;
		end

		function command:Unregister()
			if self.Handle ~= nil then
				aprservice_command_unregister(self.Handle);

				self.Handle = nil;
			end
		end

		return command;
	end

	return service;
end

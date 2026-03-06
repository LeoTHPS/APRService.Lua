APRS                                    = {};
APRS.Path                               = {};
APRS.Time                               = {};
APRS.Packet                             = {};
APRS.Packet.GPS                         = {};
APRS.Packet.Item                        = {};
APRS.Packet.Object                      = {};
APRS.Packet.Status                      = {};
APRS.Packet.Message                     = {};
APRS.Packet.Weather                     = {};
APRS.Packet.Position                    = {};
APRS.Packet.Telemetry                   = {};
APRS.Packet.ThirdParty                  = {};
APRS.Packet.UserDefined                 = {};

APRS.TIME_DHM                           = APRS_TIME_DHM;
APRS.TIME_HMS                           = APRS_TIME_HMS;
APRS.TIME_MDHM                          = APRS_TIME_MDHM;

APRS.DISTANCE_FEET                      = APRS_DISTANCE_FEET;
APRS.DISTANCE_MILES                     = APRS_DISTANCE_MILES;
APRS.DISTANCE_METERS                    = APRS_DISTANCE_METERS;
APRS.DISTANCE_KILOMETERS                = APRS_DISTANCE_KILOMETERS;

APRS.PACKET_TYPE_GPS                    = APRS_PACKET_TYPE_GPS;
APRS.PACKET_TYPE_RAW                    = APRS_PACKET_TYPE_RAW;
APRS.PACKET_TYPE_ITEM                   = APRS_PACKET_TYPE_ITEM;
APRS.PACKET_TYPE_TEST                   = APRS_PACKET_TYPE_TEST;
APRS.PACKET_TYPE_QUERY                  = APRS_PACKET_TYPE_QUERY;
APRS.PACKET_TYPE_OBJECT                 = APRS_PACKET_TYPE_OBJECT;
APRS.PACKET_TYPE_STATUS                 = APRS_PACKET_TYPE_STATUS;
APRS.PACKET_TYPE_MESSAGE                = APRS_PACKET_TYPE_MESSAGE;
APRS.PACKET_TYPE_WEATHER                = APRS_PACKET_TYPE_WEATHER;
APRS.PACKET_TYPE_POSITION               = APRS_PACKET_TYPE_POSITION;
APRS.PACKET_TYPE_TELEMETRY              = APRS_PACKET_TYPE_TELEMETRY;
APRS.PACKET_TYPE_MAP_FEATURE            = APRS_PACKET_TYPE_MAP_FEATURE;
APRS.PACKET_TYPE_GRID_BEACON            = APRS_PACKET_TYPE_GRID_BEACON;
APRS.PACKET_TYPE_THIRD_PARTY            = APRS_PACKET_TYPE_THIRD_PARTY;
APRS.PACKET_TYPE_MICROFINDER            = APRS_PACKET_TYPE_MICROFINDER;
APRS.PACKET_TYPE_USER_DEFINED           = APRS_PACKET_TYPE_USER_DEFINED;
APRS.PACKET_TYPE_SHELTER_TIME           = APRS_PACKET_TYPE_SHELTER_TIME;
APRS.PACKET_TYPE_STATION_CAPABILITIES   = APRS_PACKET_TYPE_STATION_CAPABILITIES;
APRS.PACKET_TYPE_MAIDENHEAD_GRID_BEACON = APRS_PACKET_TYPE_MAIDENHEAD_GRID_BEACON;

APRS.MESSAGE_TYPE_ACK                   = APRS_MESSAGE_TYPE_ACK;
APRS.MESSAGE_TYPE_REJECT                = APRS_MESSAGE_TYPE_REJECT;
APRS.MESSAGE_TYPE_MESSAGE               = APRS_MESSAGE_TYPE_MESSAGE;
APRS.MESSAGE_TYPE_BULLETIN              = APRS_MESSAGE_TYPE_BULLETIN;

APRS.MIC_E_MESSAGE_EMERGENCY            = APRS_MIC_E_MESSAGE_EMERGENCY;
APRS.MIC_E_MESSAGE_PRIORITY             = APRS_MIC_E_MESSAGE_PRIORITY;
APRS.MIC_E_MESSAGE_SPECIAL              = APRS_MIC_E_MESSAGE_SPECIAL;
APRS.MIC_E_MESSAGE_COMMITTED            = APRS_MIC_E_MESSAGE_COMMITTED;
APRS.MIC_E_MESSAGE_RETURNING            = APRS_MIC_E_MESSAGE_RETURNING;
APRS.MIC_E_MESSAGE_IN_SERVICE           = APRS_MIC_E_MESSAGE_IN_SERVICE;
APRS.MIC_E_MESSAGE_EN_ROUTE             = APRS_MIC_E_MESSAGE_EN_ROUTE;
APRS.MIC_E_MESSAGE_OFF_DUTY             = APRS_MIC_E_MESSAGE_OFF_DUTY;
APRS.MIC_E_MESSAGE_CUSTOM_0             = APRS_MIC_E_MESSAGE_CUSTOM_0;
APRS.MIC_E_MESSAGE_CUSTOM_1             = APRS_MIC_E_MESSAGE_CUSTOM_1;
APRS.MIC_E_MESSAGE_CUSTOM_2             = APRS_MIC_E_MESSAGE_CUSTOM_2;
APRS.MIC_E_MESSAGE_CUSTOM_3             = APRS_MIC_E_MESSAGE_CUSTOM_3;
APRS.MIC_E_MESSAGE_CUSTOM_4             = APRS_MIC_E_MESSAGE_CUSTOM_4;
APRS.MIC_E_MESSAGE_CUSTOM_5             = APRS_MIC_E_MESSAGE_CUSTOM_5;
APRS.MIC_E_MESSAGE_CUSTOM_6             = APRS_MIC_E_MESSAGE_CUSTOM_6;

APRS.POSITION_FLAG_TIME                 = APRS_POSITION_FLAG_TIME;
APRS.POSITION_FLAG_MIC_E                = APRS_POSITION_FLAG_MIC_E;
APRS.POSITION_FLAG_COMPRESSED           = APRS_POSITION_FLAG_COMPRESSED;
APRS.POSITION_FLAG_MESSAGING_ENABLED    = APRS_POSITION_FLAG_MESSAGING_ENABLED;

APRS.TELEMETRY_TYPE_U8                  = APRS_TELEMETRY_TYPE_U8;
APRS.TELEMETRY_TYPE_FLOAT               = APRS_TELEMETRY_TYPE_FLOAT;
APRS.TELEMETRY_TYPE_PARAMS              = APRS_TELEMETRY_TYPE_PARAMS;
APRS.TELEMETRY_TYPE_UNITS               = APRS_TELEMETRY_TYPE_UNITS;
APRS.TELEMETRY_TYPE_EQNS                = APRS_TELEMETRY_TYPE_EQNS;
APRS.TELEMETRY_TYPE_BITS                = APRS_TELEMETRY_TYPE_BITS;

function APRS.Distance(latitude1, longitude1, latitude2, longitude2, type)
	local value = aprs_distance(latitude1, longitude1, latitude2, longitude2, type);

	return tonumber(value);
end
function APRS.Distance3D(latitude1, longitude1, altitude1, latitude2, longitude2, altitude2, type)
	local value = aprs_distance_3d(latitude1, longitude1, altitude1, latitude2, longitude2, altitude2, type);

	return tonumber(value);
end

function APRS.MicEMessageToString(value)
	local string = aprs_mic_e_message_to_string(value);

	if not string then
		return nil;
	end

	return tostring(string);
end

-- @return path
function APRS.Path.Init()
	local handle = aprs_path_init();

	if not handle then
		return nil;
	end

	return APRS.Path.InitFromHandle(handle, false, true);
end
-- @param path can be path or userdata
-- @return path
function APRS.Path.InitFromCopy(path)
	local path_type = type(path);

	if path_type == "table" then
		local handle = aprs_path_init_from_copy(path.Handle);

		if not handle then
			return nil;
		end

		return APRS.Path.InitFromHandle(handle, false, true);
	elseif path_type == "userdata" then
		local handle = aprs_path_init_from_copy(path);

		if not handle then
			return nil;
		end

		return APRS.Path.InitFromHandle(handle, false, true);
	end

	return nil;
end
-- @return path
function APRS.Path.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local path  = {};
	path.Handle = handle;

	if not take_ownership then
		aprs_path_add_reference(handle);
	end

	setmetatable(path, {
		__gc = function(self)
			aprs_path_deinit(self.Handle);
		end
	});

	-- @return station, is_repeated
	function path:Get(index)
		local station, is_repeated = aprs_path_get(self.Handle, index);

		if not station then
			return nil;
		end

		return tostring(station), is_repeated and true or false;
	end
	function path:GetLength()
		local value = aprs_path_get_length(self.Handle);

		return tonumber(value);
	end
	function path:GetCapacity()
		local value = aprs_path_get_capacity(self.Handle);

		return tonumber(value);
	end

	if not read_only then
		function path:Set(index, station, is_repeated)
			return aprs_path_set(self.Handle, index, station, is_repeated) and true or false;
		end

		function path:Pop()
			return aprs_path_pop(self.Handle) and true or false;
		end
		function path:Push(station, is_repeated)
			return aprs_path_push(self.Handle, station, is_repeated) and true or false;
		end

		function path:Clear()
			aprs_path_clear(self.Handle);
		end
	end

	function path:ToString()
		local value = aprs_path_to_string(self.Handle);

		return tostring(value);
	end

	function path:Compare(path)
		return aprs_path_compare(self.Handle, path.Handle) and true or false;
	end

	return path;
end
-- @return path
function APRS.Path.InitFromString(value)
	local handle = aprs_path_init_from_string(value);

	if not handle then
		return nil;
	end

	return APRS.Path.InitFromHandle(handle, false, true);
end

-- @return time
function APRS.Time.Now()
	local handle = aprs_time_now();

	if not handle then
		return nil;
	end

	return APRS.Time.FromHandle(handle);
end
-- @return time
function APRS.Time.FromHandle(handle)
	if not handle then
		return nil;
	end

	local time  = {};
	time.Handle = handle;

	function time:GetType()
		return aprs_time_get_type(self.Handle);
	end
	-- @return day, hour, minute
	function time:GetDHM()
		local day, hour, minute = aprs_time_get_dhm(self.Handle);

		return tonumber(day), tonumber(hour), tonumber(minute);
	end
	-- @return hour, minute, second
	function time:GetHMS()
		local hour, minute, second = aprs_time_get_hms(self.Handle);

		return tonumber(hour), tonumber(minute), tonumber(second);
	end
	-- @return month, day, hour, minute
	function time:GetMDHM()
		local month, day, hour, minute = aprs_time_get_mdhm(self.Handle);

		return tonumber(month), tonumber(day), tonumber(hour), tonumber(minute);
	end

	function time:Compare(time)
		return aprs_time_compare(self.Handle, time.Handle) and true or false;
	end

	return time;
end

-- @param path can be string or path
function APRS.Packet.Init(sender, tocall, path)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_init(sender, tocall, path);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_init(sender, tocall, path.Handle);

		if not handle then
			return nil;
		end

		return APRS.Packet.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.InitFromCopy(packet)
	local handle = aprs_packet_init_from_copy(packet);

	if not handle then
		return nil;
	end

	return APRS.Packet.InitFromHandle(handle, false, true);
end
function APRS.Packet.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local packet  = {};
	packet.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(packet, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	function packet:GetQ()
		local value = aprs_packet_get_q(self.Handle);

		return tostring(value);
	end
	function packet:GetType()
		local value = aprs_packet_get_type(self.Handle);

		return tonumber(value);
	end
	function packet:GetPath()
		local handle = aprs_packet_get_path(self.Handle);

		return APRS.Path.InitFromHandle(handle, true, false);
	end
	function packet:GetIGate()
		local value = aprs_packet_get_igate(self.Handle);

		return tostring(value);
	end
	function packet:GetToCall()
		local value = aprs_packet_get_tocall(self.Handle);

		return tostring(value);
	end
	function packet:GetSender()
		local value = aprs_packet_get_sender(self.Handle);

		return tostring(value);
	end
	function packet:GetContent()
		local value = aprs_packet_get_content(self.Handle);

		return tostring(value);
	end

	if not read_only then
		-- @param path can be string or path
		function packet:SetPath(value)
			local value_type = type(value);

			if value_type == "string" then
				local path = aprs_path_init_from_string(value);

				if path then
					local success = aprs_packet_set_path(self.Handle, path);

					aprs_path_deinit(path);

					if success then
						return true;
					end
				end
			elseif value_type == "table" then
				return aprs_packet_set_path(self.Handle, value.Handle) and true or false;
			end

			return false;
		end
		function packet:SetToCall(value)
			return aprs_packet_set_tocall(self.Handle, value) and true or false;
		end
		function packet:SetSender(value)
			return aprs_packet_set_sender(self.Handle, value) and true or false;
		end
		function packet:SetContent(value)
			return aprs_packet_set_content(self.Handle, value) and true or false;
		end
	end

	function packet:Compare(packet)
		return aprs_packet_compare(self.Handle, packet.Handle) and true or false;
	end

	function packet:ToString()
		local value = aprs_packet_to_string(self.Handle);

		return tostring(value);
	end

	return packet;
end
function APRS.Packet.InitFromString(value)
	local handle = aprs_packet_init_from_string(value);

	if not handle then
		return nil;
	end

	return APRS.Packet.InitFromHandle(handle, false, true);
end

-- @param path can be string or path
function APRS.Packet.GPS.Init(sender, tocall, path, nmea)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_gps_init(sender, tocall, path, nmea);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.GPS.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_gps_init(sender, tocall, path.Handle, nmea);

		if not handle then
			return nil;
		end

		return APRS.Packet.GPS.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.GPS.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local gps  = {};
	gps.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(gps, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	function gps:GetNMEA()
		local value = aprs_packet_gps_get_nmea(self.Handle);

		return tostring(value);
	end
	function gps:GetComment()
		local value = aprs_packet_gps_get_comment(self.Handle);

		return tostring(value);
	end

	if not read_only then
		function gps:SetNMEA(value)
			return aprs_packet_gps_set_nmea(self.Handle, value) and true or false;
		end
		function gps:SetComment(value)
			return aprs_packet_gps_set_comment(self.Handle, value) and true or false;
		end
	end

	return gps;
end

-- @param path can be string or path
function APRS.Packet.Item.Init(sender, tocall, path, name, symbol_table, symbol_table_key)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_item_init(sender, tocall, path, name, symbol_table, symbol_table_key);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Item.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_item_init(sender, tocall, path.Handle, name, symbol_table, symbol_table_key);

		if not handle then
			return nil;
		end

		return APRS.Packet.Item.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Item.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local item  = {};
	item.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(item, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return item;
end

-- @param path can be string or path
function APRS.Packet.Object.Init(sender, tocall, path, name, symbol_table, symbol_table_key)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_object_init(sender, tocall, path, name, symbol_table, symbol_table_key);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Object.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_object_init(sender, tocall, path.Handle, name, symbol_table, symbol_table_key);

		if not handle then
			return nil;
		end

		return APRS.Packet.Object.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Object.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local object  = {};
	object.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(object, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return object;
end

-- @param path can be string or path
function APRS.Packet.Status.Init(sender, tocall, path, message)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_status_init(sender, tocall, path, message);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Status.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_status_init(sender, tocall, path.Handle, message);

		if not handle then
			return nil;
		end

		return APRS.Packet.Status.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Status.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local status  = {};
	status.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(status, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	function status:GetTime()
		local value = aprs_packet_status_get_time(self.Handle);

		if not value then
			return nil;
		end

		return APRS.Time.FromHandle(value);
	end
	function status:GetMessage()
		local value = aprs_packet_status_get_message(self.Handle);

		return tostring(value);
	end

	if not read_only then
		-- @param value can be time or userdata
		function status:SetTime(value)
			local value_type = type(value);

			if value_type == "table" then
				return aprs_packet_status_set_time(self.Handle, value.Handle) and true or false;
			elseif value_type == "userdata" then
				return aprs_packet_status_set_time(self.Handle, value) and true or false;
			end

			return false;
		end
		function status:SetMessage(value)
			return aprs_packet_status_set_message(self.Handle, value) and true or false;
		end
	end

	return status;
end

-- @param path can be string or path
function APRS.Packet.Message.Init(sender, tocall, path, destination, content)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_message_init(sender, tocall, path, destination, content);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Message.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_message_init(sender, tocall, path.Handle, destination, content);

		if not handle then
			return nil;
		end

		return APRS.Packet.Message.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Message.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local message  = {};
	message.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(message, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return message;
end

-- @param path can be string or path
function APRS.Packet.Weather.Init(sender, tocall, path, type, software)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_weather_init(sender, tocall, path, type, software);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Weather.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_weather_init(sender, tocall, path.Handle, type, software);

		if not handle then
			return nil;
		end

		return APRS.Packet.Weather.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Weather.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local weather  = {};
	weather.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(weather, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return weather;
end

-- @param path can be string or path
function APRS.Packet.Position.Init(sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_position_init(sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.Position.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_position_init(sender, tocall, path.Handle, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key);

		if not handle then
			return nil;
		end

		return APRS.Packet.Position.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.Position.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local position  = {};
	position.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(position, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return position;
end

-- @param path can be string or path
function APRS.Packet.Telemetry.Init(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence)
	local function init(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence, func)
		local path_type = type(path);

		if path_type == "string" then
			path = aprs_path_init_from_string(path);

			if not path then
				return nil;
			end

			local handle = func(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence);

			if not handle then
				aprs_path_deinit(path);

				return nil;
			end

			aprs_path_deinit(path);

			return APRS.Packet.Telemetry.InitFromHandle(handle, false, true);
		elseif path_type == "table" then
			local handle = func(sender, tocall, path.Handle, a1, a2, a3, a4, a5, digital, sequence);

			if not handle then
				return nil;
			end

			return APRS.Packet.Telemetry.InitFromHandle(handle, false, true);
		end

		return nil;
	end

	if (math.type(a1) == "integer") and (math.type(a2) == "integer") and (math.type(a3) == "integer") and (math.type(a4) == "integer") and (math.type(a5) == "integer") then
		return init(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence, aprs_packet_telemetry_init);
	end

	return init(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence, aprs_packet_telemetry_init_float);
end
function APRS.Packet.Telemetry.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local telemetry  = {};
	telemetry.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(telemetry, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	-- TODO: implement

	if not read_only then
		
	end

	return telemetry;
end

-- @param path can be string or path
function APRS.Packet.ThirdParty.Init(sender, tocall, path)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_third_party_init(sender, tocall, path);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.ThirdParty.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_third_party_init(sender, tocall, path.Handle);

		if not handle then
			return nil;
		end

		return APRS.Packet.ThirdParty.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.ThirdParty.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local third_party  = {};
	third_party.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(third_party, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	function third_party:GetContent()
		local value = aprs_packet_third_party_get_content(self.Handle);

		return tostring(value);
	end

	if not read_only then
		function third_party:SetContent(value)
			return aprs_packet_third_party_set_content(self.Handle, value) and true or false;
		end
	end

	return third_party;
end

-- @param path can be string or path
function APRS.Packet.UserDefined.Init(sender, tocall, path, id, type, data)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = aprs_packet_user_defined_init(sender, tocall, path, id, type, data);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.UserDefined.InitFromHandle(handle, false, true);
	elseif path_type == "table" then
		local handle = aprs_packet_user_defined_init(sender, tocall, path.Handle, id, type, data);

		if not handle then
			return nil;
		end

		return APRS.Packet.UserDefined.InitFromHandle(handle, false, true);
	end

	return nil;
end
function APRS.Packet.UserDefined.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

	local user_defined  = {};
	user_defined.Handle = handle;

	if not take_ownership then
		aprs_packet_add_reference(handle);
	end

	setmetatable(user_defined, {
		__gc = function(self)
			aprs_packet_deinit(self.Handle);
		end
	});

	function user_defined:GetID()
		local value = aprs_packet_user_defined_get_id(self.Handle);

		return tostring(value);
	end
	function user_defined:GetData()
		local value = aprs_packet_user_defined_get_data(self.Handle);

		return tostring(value);
	end
	function user_defined:GetType()
		local value = aprs_packet_user_defined_get_type(self.Handle);

		return tostring(value);
	end

	if not read_only then
		function user_defined:SetID(value)
			return aprs_packet_user_defined_set_id(self.Handle, value) and true or false;
		end
		function user_defined:SetData(value)
			return aprs_packet_user_defined_set_data(self.Handle, value) and true or false;
		end
		function user_defined:SetType(value)
			return aprs_packet_user_defined_set_type(self.Handle, value) and true or false;
		end
	end

	return user_defined;
end

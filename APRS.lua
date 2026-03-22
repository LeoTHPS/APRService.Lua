APRS                                    = {};
APRS.Path                               = {};
APRS.Time                               = {};
APRS.Packet                             = {};

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

local function APRS_Packet_Init(init, read_only, take_ownership, sender, tocall, path, ...)
	local path_type = type(path);

	if path_type == "string" then
		path = aprs_path_init_from_string(path);

		if not path then
			return nil;
		end

		local handle = init(sender, tocall, path, ...);

		if not handle then
			aprs_path_deinit(path);

			return nil;
		end

		aprs_path_deinit(path);

		return APRS.Packet.InitFromHandle(handle, read_only, take_ownership);
	elseif path_type == "table" then
		local handle = init(sender, tocall, path.Handle, ...);

		if not handle then
			return nil;
		end

		return APRS.Packet.InitFromHandle(handle, read_only, take_ownership);
	end

	return nil;
end

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
-- @return packet
function APRS.Packet.Init(sender, tocall, path)
	return APRS_Packet_Init(aprs_packet_init, false, true, sender, tocall, path);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitGPS(sender, tocall, path, nmea)
	return APRS_Packet_Init(aprs_packet_gps_init, false, true, sender, tocall, path, nmea);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitItem(sender, tocall, path, name, symbol_table, symbol_table_key)
	return APRS_Packet_Init(aprs_packet_item_init, false, true, sender, tocall, path, name, symbol_table, symbol_table_key);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitObject(sender, tocall, path, name, symbol_table, symbol_table_key)
	return APRS_Packet_Init(aprs_packet_object_init, false, true, sender, tocall, path, name, symbol_table, symbol_table_key);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitStatus(sender, tocall, path, message)
	return APRS_Packet_Init(aprs_packet_status_init, false, true, sender, tocall, path, message);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitMessage(sender, tocall, path, destination, content)
	return APRS_Packet_Init(aprs_packet_message_init, false, true, sender, tocall, path, destination, content);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitMessageAck(sender, tocall, path, destination, id)
	return APRS_Packet_Init(aprs_packet_message_init_ack, false, true, sender, tocall, path, destination, id);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitMessageReject(sender, tocall, path, destination, id)
	return APRS_Packet_Init(aprs_packet_message_init_reject, false, true, sender, tocall, path, destination, id);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitMessageBulletin(sender, tocall, path, destination)
	return APRS_Packet_Init(aprs_packet_message_init_bulletin, false, true, sender, tocall, path, destination);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitWeather(sender, tocall, path, type, software)
	return APRS_Packet_Init(aprs_packet_weather_init, false, true, sender, tocall, path, type, software);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitPosition(sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key)
	return APRS_Packet_Init(aprs_packet_position_init, false, true, sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitPositionMicE(sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key, message)
	return APRS_Packet_Init(aprs_packet_position_init_mic_e, false, true, sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key, message);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitPositionCompressed(sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key)
	return APRS_Packet_Init(aprs_packet_position_init_compressed, false, true, sender, tocall, path, latitude, longitude, altitude, speed, course, comment, symbol_table, symbol_table_key);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitTelemetry(sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence)
	if (math.type(a1) == "integer") and (math.type(a2) == "integer") and (math.type(a3) == "integer") and (math.type(a4) == "integer") and (math.type(a5) == "integer") then
		return APRS_Packet_Init(aprs_packet_telemetry_init, false, true, sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence);
	end

	return APRS_Packet_Init(aprs_packet_telemetry_init_float, false, true, sender, tocall, path, a1, a2, a3, a4, a5, digital, sequence);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitTelemetryBits(sender, tocall, path, value)
	return APRS_Packet_Init(aprs_packet_telemetry_init_bits, false, true, sender, tocall, path, value);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitTelemetryEqns(sender, tocall, path)
	return APRS_Packet_Init(aprs_packet_telemetry_init_eqns, false, true, sender, tocall, path);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitTelemetryUnits(sender, tocall, path)
	return APRS_Packet_Init(aprs_packet_telemetry_init_units, false, true, sender, tocall, path);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitTelemetryParams(sender, tocall, path)
	return APRS_Packet_Init(aprs_packet_telemetry_init_params, false, true, sender, tocall, path);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitThirdParty(sender, tocall, path)
	return APRS_Packet_Init(aprs_packet_third_party_init, false, true, sender, tocall, path);
end
-- @param path can be string or path
-- @return packet
function APRS.Packet.InitUserDefined(sender, tocall, path, id, type, data)
	return APRS_Packet_Init(aprs_packet_user_defined_init, false, true, sender, tocall, path, id, type, data);
end
-- @return packet
function APRS.Packet.InitFromCopy(packet)
	local handle = aprs_packet_init_from_copy(packet);

	if not handle then
		return nil;
	end

	return APRS.Packet.InitFromHandle(handle, false, true);
end
-- @return packet
function APRS.Packet.InitFromHandle(handle, read_only, take_ownership)
	if not handle then
		return nil;
	end

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

	local type = packet:GetType();

	if type == APRS.PACKET_TYPE_GPS then
		function packet:GetGpsNMEA()
			local value = aprs_packet_gps_get_nmea(self.Handle);

			return tostring(value);
		end
		function packet:GetGpsComment()
			local value = aprs_packet_gps_get_comment(self.Handle);

			return tostring(value);
		end

		if not read_only then
			function packet:SetGpsNMEA(value)
				return aprs_packet_gps_set_nmea(self.Handle, value) and true or false;
			end
			function packet:SetGpsComment(value)
				return aprs_packet_gps_set_comment(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_ITEM then
		function packet:IsItemAlive()
			return aprs_packet_item_is_alive(self.Handle) and true or false;
		end
		function packet:IsItemCompressed()
			return aprs_packet_item_is_compressed(self.Handle) and true or false;
		end

		function packet:GetItemName()
			local value = aprs_packet_item_get_name(self.Handle);

			return tostring(value);
		end
		-- @return symbol_table, symbol_table_key
		function packet:GetItemSymbol()
			local symbol_table     = aprs_packet_item_get_symbol_table(self.Handle);
			local symbol_table_key = aprs_packet_item_get_symbol_table_key(self.Handle);

			return tostring(symbol_table), tostring(symbol_table_key);
		end
		function packet:GetItemComment()
			local value = aprs_packet_item_get_comment(self.Handle);

			return tostring(value);
		end
		-- @return latitude, longitude, altitude, speed, course
		function packet:GetItemPosition()
			local speed     = aprs_packet_item_get_speed(self.Handle);
			local course    = aprs_packet_item_get_course(self.Handle);
			local altitude  = aprs_packet_item_get_altitude(self.Handle);
			local latitude  = aprs_packet_item_get_latitude(self.Handle);
			local longitude = aprs_packet_item_get_longitude(self.Handle);

			return tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
		end

		if not read_only then
			function packet:SetItemName(value)
				return aprs_packet_item_set_name(self.Handle, value) and true or false;
			end
			function packet:SetItemAlive(value)
				return aprs_packet_item_set_alive(self.Handle, value) and true or false;
			end
			function packet:SetItemSymbol(table, key)
				return aprs_packet_item_set_symbol(self.Handle, table, key) and true or false;
			end
			function packet:SetItemComment(value)
				return aprs_packet_item_set_comment(self.Handle, value) and true or false;
			end
			function packet:SetItemPosition(latitude, longitude, altitude, speed, course)
				if not aprs_packet_item_set_speed(self.Handle, speed) then
					return false;
				end

				if not aprs_packet_item_set_course(self.Handle, course) then
					return false;
				end

				if not aprs_packet_item_set_altitude(self.Handle, altitude) then
					return false;
				end

				if not aprs_packet_item_set_latitude(self.Handle, latitude) then
					return false;
				end

				if not aprs_packet_item_set_longitude(self.Handle, longitude) then
					return false;
				end

				return true;
			end
			function packet:SetItemCompressed(value)
				return aprs_packet_item_set_compressed(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_TEST then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_QUERY then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_OBJECT then
		function packet:IsObjectAlive()
			return aprs_packet_object_is_alive(self.Handle) and true or false;
		end
		function packet:IsObjectCompressed()
			return aprs_packet_object_is_compressed(self.Handle) and true or false;
		end

		function packet:GetObjectName()
			local value = aprs_packet_object_get_name(self.Handle);

			return tostring(value);
		end
		-- @return symbol_table, symbol_table_key
		function packet:GetObjectSymbol()
			local symbol_table     = aprs_packet_object_get_symbol_table(self.Handle);
			local symbol_table_key = aprs_packet_object_get_symbol_table_key(self.Handle);

			return tostring(symbol_table), tostring(symbol_table_key);
		end
		function packet:GetObjectComment()
			local value = aprs_packet_object_get_comment(self.Handle);

			return tostring(value);
		end
		-- @return latitude, longitude, altitude, speed, course
		function packet:GetObjectPosition()
			local speed     = aprs_packet_object_get_speed(self.Handle);
			local course    = aprs_packet_object_get_course(self.Handle);
			local altitude  = aprs_packet_object_get_altitude(self.Handle);
			local latitude  = aprs_packet_object_get_latitude(self.Handle);
			local longitude = aprs_packet_object_get_longitude(self.Handle);

			return tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
		end

		if not read_only then
			function packet:SetObjectName(value)
				return aprs_packet_object_set_name(self.Handle, value) and true or false;
			end
			function packet:SetObjectAlive(value)
				return aprs_packet_object_set_alive(self.Handle, value) and true or false;
			end
			function packet:SetObjectSymbol(table, key)
				return aprs_packet_object_set_symbol(self.Handle, table, key) and true or false;
			end
			function packet:SetObjectComment(value)
				return aprs_packet_object_set_comment(self.Handle, value) and true or false;
			end
			function packet:SetObjectPosition(latitude, longitude, altitude, speed, course)
				if not aprs_packet_object_set_speed(self.Handle, speed) then
					return false;
				end

				if not aprs_packet_object_set_course(self.Handle, course) then
					return false;
				end

				if not aprs_packet_object_set_altitude(self.Handle, altitude) then
					return false;
				end

				if not aprs_packet_object_set_latitude(self.Handle, latitude) then
					return false;
				end

				if not aprs_packet_object_set_longitude(self.Handle, longitude) then
					return false;
				end

				return true;
			end
			function packet:SetObjectCompressed(value)
				return aprs_packet_object_set_compressed(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_STATUS then
		function packet:GetStatusTime()
			local value = aprs_packet_status_get_time(self.Handle);

			if not value then
				return nil;
			end

			return APRS.Time.FromHandle(value);
		end
		function packet:GetStatusMessage()
			local value = aprs_packet_status_get_message(self.Handle);

			return tostring(value);
		end

		if not read_only then
			-- @param value can be time or userdata
			function packet:SetStatusTime(value)
				local value_type = type(value);

				if value_type == "table" then
					return aprs_packet_status_set_time(self.Handle, value.Handle) and true or false;
				elseif value_type == "userdata" then
					return aprs_packet_status_set_time(self.Handle, value) and true or false;
				end

				return false;
			end
			function packet:SetStatusMessage(value)
				return aprs_packet_status_set_message(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_MESSAGE then
		function packet:GetMessageID()
			local value = aprs_packet_message_get_id(self.Handle);

			if not value then
				return nil;
			end

			return tostring(value);
		end
		function packet:GetMessageType()
			local value = aprs_packet_message_get_type(self.Handle);

			return tonumber(value);
		end
		function packet:GetMessageContent()
			local value = aprs_packet_message_get_content(self.Handle);

			return tostring(value);
		end
		function packet:GetMessageDestination()
			local value = aprs_packet_message_get_destination(self.Handle);

			return tostring(value);
		end

		if not read_only then
			function packet:SetMessageID(value)
				return aprs_packet_message_set_id(self.Handle, value) and true or false;
			end
			function packet:SetMessageType(value)
				return aprs_packet_message_set_type(self.Handle, value) and true or false;
			end
			function packet:SetMessageContent(value)
				return aprs_packet_message_set_content(self.Handle, value) and true or false;
			end
			function packet:SetMessageDestination(value)
				return aprs_packet_message_set_destination(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_WEATHER then
		function packet:GetWeatherTime()
			local value = aprs_packet_weather_get_time(self.Handle);

			if not value then
				return nil;
			end

			return APRS.Time.FromHandle(value);
		end
		function packet:GetWeatherType()
			local value = aprs_packet_weather_get_type(self.Handle);

			return tostring(value);
		end
		function packet:GetWeatherSoftware()
			local value = aprs_packet_weather_get_software(self.Handle);

			return tostring(value);
		end
		function packet:GetWeatherWindSpeed()
			local value = aprs_packet_weather_get_wind_speed(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherWindSpeedGust()
			local value = aprs_packet_weather_get_wind_speed_gust(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherWindDirection()
			local value = aprs_packet_weather_get_wind_direction(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherRainfallLastHour()
			local value = aprs_packet_weather_get_rainfall_last_hour(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherRainfallLast24Hours()
			local value = aprs_packet_weather_get_rainfall_last_24_hours(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherRainfallSinceMidnight()
			local value = aprs_packet_weather_get_rainfall_since_midnight(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherHumidity()
			local value = aprs_packet_weather_get_humidity(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherTemperature()
			local value = aprs_packet_weather_get_temperature(self.Handle);

			return tonumber(value);
		end
		function packet:GetWeatherBarometricPressure()
			local value = aprs_packet_weather_get_barometric_pressure(self.Handle);

			return tonumber(value);
		end

		if not read_only then
			function packet:SetWeatherTime(value)
				local value_type = type(value);

				if value_type == "table" then
					return aprs_packet_weather_set_time(self.Handle, value.Handle) and true or false;
				elseif value_type == "userdata" then
					return aprs_packet_weather_set_time(self.Handle, value) and true or false;
				end

				return false;
			end
			function packet:SetWeatherWindSpeed(value)
				return aprs_packet_weather_set_wind_speed(self.Handle, value) and true or false;
			end
			function packet:SetWeatherWindSpeedGust(value)
				return aprs_packet_weather_set_wind_speed_gust(self.Handle, value) and true or false;
			end
			function packet:SetWeatherWindDirection(value)
				return aprs_packet_weather_set_wind_direction(self.Handle, value) and true or false;
			end
			function packet:SetWeatherRainfallLastHour(value)
				return aprs_packet_weather_set_rainfall_last_hour(self.Handle, value) and true or false;
			end
			function packet:SetWeatherRainfallLast24Hours(value)
				return aprs_packet_weather_set_rainfall_last_24_hours(self.Handle, value) and true or false;
			end
			function packet:SetWeatherRainfallSinceMidnight(value)
				return aprs_packet_weather_set_rainfall_since_midnight(self.Handle, value) and true or false;
			end
			function packet:SetWeatherHumidity(value)
				return aprs_packet_weather_set_humidity(self.Handle, value) and true or false;
			end
			function packet:SetWeatherTemperature(value)
				return aprs_packet_weather_set_temperature(self.Handle, value) and true or false;
			end
			function packet:SetWeatherBarometricPressure(value)
				return aprs_packet_weather_set_barometric_pressure(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_POSITION then
		function packet:IsPositionMicE()
			return aprs_packet_position_is_mic_e(self.Handle) and true or false;
		end
		function packet:IsPositionCompressed()
			return aprs_packet_position_is_compressed(self.Handle) and true or false;
		end
		function packet:IsPositionMessagingEnabled()
			return aprs_packet_position_is_messaging_enabled(self.Handle) and true or false;
		end

		-- @return latitude, longitude, altitude, speed, course
		function packet:GetPosition()
			local speed     = aprs_packet_position_get_speed(self.Handle);
			local course    = aprs_packet_position_get_course(self.Handle);
			local altitude  = aprs_packet_position_get_altitude(self.Handle);
			local latitude  = aprs_packet_position_get_latitude(self.Handle);
			local longitude = aprs_packet_position_get_longitude(self.Handle);

			return tonumber(latitude), tonumber(longitude), tonumber(altitude), tonumber(speed), tonumber(course);
		end
		function packet:GetPositionTime()
			local value = aprs_packet_position_get_time(self.Handle);

			if not value then
				return nil;
			end

			return APRS.Time.FromHandle(value);
		end
		function packet:GetPositionFlags()
			local value = aprs_packet_position_get_flags(self.Handle);

			return tonumber(value);
		end
		-- @return symbol_table, symbol_table_key
		function packet:GetPositionSymbol()
			local symbol_table     = aprs_packet_position_get_symbol_table(self.Handle);
			local symbol_table_key = aprs_packet_position_get_symbol_table_key(self.Handle);

			return tostring(symbol_table), tostring(symbol_table_key);
		end
		function packet:GetPositionComment()
			local value = aprs_packet_position_get_comment(self.Handle);

			return tostring(value);
		end
		function packet:GetPositionMicEComment()
			local value = aprs_packet_position_get_mic_e_message(self.Handle);

			return tonumber(value);
		end

		if not read_only then
			function packet:SetPosition(latitude, longitude, altitude, speed, course)
				if not aprs_packet_position_set_speed(self.Handle, speed) then
					return false;
				end

				if not aprs_packet_position_set_course(self.Handle, course) then
					return false;
				end

				if not aprs_packet_position_set_altitude(self.Handle, altitude) then
					return false;
				end

				if not aprs_packet_position_set_latitude(self.Handle, latitude) then
					return false;
				end

				if not aprs_packet_position_set_longitude(self.Handle, longitude) then
					return false;
				end

				return true;
			end
			function packet:SetPositionTime(value)
				local value_type = type(value);

				if value_type == "table" then
					return aprs_packet_position_set_time(self.Handle, value.Handle) and true or false;
				elseif value_type == "userdata" then
					return aprs_packet_position_set_time(self.Handle, value) and true or false;
				end

				return false;
			end
			function packet:SetPositionSymbol(table, key)
				return aprs_packet_position_set_symbol(self.Handle, table, key) and true or false;
			end
			function packet:SetPositionComment(value)
				return aprs_packet_position_set_comment(self.Handle, value) and true or false;
			end
			function packet:SetPositionMicEMessage(value)
				return aprs_packet_position_set_mic_e_message(self.Handle, value) and true or false;
			end

			function packet:EnablePositionMicE(value)
				return aprs_packet_position_enable_mic_e(self.Handle, value) and true or false;
			end
			function packet:EnablePositionMessaging(value)
				return aprs_packet_position_enable_messaging(self.Handle, value) and true or false;
			end
			function packet:EnablePositionCompression(value)
				return aprs_packet_position_enable_compression(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_TELEMETRY then
		function packet:GetTelemetryType()
			local value = aprs_packet_telemetry_get_type(self.Handle);

			return tonumber(value);
		end
		function packet:GetTelemetryBits()
			local value = aprs_packet_telemetry_get_bits(self.Handle);

			return tonumber(value);
		end
		-- @return eqn1, eqn2, eqn3, eqn4, eqn5
		function packet:GetTelemetryEqns()
			local eqn1                                                                                                                   = nil;
			local eqn2                                                                                                                   = nil;
			local eqn3                                                                                                                   = nil;
			local eqn4                                                                                                                   = nil;
			local eqn5                                                                                                                   = nil;
			local eqn1_a, eqn1_b, eqn1_c, eqn2_a, eqn2_b, eqn2_c, eqn3_a, eqn3_b, eqn3_c, eqn4_a, eqn4_b, eqn4_c, eqn5_a, eqn5_b, eqn5_c = aprs_packet_telemetry_get_eqns(self.Handle);

			if (eqn1_a and eqn1_b and eqn1_c) then
				eqn1 = { eqn1_a, eqn1_b, eqn1_c };

				if (eqn2_a and eqn2_b and eqn2_c) then
					eqn2 = { eqn2_a, eqn2_b, eqn2_c };

					if (eqn3_a and eqn3_b and eqn3_c) then
						eqn3 = { eqn3_a, eqn3_b, eqn3_c };

						if (eqn4_a and eqn4_b and eqn4_c) then
							eqn4 = { eqn4_a, eqn4_b, eqn4_c };

							if (eqn5_a and eqn5_b and eqn5_c) then
								eqn5 = { eqn5_a, eqn5_b, eqn5_c };
							end
						end
					end
				end
			end

			return eqn1, eqn2, eqn3, eqn4, eqn5;
		end
		-- @return unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8, unit9, unit10, unit11, unit12, unit13
		function packet:GetTelemetryUnits()
			local unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8, unit9, unit10, unit11, unit12, unit13 = aprs_packet_telemetry_get_units(self.Handle);

			return unit1 and tostring(unit1) or nil,
					unit2 and tostring(unit2) or nil,
					unit3 and tostring(unit3) or nil,
					unit4 and tostring(unit4) or nil,
					unit5 and tostring(unit5) or nil,
					unit6 and tostring(unit6) or nil,
					unit7 and tostring(unit7) or nil,
					unit8 and tostring(unit8) or nil,
					unit9 and tostring(unit9) or nil,
					unit10 and tostring(unit10) or nil,
					unit11 and tostring(unit11) or nil,
					unit12 and tostring(unit12) or nil,
					unit13 and tostring(unit13) or nil;
		end
		-- @return param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13
		function packet:GetTelemetryParams()
			local param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13 = aprs_packet_telemetry_get_params(self.Handle);

			return param1 and tostring(param1) or nil,
					param2 and tostring(param2) or nil,
					param3 and tostring(param3) or nil,
					param4 and tostring(param4) or nil,
					param5 and tostring(param5) or nil,
					param6 and tostring(param6) or nil,
					param7 and tostring(param7) or nil,
					param8 and tostring(param8) or nil,
					param9 and tostring(param9) or nil,
					param10 and tostring(param10) or nil,
					param11 and tostring(param11) or nil,
					param12 and tostring(param12) or nil,
					param13 and tostring(param13) or nil;
		end
		-- @return a1, a2, a3, a4, a5
		function packet:GetTelemetryAnalog()
			local analog_type = self:GetTelemetryType();

			if analog_type == APRS.TELEMETRY_TYPE_U8 then
				local a1, a2, a3, a4, a5 = aprs_packet_telemetry_get_analog(self.Handle);

				return tonumber(a1), tonumber(a2), tonumber(a3), tonumber(a4), tonumber(a5);
			elseif analog_type == APRS.TELEMETRY_TYPE_FLOAT then
				local a1, a2, a3, a4, a5 = aprs_packet_telemetry_get_analog_float(self.Handle);

				return tonumber(a1), tonumber(a2), tonumber(a3), tonumber(a4), tonumber(a5);
			end
		end
		function packet:GetTelemetryComment()
			local value = aprs_packet_telemetry_get_comment(self.Handle);

			return tostring(value);
		end
		function packet:GetTelemetryDigital()
			local value = aprs_packet_telemetry_get_digital(self.Handle);

			return tonumber(value);
		end
		function packet:GetTelemetrySequence()
			local value = aprs_packet_telemetry_get_sequence(self.Handle);

			return tonumber(value);
		end

		if not read_only then
			function packet:SetTelemetryBits(value)
				return aprs_packet_telemetry_set_bits(self.Handle, value) and true or false;
			end
			function packet:SetTelemetryAnalog(a1, a2, a3, a4, a5)
				if (math.type(a1) == "integer") and (math.type(a2) == "integer") and (math.type(a3) == "integer") and (math.type(a4) == "integer") and (math.type(a5) == "integer") then
					return aprs_packet_telemetry_set_analog(self.Handle, a1, a2, a3, a4, a5) and true or false;
				end

				return aprs_packet_telemetry_set_analog_float(self.Handle, a1, a2, a3, a4, a5) and true or false;
			end
			function packet:SetTelemetryComment(value)
				return aprs_packet_telemetry_set_comment(self.Handle, value) and true or false;
			end
			function packet:SetTelemetryDigital(value)
				return aprs_packet_telemetry_set_digital(self.Handle, value) and true or false;
			end
			function packet:SetTelemetrySequence(value)
				return aprs_packet_telemetry_set_sequence(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_MAP_FEATURE then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_GRID_BEACON then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_THIRD_PARTY then
		function packet:GetThirdPartyContent()
			local value = aprs_packet_third_party_get_content(self.Handle);

			return tostring(value);
		end

		if not read_only then
			function packet:SetThirdPartyContent(value)
				return aprs_packet_third_party_set_content(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_MICROFINDER then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_USER_DEFINED then
		function packet:GetUserDefinedID()
			local value = aprs_packet_user_defined_get_id(self.Handle);

			return tostring(value);
		end
		function packet:GetUserDefinedData()
			local value = aprs_packet_user_defined_get_data(self.Handle);

			return tostring(value);
		end
		function packet:GetUserDefinedType()
			local value = aprs_packet_user_defined_get_type(self.Handle);

			return tostring(value);
		end

		if not read_only then
			function packet:SetUserDefinedID(value)
				return aprs_packet_user_defined_set_id(self.Handle, value) and true or false;
			end
			function packet:SetUserDefinedData(value)
				return aprs_packet_user_defined_set_data(self.Handle, value) and true or false;
			end
			function packet:SetUserDefinedType(value)
				return aprs_packet_user_defined_set_type(self.Handle, value) and true or false;
			end
		end
	elseif type == APRS.PACKET_TYPE_SHELTER_TIME then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_STATION_CAPABILITIES then
		-- // TODO: implement
	elseif type == APRS.PACKET_TYPE_MAIDENHEAD_GRID_BEACON then
		-- // TODO: implement
	end

	return packet;
end
-- @return packet
function APRS.Packet.InitFromString(value)
	local handle = aprs_packet_init_from_string(value);

	if not handle then
		return nil;
	end

	return APRS.Packet.InitFromHandle(handle, false, true);
end

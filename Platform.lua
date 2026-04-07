Platform       = {};
Platform.Unix  = nil;
Platform.Linux = nil;
Platform.Win32 = nil;

-- @return result
function Platform.ShellExec(string)
	local handle = io.popen(string);

	if not handle then
		return nil;
	end

	local result = handle:read('a');

	handle:close();

	return tostring(result);
end

if PLATFORM_UNIX then
	Platform.Unix = {};
elseif PLATFORM_LINUX then
	Platform.Linux             = {};
	Platform.Linux.GPIO        = {};
	Platform.Linux.GPIO.Low    = 0;
	Platform.Linux.GPIO.High   = 1;
	Platform.Linux.GPIO.Input  = 0;
	Platform.Linux.GPIO.Output = 1;

	-- @return value
	function Platform.Linux.gpioget(chip, pin, no_change)
		local result = Platform.ShellExec(string.format('gpioget %s-c %s %s', (no_change and '-a ' or ''), chip, pin));

		if not result then
			return nil;
		end

		local match_pin, match_status = result:match('"([^"]+)"=(%S+)');

		if not match_pin or not match_status then
			return nil;
		end

		return (match_status == 'active') and Platform.Linux.GPIO.High or Platform.Linux.GPIO.Low;
	end
	function Platform.Linux.gpioset(chip, pin, value)
		if (value ~= Platform.Linux.GPIO.Low) and (value ~= Platform.Linux.GPIO.High) then
			return false;
		end

		local result = Platform.ShellExec(string.format('gpioset -t 0 -c %s %s=%u', chip, pin, value));

		if not result then
			return false;
		end

		return #result == 0;
	end
	-- @return direction
	function Platform.Linux.gpioinfo(chip, pin)
		local result = Platform.ShellExec(string.format('gpioinfo -c %s %s', chip, pin));

		if not result then
			return nil;
		end

		local match_chip, match_chip_number, match_pin, match_direction = result:match('(%S+)%s+(%S+)%s+"(%S+)"%s+(%S+)');

		if not match_chip or not match_chip_number or not match_pin or not match_direction then
			return nil;
		end

		return (match_direction == 'output') and Platform.Linux.GPIO.Output or Platform.Linux.GPIO.Input;
	end

	function Platform.Linux.GPIO.Init(chip, pin, direction, value)
		if type(pin) ~= 'string' then
			return nil;
		end

		if type(chip) ~= 'string' then
			return nil;
		end

		local gpio     = {};
		gpio.Pin       = pin;
		gpio.Chip      = chip;
		gpio.Value     = -1;
		gpio.Direction = -1;

		function gpio:Get()
			if self.Direction == Platform.Linux.GPIO.Input then
				return Platform.Linux.gpioget(self.Chip, self.Pin, true);
			end

			return self.Value;
		end
		function gpio:GetDirection()
			return self.Direction;
		end

		function gpio:Set(value)
			if not Platform.Linux.gpioset(self.Chip, self.Pin, value) then
				return false;
			end

			self.Value     = value;
			self.Direction = Platform.Linux.GPIO.Output;

			return true;
		end
		function gpio:SetDirection(direction, value)
			if direction == Platform.Linux.GPIO.Input then
				if not Platform.Linux.gpioget(self.Chip, self.Pin) then
					return false;
				end

				self.Direction = Platform.Linux.GPIO.Input;

				return true;
			elseif direction == Platform.Linux.GPIO.Output then
				if value ~= nil then
					if not Platform.Linux.gpioset(self.Chip, self.Pin, value) then
						return false;
					end

					self.Value     = value;
					self.Direction = Platform.Linux.GPIO.Output;

					return true;
				end

				if not Platform.Linux.gpioset(self.Chip, self.Pin, self.Value) then
					return false;
				end

				self.Direction = Platform.Linux.GPIO.Output;

				return true;
			end

			return false;
		end

		if direction == Platform.Linux.GPIO.Input then
			gpio.Value     = Platform.Linux.gpioget(chip, pin);
			gpio.Direction = Platform.Linux.GPIO.Input;

			if not gpio.Value then
				return nil;
			end
		elseif direction == Platform.Linux.GPIO.Output then
			if not Platform.Linux.gpioset(chip, pin, value) then
				return nil;
			end

			gpio.Value     = value;
			gpio.Direction = Platform.Linux.GPIO.Output;
		else
			gpio.Direction = Platform.Linux.gpioinfo(chip, pin);

			if not gpio.Direction then
				return nil;
			end

			if gpio.Direction == Platform.Linux.GPIO.Input then
				gpio.Value     = Platform.Linux.gpioget(chip, pin, true);
				gpio.Direction = Platform.Linux.gpioinfo(chip, pin);

				if not gpio.Value or not gpio.Direction then
					return nil;
				end
			end
		end

		return gpio;
	end
	-- @param callback(chip, pin, direction, params)
	function Platform.Linux.GPIO.Enumerate(callback)
		local result = Platform.ShellExec(string.format('gpioinfo'));

		if not result then
			return false;
		end

		local chip = nil;

		for line in result:gmatch('([^\n]*)\n?') do
			local match_chip, match_lines = line:match('(%S+)%s+-%s+(%d+) lines:');

			if match_chip then
				chip = match_chip;
			elseif chip ~= nil then
				local match_pin, match_direction, match_params = line:match('%s+line%s+%d+:%s+"(%S+)"%s+(%S+)%s*(%S*)');

				if match_pin and match_direction and match_params then
					callback(chip, match_pin, match_direction, match_params);
				end
			end
		end

		return true;
	end
elseif PLATFORM_WIN32 then
	Platform.Win32 = {};
end

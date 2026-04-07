require('Platform');

local pin  = 'GPIO15';
local chip = 'gpiochip0';
local gpio = Platform.GPIO.Init(chip, pin);

if not gpio then
	error(string.format('Error opening %s.%s', chip, pin));
end

if gpio:GetDirection() ~= Platform.GPIO.Input then
	print(string.format('Switching %s.%s to input', chip, pin));

	if not gpio:SetDirection(Platform.GPIO.Input) then
		error(string.format('Error setting %s.%s direction', chip, pin));
	end
end

repeat
	local value = gpio:Get();

	print(string.format('Value: %s', (value == Platform.GPIO.Low) and 'Low' or 'High'));

	if not value then
		error(string.format('Error reading %s.%s', chip, pin));
	end
until not value;

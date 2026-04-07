#include <LuaCPP.hpp>
#include <APRService.hpp>

#include <string>
#include <utility>
#include <iostream>

#if defined(PLATFORM_UNIX) || defined(PLATFORM_LINUX)
	#include <ctime>
#elif defined(PLATFORM_WIN32)
	#include <Windows.h>

	#undef LoadLibrary
#endif

#define INT_TO_POINTER(value) ((void*)(uintptr_t)value)
#define POINTER_TO_INT(value) ((int)(uintptr_t)value)

LuaCPP lua;

// station, is_repeated
typedef std::tuple<const char*, bool>                                                                                                                                                                                                                        lua_aprs_path_node;

// day, hour, minute
typedef std::tuple<uint8_t, uint8_t, uint8_t>                                                                                                                                                                                                                lua_aprs_time_dhm;
// hour, minute, second
typedef std::tuple<uint8_t, uint8_t, uint8_t>                                                                                                                                                                                                                lua_aprs_time_hms;
// month, day, hour, minute
typedef std::tuple<uint8_t, uint8_t, uint8_t, uint8_t>                                                                                                                                                                                                       lua_aprs_time_mdhm;

// eqn1_a, eqn1_b, eqn1_c, eqn2_a, eqn2_b, eqn2_c, eqn3_a, eqn3_b, eqn3_c, eqn4_a, eqn4_b, eqn4_c, eqn5_a, eqn5_b, eqn5_c
typedef std::tuple<float, float, float, float, float, float, float, float, float, float, float, float, float, float, float>                                                                                                                                  lua_aprs_packet_telemetry_eqns;
// unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8, unit9, unit10, unit11, unit12, unit13
typedef std::tuple<std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view> lua_aprs_packet_telemetry_units;
// param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13
typedef std::tuple<std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view, std::string_view> lua_aprs_packet_telemetry_params;
// value1, value2, value3, value4, value5
typedef std::tuple<uint8_t, uint8_t, uint8_t, uint8_t, uint8_t>                                                                                                                                                                                              lua_aprs_packet_telemetry_analog;
// value1, value2, value3, value4, value5
typedef std::tuple<float, float, float, float, float>                                                                                                                                                                                                        lua_aprs_packet_telemetry_analog_float;

// latitude, longitude, altitude, speed, course
typedef std::tuple<float, float, int32_t, uint16_t, uint16_t>                                                                                                                                                                                                lua_aprservice_position;

// @return true to reschedule
typedef LuaCPP::Function<bool(bool is_canceled, uint32_t seconds)>                                                                                                                                                                                           lua_aprservice_task_handler;
typedef LuaCPP::Function<void(aprservice_event_information* event)>                                                                                                                                                                                          lua_aprservice_event_handler;
typedef LuaCPP::Function<void(aprservice_command* command, aprs_packet* packet, std::string_view sender, std::string_view name, std::string_view args)>                                                                                                      lua_aprservice_command_handler;
// @return true to accept command
typedef LuaCPP::Function<bool(aprservice_command* command, aprs_packet* packet, std::string_view sender, std::string_view name, std::string_view args)>                                                                                                      lua_aprservice_command_filter_handler;

typedef LuaCPP::Function<void(APRSERVICE_MESSAGE_ERRORS error)>                                                                                                                                                                                              lua_aprservice_message_callback;

// type
typedef std::tuple<APRSERVICE_EVENTS>                                                                                                                                                                                                                        lua_aprservice_event_information_connect;
// type
typedef std::tuple<APRSERVICE_EVENTS>                                                                                                                                                                                                                        lua_aprservice_event_information_disconnect;
// type, message, success, verified
typedef std::tuple<APRSERVICE_EVENTS, const char*, bool, bool>                                                                                                                                                                                               lua_aprservice_event_information_authenticate;
// type, packet
typedef std::tuple<APRSERVICE_EVENTS, aprs_packet*>                                                                                                                                                                                                          lua_aprservice_event_information_receive_packet;
// type, packet, id, sender, destination, content
typedef std::tuple<APRSERVICE_EVENTS, aprs_packet*, const char*, const char*, const char*, const char*>                                                                                                                                                      lua_aprservice_event_information_receive_message;
// type, content
typedef std::tuple<APRSERVICE_EVENTS, const char*>                                                                                                                                                                                                           lua_aprservice_event_information_receive_server_message;

void                                                    lua_sleep(uint32_t milliseconds)
{
#if defined(PLATFORM_UNIX) || defined(PLATFORM_LINUX)
	timespec ts =
	{
		.tv_sec = milliseconds / 1000,
		.tv_nsec = (milliseconds % 1000) * 1000000
	};

	nanosleep(&ts, &ts);
#elif defined(PLATFORM_WIN32)
	Sleep(milliseconds);
#endif
}

lua_aprs_path_node                                      lua_aprs_path_get_at(aprs_path* path, uint8_t index)
{
	lua_aprs_path_node value(nullptr, false);

	if (auto node = aprs_path_get_at(path, index))
	{
		std::get<0>(value) = node->station;
		std::get<1>(value) = node->repeated;
	}

	return value;
}

lua_aprs_time_dhm                                       lua_aprs_time_get_dhm(const aprs_time* time)
{
	lua_aprs_time_dhm value(0, 0, 0);

	aprs_time_get_dhm(time, &std::get<0>(value), &std::get<1>(value), &std::get<2>(value));

	return value;
}
lua_aprs_time_hms                                       lua_aprs_time_get_hms(const aprs_time* time)
{
	lua_aprs_time_hms value(0, 0, 0);

	aprs_time_get_hms(time, &std::get<0>(value), &std::get<1>(value), &std::get<2>(value));

	return value;
}
lua_aprs_time_mdhm                                      lua_aprs_time_get_mdhm(const aprs_time* time)
{
	lua_aprs_time_mdhm value(0, 0, 0, 0);

	aprs_time_get_mdhm(time, &std::get<0>(value), &std::get<1>(value), &std::get<2>(value), &std::get<3>(value));

	return value;
}

lua_aprs_packet_telemetry_analog                        lua_aprs_packet_telemetry_get_analog(aprs_packet* packet)
{
	lua_aprs_packet_telemetry_analog value(0, 0, 0, 0, 0);

	if (auto values = aprs_packet_telemetry_get_analog(packet))
	{
		if (values[0]) std::get<0>(value) = *values[0];
		if (values[1]) std::get<1>(value) = *values[1];
		if (values[2]) std::get<2>(value) = *values[2];
		if (values[3]) std::get<3>(value) = *values[3];
		if (values[4]) std::get<4>(value) = *values[4];
	}

	return value;
}
lua_aprs_packet_telemetry_analog_float                  lua_aprs_packet_telemetry_get_analog_float(aprs_packet* packet)
{
	lua_aprs_packet_telemetry_analog_float value(0.0f, 0.0f, 0.0f, 0.0f, 0.0f);

	if (auto values = aprs_packet_telemetry_get_analog_float(packet))
	{
		if (values[0]) std::get<0>(value) = *values[0];
		if (values[1]) std::get<1>(value) = *values[1];
		if (values[2]) std::get<2>(value) = *values[2];
		if (values[3]) std::get<3>(value) = *values[3];
		if (values[4]) std::get<4>(value) = *values[4];
	}

	return value;
}
template<size_t I>
constexpr bool                                          lua_aprs_packet_telemetry_populate_eqn(lua_aprs_packet_telemetry_eqns& value, const aprs_telemetry_eqn** eqns)
{
	if (auto eqn = eqns[I])
	{
		std::get<(I * 3) + 0>(value) = eqn->a;
		std::get<(I * 3) + 1>(value) = eqn->b;
		std::get<(I * 3) + 2>(value) = eqn->c;

		return true;
	}

	return false;
}
template<size_t ... I>
constexpr void                                          lua_aprs_packet_telemetry_populate_eqns(lua_aprs_packet_telemetry_eqns& value, const aprs_telemetry_eqn** eqns, std::index_sequence<I ...>)
{
	(lua_aprs_packet_telemetry_populate_eqn<I>(value, eqns) && ...);
}
lua_aprs_packet_telemetry_eqns                          lua_aprs_packet_telemetry_get_eqns(aprs_packet* packet)
{
	lua_aprs_packet_telemetry_eqns value;

	if (auto eqns = aprs_packet_telemetry_get_eqns(packet))
		lua_aprs_packet_telemetry_populate_eqns(value, eqns, std::make_index_sequence<5> {});

	return value;
}
template<size_t I>
constexpr bool                                          lua_aprs_packet_telemetry_populate_unit(lua_aprs_packet_telemetry_units& value, const char** units)
{
	if (auto unit = units[I])
	{
		std::get<I>(value) = unit;

		return true;
	}

	return false;
}
template<size_t ... I>
constexpr void                                          lua_aprs_packet_telemetry_populate_units(lua_aprs_packet_telemetry_units& value, const char** units, std::index_sequence<I ...>)
{
	(lua_aprs_packet_telemetry_populate_unit<I>(value, units) && ...);
}
lua_aprs_packet_telemetry_units                         lua_aprs_packet_telemetry_get_units(aprs_packet* packet)
{
	lua_aprs_packet_telemetry_units value;

	if (auto units = aprs_packet_telemetry_get_units(packet))
		lua_aprs_packet_telemetry_populate_units(value, units, std::make_index_sequence<13> {});

	return value;
}
template<size_t I>
constexpr bool                                          lua_aprs_packet_telemetry_populate_param(lua_aprs_packet_telemetry_params& value, const char** params)
{
	if (auto param = params[I])
	{
		std::get<I>(value) = param;

		return true;
	}

	return false;
}
template<size_t ... I>
constexpr void                                          lua_aprs_packet_telemetry_populate_params(lua_aprs_packet_telemetry_params& value, const char** params, std::index_sequence<I ...>)
{
	(lua_aprs_packet_telemetry_populate_param<I>(value, params) && ...);
}
lua_aprs_packet_telemetry_params                        lua_aprs_packet_telemetry_get_params(aprs_packet* packet)
{
	lua_aprs_packet_telemetry_params value;

	if (auto params = aprs_packet_telemetry_get_params(packet))
		lua_aprs_packet_telemetry_populate_params(value, params, std::make_index_sequence<13> {});

	return value;
}

lua_aprservice_position                                 lua_aprservice_get_position(aprservice* service)
{
	lua_aprservice_position value(0.0f, 0.0f, 0, 0, 0);

	aprservice_get_position(service, &std::get<0>(value), &std::get<1>(value), &std::get<2>(value), &std::get<3>(value), &std::get<4>(value));

	return value;
}

lua_aprservice_event_handler                            lua_aprservice_get_event_handler(aprservice* service, APRSERVICE_EVENTS event)
{
	lua_aprservice_event_handler handler;
	aprservice_event_handler     handler_c;
	void*                        handler_param_c;

	if (aprservice_get_event_handler(service, event, &handler_c, &handler_param_c) && handler_c)
		handler = lua_aprservice_event_handler(lua, POINTER_TO_INT(handler_param_c), false);

	return handler;
}
lua_aprservice_event_handler                            lua_aprservice_get_default_event_handler(aprservice* service)
{
	lua_aprservice_event_handler handler;
	aprservice_event_handler     handler_c;
	void*                        handler_param_c;

	if (aprservice_get_default_event_handler(service, &handler_c, &handler_param_c), handler_c)
		handler = lua_aprservice_event_handler(lua, POINTER_TO_INT(handler_param_c), false);

	return handler;
}

void                                                    lua_aprservice_event_handler_detour(aprservice* service, aprservice_event_information* event, void* param)
{
	lua_aprservice_event_handler(lua, POINTER_TO_INT(param), false).Execute(event);
}
bool                                                    lua_aprservice_set_event_handler(aprservice* service, APRSERVICE_EVENTS event, lua_aprservice_event_handler handler)
{
	void*                    prev_param;
	aprservice_event_handler prev_handler;

	aprservice_get_event_handler(service, event, &prev_handler, &prev_param);

	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, handler.GetReference()) != LUA_TFUNCTION)
		return false;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return false;
	}

	if (!aprservice_set_event_handler(service, event, &lua_aprservice_event_handler_detour, INT_TO_POINTER(reference)))
	{
		luaL_unref(lua, LUA_REGISTRYINDEX, reference);

		return false;
	}

	if (prev_handler)
		luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(prev_param));

	return true;
}

void                                                    lua_aprservice_default_event_handler_detour(aprservice* service, aprservice_event_information* event, void* param)
{
	lua_aprservice_event_handler(lua, POINTER_TO_INT(param), false).Execute(event);
}
bool                                                    lua_aprservice_set_default_event_handler(aprservice* service, lua_aprservice_event_handler handler)
{
	void*                    prev_param;
	aprservice_event_handler prev_handler;

	aprservice_get_default_event_handler(service, &prev_handler, &prev_param);

	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, handler.GetReference()) != LUA_TFUNCTION)
		return false;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return false;
	}

	aprservice_set_default_event_handler(service, &lua_aprservice_default_event_handler_detour, INT_TO_POINTER(reference));

	if (prev_handler)
		luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(prev_param));

	return true;
}

void                                                    lua_aprservice_message_callback_detour(aprservice* service, APRSERVICE_MESSAGE_ERRORS error, void* param)
{
	lua_aprservice_message_callback(lua, POINTER_TO_INT(param), true).Execute(error);
}
bool                                                    lua_aprservice_send_message(aprservice* service, std::string_view destination, std::string_view content, uint32_t timeout, lua_aprservice_message_callback callback)
{
	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, callback.GetReference()) != LUA_TFUNCTION)
		return false;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return false;
	}

	if (!aprservice_send_message(service, destination.data(), content.data(), timeout, &lua_aprservice_message_callback_detour, INT_TO_POINTER(reference)))
	{
		luaL_unref(lua, LUA_REGISTRYINDEX, reference);

		return false;
	}

	return true;
}
bool                                                    lua_aprservice_send_message_ex(aprservice* service, std::string_view destination, std::string_view content, const char* id, uint32_t timeout, lua_aprservice_message_callback callback)
{
	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, callback.GetReference()) != LUA_TFUNCTION)
		return false;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return false;
	}

	if (!aprservice_send_message_ex(service, destination.data(), content.data(), id, timeout, &lua_aprservice_message_callback_detour, INT_TO_POINTER(reference)))
	{
		luaL_unref(lua, LUA_REGISTRYINDEX, reference);

		return false;
	}

	return true;
}

void                                                    lua_aprservice_task_handler_detour(aprservice* service, aprservice_task_information* task, void* param)
{
	if (!(task->reschedule = lua_aprservice_task_handler(lua, POINTER_TO_INT(param), false).Execute(task->is_canceled, task->seconds)))
		luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(param));
}
aprservice_task*                                        lua_aprservice_task_schedule(aprservice* service, uint32_t seconds, lua_aprservice_task_handler handler)
{
	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, handler.GetReference()) != LUA_TFUNCTION)
		return nullptr;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return nullptr;
	}

	aprservice_task* task;

	if (!(task = aprservice_task_schedule(service, seconds, &lua_aprservice_task_handler_detour, INT_TO_POINTER(reference))))
	{
		luaL_unref(lua, LUA_REGISTRYINDEX, reference);

		return nullptr;
	}

	return task;
}
void                                                    lua_aprservice_task_cancel(aprservice_task* task)
{
	aprservice_task_handler handler;
	void*                   handler_param;

	aprservice_task_get_handler(task, &handler, &handler_param);
	aprservice_task_cancel(task);

	luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(handler_param));
}
lua_aprservice_task_handler                             lua_aprservice_task_get_handler(aprservice_task* task)
{
	aprservice_task_handler handler;
	void*                   handler_param;

	aprservice_task_get_handler(task, &handler, &handler_param);

	return lua_aprservice_task_handler(lua, POINTER_TO_INT(handler_param), false);
}

bool                                                    lua_aprservice_command_filter_detour(aprservice* service, aprservice_command* command, aprs_packet* packet, const char* sender, const char* name, const char* args, void* param)
{
	return lua_aprservice_command_filter_handler(lua, POINTER_TO_INT(param), false).Execute(command, packet, sender, name, args);
}
void                                                    lua_aprservice_command_handler_detour(aprservice* service, aprservice_command* command, aprs_packet* packet, const char* sender, const char* name, const char* args, void* param)
{
	lua_aprservice_command_handler(lua, POINTER_TO_INT(param), false).Execute(command, packet, sender, name, args);
}
aprservice_command*                                     lua_aprservice_command_register(aprservice* service, std::string_view name, const char* help, lua_aprservice_command_handler handler)
{
	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, handler.GetReference()) != LUA_TFUNCTION)
		return nullptr;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return nullptr;
	}

	aprservice_command* command;

	if (!(command = aprservice_command_register(service, name.data(), help, &lua_aprservice_command_handler_detour, INT_TO_POINTER(reference))))
	{
		luaL_unref(lua, LUA_REGISTRYINDEX, reference);

		return nullptr;
	}

	return command;
}
void                                                    lua_aprservice_command_unregister(aprservice_command* command)
{
	aprservice_command_filter_handler filter;
	void*                             filter_param;

	aprservice_command_handler        handler;
	void*                             handler_param;

	aprservice_command_get_filter(command, &filter, &filter_param);
	aprservice_command_get_handler(command, &handler, &handler_param);
	aprservice_command_unregister(command);

	if (filter)
		luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(filter_param));

	luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(handler_param));
}
lua_aprservice_command_filter_handler                   lua_aprservice_command_get_filter(aprservice_command* command)
{
	lua_aprservice_command_filter_handler handler;
	aprservice_command_filter_handler     handler_c;
	void*                                 handler_param_c;

	aprservice_command_get_filter(command, &handler_c, &handler_param_c);

	if (handler_c)
		handler = lua_aprservice_command_filter_handler(lua, POINTER_TO_INT(handler_param_c), false);

	return handler;
}
lua_aprservice_command_handler                          lua_aprservice_command_get_handler(aprservice_command* command)
{
	aprservice_command_handler handler;
	void*                      handler_param;

	aprservice_command_get_handler(command, &handler, &handler_param);

	return lua_aprservice_command_handler(lua, POINTER_TO_INT(handler_param), false);
}
bool                                                    lua_aprservice_command_set_filter(aprservice_command* command, lua_aprservice_command_filter_handler handler)
{
	void*                             prev_param;
	aprservice_command_filter_handler prev_handler;

	aprservice_command_get_filter(command, &prev_handler, &prev_param);

	if (lua_rawgeti(lua, LUA_REGISTRYINDEX, handler.GetReference()) != LUA_TFUNCTION)
		return false;

	int reference;

	if ((reference = luaL_ref(lua, LUA_REGISTRYINDEX)) == LUA_REFNIL)
	{
		lua_pop(lua, 1);

		return false;
	}

	aprservice_command_set_filter(command, &lua_aprservice_command_filter_detour, INT_TO_POINTER(reference));

	if (prev_handler)
		luaL_unref(lua, LUA_REGISTRYINDEX, POINTER_TO_INT(prev_param));

	return true;
}

APRSERVICE_EVENTS                                       lua_aprservice_event_information_get_type(aprservice_event_information* event)
{
	return event->type;
}
lua_aprservice_event_information_connect                lua_aprservice_event_information_get_connect(aprservice_event_information* event)
{
	lua_aprservice_event_information_connect value(event->type);

	if (event->type == APRSERVICE_EVENT_CONNECT)
		;

	return value;
}
lua_aprservice_event_information_disconnect             lua_aprservice_event_information_get_disconnect(aprservice_event_information* event)
{
	lua_aprservice_event_information_disconnect value(event->type);

	if (event->type == APRSERVICE_EVENT_DISCONNECT)
		;

	return value;
}
lua_aprservice_event_information_authenticate           lua_aprservice_event_information_get_authenticate(aprservice_event_information* event)
{
	lua_aprservice_event_information_authenticate value(event->type, nullptr, false, false);

	if (event->type == APRSERVICE_EVENT_AUTHENTICATE)
	{
		std::get<1>(value) = ((aprservice_event_information_authenticate*)event)->message;
		std::get<2>(value) = ((aprservice_event_information_authenticate*)event)->success;
		std::get<3>(value) = ((aprservice_event_information_authenticate*)event)->verified;
	}

	return value;
}
lua_aprservice_event_information_receive_packet         lua_aprservice_event_information_get_receive_packet(aprservice_event_information* event)
{
	lua_aprservice_event_information_receive_packet value(event->type, nullptr);

	if (event->type == APRSERVICE_EVENT_RECEIVE_PACKET)
		std::get<1>(value) = ((aprservice_event_information_receive_packet*)event)->packet;

	return value;
}
lua_aprservice_event_information_receive_message        lua_aprservice_event_information_get_receive_message(aprservice_event_information* event)
{
	lua_aprservice_event_information_receive_message value(event->type, nullptr, nullptr, nullptr, nullptr, nullptr);

	if (event->type == APRSERVICE_EVENT_RECEIVE_MESSAGE)
	{
		std::get<1>(value) = ((aprservice_event_information_receive_message*)event)->packet;
		std::get<2>(value) = ((aprservice_event_information_receive_message*)event)->id;
		std::get<3>(value) = ((aprservice_event_information_receive_message*)event)->sender;
		std::get<4>(value) = ((aprservice_event_information_receive_message*)event)->destination;
		std::get<5>(value) = ((aprservice_event_information_receive_message*)event)->content;
	}

	return value;
}
lua_aprservice_event_information_receive_server_message lua_aprservice_event_information_get_receive_server_message(aprservice_event_information* event)
{
	lua_aprservice_event_information_receive_server_message value(event->type, nullptr);

	if (event->type == APRSERVICE_EVENT_RECEIVE_SERVER_MESSAGE)
		std::get<1>(value) = ((aprservice_event_information_receive_server_message*)event)->content;

	return value;
}

#define lua_register_global(value)          lua_register_global_ex(#value, value)
#define lua_register_global_ex(name, value) lua.SetGlobal<value>(name)

void lua_register_globals()
{
	lua_register_global_ex("PLATFORM_UNIX",  false);
	lua_register_global_ex("PLATFORM_LINUX", false);
	lua_register_global_ex("PLATFORM_WIN32", false);

#if defined(PLATFORM_UNIX)
	lua_register_global_ex("PLATFORM_UNIX",  true);
#elif defined(PLATFORM_LINUX)
	lua_register_global_ex("PLATFORM_LINUX", true);
#elif defined(PLATFORM_WIN32)
	lua_register_global_ex("PLATFORM_WIN32", true);
#endif

	lua_register_global_ex("sleep", lua_sleep);
}
void lua_register_globals_aprs()
{
	lua_register_global(APRS_TIME_DHM);
	lua_register_global(APRS_TIME_HMS);
	lua_register_global(APRS_TIME_MDHM);

	lua_register_global(APRS_DISTANCE_FEET);
	lua_register_global(APRS_DISTANCE_MILES);
	lua_register_global(APRS_DISTANCE_METERS);
	lua_register_global(APRS_DISTANCE_KILOMETERS);

	lua_register_global(APRS_PACKET_TYPE_GPS);
	lua_register_global(APRS_PACKET_TYPE_RAW);
	lua_register_global(APRS_PACKET_TYPE_ITEM);
	lua_register_global(APRS_PACKET_TYPE_TEST);
	lua_register_global(APRS_PACKET_TYPE_QUERY);
	lua_register_global(APRS_PACKET_TYPE_OBJECT);
	lua_register_global(APRS_PACKET_TYPE_STATUS);
	lua_register_global(APRS_PACKET_TYPE_MESSAGE);
	lua_register_global(APRS_PACKET_TYPE_WEATHER);
	lua_register_global(APRS_PACKET_TYPE_POSITION);
	lua_register_global(APRS_PACKET_TYPE_TELEMETRY);
	lua_register_global(APRS_PACKET_TYPE_MAP_FEATURE);
	lua_register_global(APRS_PACKET_TYPE_GRID_BEACON);
	lua_register_global(APRS_PACKET_TYPE_THIRD_PARTY);
	lua_register_global(APRS_PACKET_TYPE_MICROFINDER);
	lua_register_global(APRS_PACKET_TYPE_USER_DEFINED);
	lua_register_global(APRS_PACKET_TYPE_SHELTER_TIME);
	lua_register_global(APRS_PACKET_TYPE_STATION_CAPABILITIES);
	lua_register_global(APRS_PACKET_TYPE_MAIDENHEAD_GRID_BEACON);

	lua_register_global(APRS_MESSAGE_TYPE_ACK);
	lua_register_global(APRS_MESSAGE_TYPE_REJECT);
	lua_register_global(APRS_MESSAGE_TYPE_MESSAGE);
	lua_register_global(APRS_MESSAGE_TYPE_BULLETIN);

	lua_register_global(APRS_MIC_E_MESSAGE_EMERGENCY);
	lua_register_global(APRS_MIC_E_MESSAGE_PRIORITY);
	lua_register_global(APRS_MIC_E_MESSAGE_SPECIAL);
	lua_register_global(APRS_MIC_E_MESSAGE_COMMITTED);
	lua_register_global(APRS_MIC_E_MESSAGE_RETURNING);
	lua_register_global(APRS_MIC_E_MESSAGE_IN_SERVICE);
	lua_register_global(APRS_MIC_E_MESSAGE_EN_ROUTE);
	lua_register_global(APRS_MIC_E_MESSAGE_OFF_DUTY);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_0);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_1);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_2);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_3);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_4);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_5);
	lua_register_global(APRS_MIC_E_MESSAGE_CUSTOM_6);

	lua_register_global(APRS_POSITION_FLAG_TIME);
	lua_register_global(APRS_POSITION_FLAG_MIC_E);
	lua_register_global(APRS_POSITION_FLAG_COMPRESSED);
	lua_register_global(APRS_POSITION_FLAG_MESSAGING_ENABLED);

	lua_register_global(APRS_TELEMETRY_TYPE_U8);
	lua_register_global(APRS_TELEMETRY_TYPE_FLOAT);
	lua_register_global(APRS_TELEMETRY_TYPE_PARAMS);
	lua_register_global(APRS_TELEMETRY_TYPE_UNITS);
	lua_register_global(APRS_TELEMETRY_TYPE_EQNS);
	lua_register_global(APRS_TELEMETRY_TYPE_BITS);

	lua_register_global(aprs_path_init);
	lua_register_global(aprs_path_init_from_copy);
	lua_register_global(aprs_path_init_from_string);
	lua_register_global(aprs_path_deinit);
	lua_register_global_ex("aprs_path_get_at", lua_aprs_path_get_at);
	lua_register_global(aprs_path_get_length);
	lua_register_global(aprs_path_get_capacity);
	lua_register_global(aprs_path_get_reference_count);
	lua_register_global(aprs_path_set);
	lua_register_global(aprs_path_pop);
	lua_register_global(aprs_path_push);
	lua_register_global(aprs_path_clear);
	lua_register_global(aprs_path_compare);
	lua_register_global(aprs_path_to_string);
	lua_register_global(aprs_path_add_reference);

	lua_register_global(aprs_time_now);
	lua_register_global(aprs_time_get_type);
	lua_register_global_ex("aprs_time_get_dhm", lua_aprs_time_get_dhm);
	lua_register_global_ex("aprs_time_get_hms", lua_aprs_time_get_hms);
	lua_register_global_ex("aprs_time_get_mdhm", lua_aprs_time_get_mdhm);
	lua_register_global(aprs_time_compare);

	lua_register_global(aprs_packet_init);
	lua_register_global(aprs_packet_init_from_copy);
	lua_register_global(aprs_packet_init_from_string);
	lua_register_global(aprs_packet_deinit);
	lua_register_global(aprs_packet_get_q);
	lua_register_global(aprs_packet_get_type);
	lua_register_global(aprs_packet_get_path);
	lua_register_global(aprs_packet_get_igate);
	lua_register_global(aprs_packet_get_tocall);
	lua_register_global(aprs_packet_get_sender);
	lua_register_global(aprs_packet_get_content);
	lua_register_global(aprs_packet_get_reference_count);
	lua_register_global(aprs_packet_set_path);
	lua_register_global(aprs_packet_set_tocall);
	lua_register_global(aprs_packet_set_sender);
	lua_register_global(aprs_packet_set_content);
	lua_register_global(aprs_packet_compare);
	lua_register_global(aprs_packet_to_string);
	lua_register_global(aprs_packet_add_reference);

	lua_register_global(aprs_packet_gps_init);
	lua_register_global(aprs_packet_gps_get_nmea);
	lua_register_global(aprs_packet_gps_get_comment);
	lua_register_global(aprs_packet_gps_set_nmea);
	lua_register_global(aprs_packet_gps_set_comment);

	lua_register_global(aprs_packet_item_init);
	lua_register_global(aprs_packet_item_is_alive);
	lua_register_global(aprs_packet_item_is_compressed);
	lua_register_global(aprs_packet_item_get_name);
	lua_register_global(aprs_packet_item_get_comment);
	lua_register_global(aprs_packet_item_get_speed);
	lua_register_global(aprs_packet_item_get_course);
	lua_register_global(aprs_packet_item_get_altitude);
	lua_register_global(aprs_packet_item_get_latitude);
	lua_register_global(aprs_packet_item_get_longitude);
	lua_register_global(aprs_packet_item_get_symbol_table);
	lua_register_global(aprs_packet_item_get_symbol_table_key);
	lua_register_global(aprs_packet_item_set_alive);
	lua_register_global(aprs_packet_item_set_compressed);
	lua_register_global(aprs_packet_item_set_name);
	lua_register_global(aprs_packet_item_set_comment);
	lua_register_global(aprs_packet_item_set_speed);
	lua_register_global(aprs_packet_item_set_course);
	lua_register_global(aprs_packet_item_set_altitude);
	lua_register_global(aprs_packet_item_set_latitude);
	lua_register_global(aprs_packet_item_set_longitude);
	lua_register_global(aprs_packet_item_set_symbol);
	lua_register_global(aprs_packet_item_set_symbol_table);
	lua_register_global(aprs_packet_item_set_symbol_table_key);

	lua_register_global(aprs_packet_object_init);
	lua_register_global(aprs_packet_object_is_alive);
	lua_register_global(aprs_packet_object_is_compressed);
	lua_register_global(aprs_packet_object_get_time);
	lua_register_global(aprs_packet_object_get_name);
	lua_register_global(aprs_packet_object_get_comment);
	lua_register_global(aprs_packet_object_get_speed);
	lua_register_global(aprs_packet_object_get_course);
	lua_register_global(aprs_packet_object_get_altitude);
	lua_register_global(aprs_packet_object_get_latitude);
	lua_register_global(aprs_packet_object_get_longitude);
	lua_register_global(aprs_packet_object_get_symbol_table);
	lua_register_global(aprs_packet_object_get_symbol_table_key);
	lua_register_global(aprs_packet_object_set_time);
	lua_register_global(aprs_packet_object_set_alive);
	lua_register_global(aprs_packet_object_set_compressed);
	lua_register_global(aprs_packet_object_set_name);
	lua_register_global(aprs_packet_object_set_comment);
	lua_register_global(aprs_packet_object_set_speed);
	lua_register_global(aprs_packet_object_set_course);
	lua_register_global(aprs_packet_object_set_altitude);
	lua_register_global(aprs_packet_object_set_latitude);
	lua_register_global(aprs_packet_object_set_longitude);
	lua_register_global(aprs_packet_object_set_symbol);
	lua_register_global(aprs_packet_object_set_symbol_table);
	lua_register_global(aprs_packet_object_set_symbol_table_key);

	lua_register_global(aprs_packet_status_init);
	lua_register_global(aprs_packet_status_get_time);
	lua_register_global(aprs_packet_status_get_message);
	lua_register_global(aprs_packet_status_set_time);
	lua_register_global(aprs_packet_status_set_message);

	lua_register_global(aprs_packet_message_init);
	lua_register_global(aprs_packet_message_init_ack);
	lua_register_global(aprs_packet_message_init_reject);
	lua_register_global(aprs_packet_message_init_bulletin);
	lua_register_global(aprs_packet_message_get_id);
	lua_register_global(aprs_packet_message_get_type);
	lua_register_global(aprs_packet_message_get_content);
	lua_register_global(aprs_packet_message_get_destination);
	lua_register_global(aprs_packet_message_set_id);
	lua_register_global(aprs_packet_message_set_type);
	lua_register_global(aprs_packet_message_set_content);
	lua_register_global(aprs_packet_message_set_destination);

	lua_register_global(aprs_packet_weather_init);
	lua_register_global(aprs_packet_weather_get_time);
	lua_register_global(aprs_packet_weather_get_type);
	lua_register_global(aprs_packet_weather_get_software);
	lua_register_global(aprs_packet_weather_get_wind_speed);
	lua_register_global(aprs_packet_weather_get_wind_speed_gust);
	lua_register_global(aprs_packet_weather_get_wind_direction);
	lua_register_global(aprs_packet_weather_get_rainfall_last_hour);
	lua_register_global(aprs_packet_weather_get_rainfall_last_24_hours);
	lua_register_global(aprs_packet_weather_get_rainfall_since_midnight);
	lua_register_global(aprs_packet_weather_get_humidity);
	lua_register_global(aprs_packet_weather_get_temperature);
	lua_register_global(aprs_packet_weather_get_barometric_pressure);
	lua_register_global(aprs_packet_weather_set_time);
	lua_register_global(aprs_packet_weather_set_wind_speed);
	lua_register_global(aprs_packet_weather_set_wind_speed_gust);
	lua_register_global(aprs_packet_weather_set_wind_direction);
	lua_register_global(aprs_packet_weather_set_rainfall_last_hour);
	lua_register_global(aprs_packet_weather_set_rainfall_last_24_hours);
	lua_register_global(aprs_packet_weather_set_rainfall_since_midnight);
	lua_register_global(aprs_packet_weather_set_humidity);
	lua_register_global(aprs_packet_weather_set_temperature);
	lua_register_global(aprs_packet_weather_set_barometric_pressure);

	lua_register_global(aprs_packet_position_init);
	lua_register_global(aprs_packet_position_init_mic_e);
	lua_register_global(aprs_packet_position_init_compressed);
	lua_register_global(aprs_packet_position_is_mic_e);
	lua_register_global(aprs_packet_position_is_compressed);
	lua_register_global(aprs_packet_position_is_messaging_enabled);
	lua_register_global(aprs_packet_position_get_time);
	lua_register_global(aprs_packet_position_get_flags);
	lua_register_global(aprs_packet_position_get_comment);
	lua_register_global(aprs_packet_position_get_speed);
	lua_register_global(aprs_packet_position_get_course);
	lua_register_global(aprs_packet_position_get_altitude);
	lua_register_global(aprs_packet_position_get_latitude);
	lua_register_global(aprs_packet_position_get_longitude);
	lua_register_global(aprs_packet_position_get_symbol_table);
	lua_register_global(aprs_packet_position_get_symbol_table_key);
	lua_register_global(aprs_packet_position_get_mic_e_message);
	lua_register_global(aprs_packet_position_set_time);
	lua_register_global(aprs_packet_position_set_comment);
	lua_register_global(aprs_packet_position_set_speed);
	lua_register_global(aprs_packet_position_set_course);
	lua_register_global(aprs_packet_position_set_altitude);
	lua_register_global(aprs_packet_position_set_latitude);
	lua_register_global(aprs_packet_position_set_longitude);
	lua_register_global(aprs_packet_position_set_symbol);
	lua_register_global(aprs_packet_position_set_symbol_table);
	lua_register_global(aprs_packet_position_set_symbol_table_key);
	lua_register_global(aprs_packet_position_set_mic_e_message);
	lua_register_global(aprs_packet_position_enable_mic_e);
	lua_register_global(aprs_packet_position_enable_messaging);
	lua_register_global(aprs_packet_position_enable_compression);

	lua_register_global(aprs_packet_telemetry_init);
	lua_register_global(aprs_packet_telemetry_init_float);
	lua_register_global(aprs_packet_telemetry_init_bits);
	lua_register_global(aprs_packet_telemetry_init_eqns);
	lua_register_global(aprs_packet_telemetry_init_units);
	lua_register_global(aprs_packet_telemetry_init_params);
	lua_register_global(aprs_packet_telemetry_get_type);
	lua_register_global_ex("aprs_packet_telemetry_get_analog", lua_aprs_packet_telemetry_get_analog);
	lua_register_global_ex("aprs_packet_telemetry_get_analog_float", lua_aprs_packet_telemetry_get_analog_float);
	lua_register_global(aprs_packet_telemetry_get_bits);
	lua_register_global_ex("aprs_packet_telemetry_get_eqns", lua_aprs_packet_telemetry_get_eqns);
	lua_register_global_ex("aprs_packet_telemetry_get_units", lua_aprs_packet_telemetry_get_units);
	lua_register_global_ex("aprs_packet_telemetry_get_params", lua_aprs_packet_telemetry_get_params);
	lua_register_global(aprs_packet_telemetry_get_digital);
	lua_register_global(aprs_packet_telemetry_get_sequence);
	lua_register_global(aprs_packet_telemetry_get_comment);
	lua_register_global(aprs_packet_telemetry_set_bits);
	lua_register_global(aprs_packet_telemetry_set_analog);
	lua_register_global(aprs_packet_telemetry_set_analog_float);
	lua_register_global(aprs_packet_telemetry_set_digital);
	lua_register_global(aprs_packet_telemetry_set_sequence);
	lua_register_global(aprs_packet_telemetry_set_comment);

	lua_register_global(aprs_packet_user_defined_init);
	lua_register_global(aprs_packet_user_defined_get_id);
	lua_register_global(aprs_packet_user_defined_get_type);
	lua_register_global(aprs_packet_user_defined_get_data);
	lua_register_global(aprs_packet_user_defined_set_id);
	lua_register_global(aprs_packet_user_defined_set_type);
	lua_register_global(aprs_packet_user_defined_set_data);

	lua_register_global(aprs_packet_third_party_init);
	lua_register_global(aprs_packet_third_party_get_content);
	lua_register_global(aprs_packet_third_party_set_content);

	lua_register_global(aprs_distance);
	lua_register_global(aprs_distance_3d);

	lua_register_global(aprs_mic_e_message_to_string);
}
void lua_register_globals_aprservice()
{
	lua_register_global(APRSERVICE_EVENT_CONNECT);
	lua_register_global(APRSERVICE_EVENT_DISCONNECT);
	lua_register_global(APRSERVICE_EVENT_AUTHENTICATE);
	lua_register_global(APRSERVICE_EVENT_RECEIVE_PACKET);
	lua_register_global(APRSERVICE_EVENT_RECEIVE_MESSAGE);
	lua_register_global(APRSERVICE_EVENT_RECEIVE_SERVER_MESSAGE);

	lua_register_global(APRSERVICE_MESSAGE_ERROR_SUCCESS);
	lua_register_global(APRSERVICE_MESSAGE_ERROR_TIMEOUT);
	lua_register_global(APRSERVICE_MESSAGE_ERROR_REJECTED);
	lua_register_global(APRSERVICE_MESSAGE_ERROR_DISCONNECTED);

	lua_register_global(APRSERVICE_POSITION_TYPE_MIC_E);
	lua_register_global(APRSERVICE_POSITION_TYPE_POSITION);
	lua_register_global(APRSERVICE_POSITION_TYPE_POSITION_COMPRESSED);

	lua_register_global(aprservice_init);
	lua_register_global(aprservice_deinit);
	lua_register_global(aprservice_is_read_only);
	lua_register_global(aprservice_is_connected);
	lua_register_global(aprservice_is_authenticated);
	lua_register_global(aprservice_is_authenticating);
	lua_register_global(aprservice_is_monitoring_enabled);
	lua_register_global(aprservice_is_compression_enabled);
	lua_register_global(aprservice_get_path);
	lua_register_global(aprservice_get_time);
	lua_register_global(aprservice_get_comment);
	lua_register_global(aprservice_get_station);
	lua_register_global(aprservice_get_symbol_table);
	lua_register_global(aprservice_get_symbol_table_key);
	lua_register_global_ex("aprservice_get_position", lua_aprservice_get_position);
	lua_register_global(aprservice_get_position_type);
	lua_register_global(aprservice_get_command_prefix);
	lua_register_global(aprservice_get_connection_timeout);
	lua_register_global_ex("aprservice_get_event_handler", lua_aprservice_get_event_handler);
	lua_register_global_ex("aprservice_get_default_event_handler", lua_aprservice_get_default_event_handler);
	lua_register_global(aprservice_set_path);
	lua_register_global(aprservice_set_symbol);
	lua_register_global(aprservice_set_comment);
	lua_register_global(aprservice_set_position);
	lua_register_global(aprservice_set_position_type);
	lua_register_global_ex("aprservice_set_event_handler", lua_aprservice_set_event_handler);
	lua_register_global_ex("aprservice_set_default_event_handler", lua_aprservice_set_default_event_handler);
	lua_register_global(aprservice_set_command_prefix);
	lua_register_global(aprservice_set_connection_timeout);
	lua_register_global(aprservice_enable_monitoring);
	lua_register_global(aprservice_poll);
	lua_register_global(aprservice_send);
	lua_register_global(aprservice_send_raw);
	lua_register_global(aprservice_send_item);
	lua_register_global(aprservice_send_object);
	lua_register_global(aprservice_send_status);
	lua_register_global_ex("aprservice_send_message", lua_aprservice_send_message);
	lua_register_global_ex("aprservice_send_message_ex", lua_aprservice_send_message_ex);
	lua_register_global(aprservice_send_weather);
	lua_register_global(aprservice_send_position);
	lua_register_global(aprservice_send_position_ex);
	lua_register_global(aprservice_send_telemetry);
	lua_register_global(aprservice_send_telemetry_ex);
	lua_register_global(aprservice_send_telemetry_float);
	lua_register_global(aprservice_send_telemetry_float_ex);
	lua_register_global(aprservice_send_user_defined);
	lua_register_global(aprservice_send_third_party);
	lua_register_global(aprservice_connect_aprs_is);
	lua_register_global(aprservice_connect_kiss_tnc_tcp);
	lua_register_global(aprservice_connect_kiss_tnc_serial);
	lua_register_global(aprservice_disconnect);
	lua_register_global(aprservice_wait_for_io);

	lua_register_global_ex("aprservice_task_schedule", lua_aprservice_task_schedule);
	lua_register_global_ex("aprservice_task_cancel", lua_aprservice_task_cancel);
	lua_register_global_ex("aprservice_task_get_handler", lua_aprservice_task_get_handler);
	lua_register_global(aprservice_task_get_service);

	lua_register_global(aprservice_item_create);
	lua_register_global(aprservice_item_destroy);
	lua_register_global(aprservice_item_is_alive);
	lua_register_global(aprservice_item_is_compressed);
	lua_register_global(aprservice_item_get_service);
	lua_register_global(aprservice_item_get_name);
	lua_register_global(aprservice_item_get_comment);
	lua_register_global(aprservice_item_get_speed);
	lua_register_global(aprservice_item_get_course);
	lua_register_global(aprservice_item_get_altitude);
	lua_register_global(aprservice_item_get_latitude);
	lua_register_global(aprservice_item_get_longitude);
	lua_register_global(aprservice_item_get_symbol_table);
	lua_register_global(aprservice_item_get_symbol_table_key);
	lua_register_global(aprservice_item_set_symbol);
	lua_register_global(aprservice_item_set_comment);
	lua_register_global(aprservice_item_set_position);
	lua_register_global(aprservice_item_set_compressed);
	lua_register_global(aprservice_item_kill);
	lua_register_global(aprservice_item_announce);

	lua_register_global(aprservice_object_create);
	lua_register_global(aprservice_object_destroy);
	lua_register_global(aprservice_object_is_alive);
	lua_register_global(aprservice_object_is_compressed);
	lua_register_global(aprservice_object_get_service);
	lua_register_global(aprservice_object_get_name);
	lua_register_global(aprservice_object_get_comment);
	lua_register_global(aprservice_object_get_speed);
	lua_register_global(aprservice_object_get_course);
	lua_register_global(aprservice_object_get_altitude);
	lua_register_global(aprservice_object_get_latitude);
	lua_register_global(aprservice_object_get_longitude);
	lua_register_global(aprservice_object_get_symbol_table);
	lua_register_global(aprservice_object_get_symbol_table_key);
	lua_register_global(aprservice_object_set_symbol);
	lua_register_global(aprservice_object_set_comment);
	lua_register_global(aprservice_object_set_position);
	lua_register_global(aprservice_object_set_compressed);
	lua_register_global(aprservice_object_kill);
	lua_register_global(aprservice_object_announce);

	lua_register_global_ex("aprservice_command_register", lua_aprservice_command_register);
	lua_register_global_ex("aprservice_command_unregister", lua_aprservice_command_unregister);
	lua_register_global(aprservice_command_get_help);
	lua_register_global_ex("aprservice_command_get_filter", lua_aprservice_command_get_filter);
	lua_register_global_ex("aprservice_command_get_handler", lua_aprservice_command_get_handler);
	lua_register_global(aprservice_command_get_service);
	lua_register_global(aprservice_command_set_help);
	lua_register_global_ex("aprservice_command_set_filter", lua_aprservice_command_set_filter);

	lua_register_global_ex("aprservice_event_information_get_type", lua_aprservice_event_information_get_type);
	lua_register_global_ex("aprservice_event_information_get_connect", lua_aprservice_event_information_get_connect);
	lua_register_global_ex("aprservice_event_information_get_disconnect", lua_aprservice_event_information_get_disconnect);
	lua_register_global_ex("aprservice_event_information_get_authenticate", lua_aprservice_event_information_get_authenticate);
	lua_register_global_ex("aprservice_event_information_get_receive_packet", lua_aprservice_event_information_get_receive_packet);
	lua_register_global_ex("aprservice_event_information_get_receive_message", lua_aprservice_event_information_get_receive_message);
	lua_register_global_ex("aprservice_event_information_get_receive_server_message", lua_aprservice_event_information_get_receive_server_message);
}

bool main_execute_files(int argc, char* argv[])
{
	for (int i = 1; i < argc; ++i)
		try
		{
			if (!lua.RunFile(argv[i]))
			{
				std::cerr << "File not found: " << argv[i] << std::endl;

				return false;
			}
		}
		catch (const std::exception& e)
		{
			std::cerr << "Error running file: " << argv[i] << std::endl;
			std::cerr << e.what() << std::endl;

			return false;
		}

	return true;
}
bool main_execute_stdin()
{
	std::cout << "APRService.Lua" << std::endl;
	std::cout << LUA_COPYRIGHT << std::endl;

	std::string line;
	auto        get_next_line = [&line]()->bool
	{
		std::cout << "> ";

		// TODO: why is .operator bool() needed?
		return std::getline(std::cin, line).operator bool();
	};

	while (get_next_line())
	{
		try
		{
			lua.Run(line);
		}
		catch (const std::exception& e)
		{
			std::cerr << e.what() << std::endl;

			return false;
		}
	}

	return true;
}

int main(int argc, char* argv[])
{
	if (lua)
	{
		lua.LoadLibrary(LuaCPP::Libraries::All);

		lua_register_globals();
		lua_register_globals_aprs();
		lua_register_globals_aprservice();

		if (argc <= 1)
			main_execute_stdin();
		else
			main_execute_files(argc, argv);
	}

	return 0;
}

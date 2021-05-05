--[[
    ArenaLive [Core] is an unit frame framework for World of Warcraft.
    Copyright (C) 2014  Harald Böhm <harald@boehm.agency>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	ADDITIONAL PERMISSION UNDER GNU GPL VERSION 3 SECTION 7:
	As a special exception, the copyright holder of this add-on gives you
	permission to link this add-on with independent proprietary software,
	regardless of the license terms of the independent proprietary software.
]]

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

-- Create a table to store handlers:
ArenaLive.handlers = {};

-- Create base class table:
local Handler = {};

--[[ Method: ConstructHandler
	 Creates a new handler with a specified name and returns it.
		handlerName (string): Name of the new handler.
		isEventObject (boolean): If true, the handler will receive all needed methods to register for events etc.
		needsFrame (boolean): If true, the handler will be created as a frame instead of a normal table. Use this if your handler needs an OnUpdate script etc.
		frameType (string [optional]: The frame type that will be created if needFrame is true. Defaults to "Frame".
		frameName (string [optional]: Name the handler's frame will be assigned.
		frameParent (frame [optional]: Parent frame for the handler.
		inheritFrame (string [optional]): Name of a frame the new handler frame should inherit values from. So basically a frame template.
		RETURNS:
			The newly created handler object.
]]--
function ArenaLive:ConstructHandler(handlerName, isEventObject, needsFrame, frameType, frameName, frameParent, inheritFrame)

	ArenaLive:CheckArgs(handlerName, "string");

	if ( self.handlers[handlerName] ) then
		ArenaLive:Message(L["Couldn't construct handler via method ArenaLive:ConstructHandler, because there already is a handler with the name %s registered."], "error", handlerName);
		return nil;
	end

	-- Create the new handler and set it up:
	if ( needsFrame ) then
		frameType = frameType or "Frame";
		frameParent = frameParent;
		self.handlers[handlerName] = CreateFrame(frameType, frameName, frameParent, inheritFrame);
	else
		self.handlers[handlerName] = {};
	end
	
	self.handlers[handlerName].name = handlerName;
	
	-- Equip with base class methods:
	ArenaLive:CopyClassMethods(Handler, self.handlers[handlerName]);
	
	if ( isEventObject ) then
		self:ConstructEventObject(self.handlers[handlerName]);
	end
	
	--ArenaLive:Message("Successfully constructed handler with the name %s!", "debug", handlerName);
	
	return self.handlers[handlerName];

end

--[[ Method: DestroyHandler
	 Deletes the specified handler. Also removes it from all events.
		handlerName (string): Name of the new handler.
]]--
function ArenaLive:DestroyHandler(handlerName)

	ArenaLive:CheckArgs(handlerName, "string");

	if ( not self.handlers[handlerName] ) then
		ArenaLive:Message(L["Couldn't delete handler via method ArenaLive:DestroyHandler, because there is no handler \"%s\" registered."], "error", handlerName);
		return;
	end
	
	local handler = self.handlers[handlerName];
	
	if ( handler.UnregisterAllEvents ) then
		handler:UnregisterAllEvents()
	end
	
	self.handlers[handlerName] = nil;

	--ArenaLive:Message("Successfully destroyed handler with the name %s!", "debug", handlerName);
end

--[[ Method: GetHandler
	 Returns the handler with the specified name.
		handlerName (string): Name of the new handler.
]]--
function ArenaLive:GetHandler(handlerName)
	
	ArenaLive:CheckArgs(handlerName, "string");
	
	if ( not self.handlers[handlerName] ) then
		ArenaLive:Message(L["Couldn't get handler via method ArenaLive:GetHandler, because there is no handler \"%s\" registered."], "error", handlerName);
		return nil;
	end

	return self.handlers[handlerName];
end

--[[ Method: ConstructHandlerObject
	 Construct a handler object of the specified type.
		handlerName (string): Name of the new handler.
		... (mixed): A list of further args the handler needs to set up the object.
]]
function ArenaLive:ConstructHandlerObject(object, handlerName, ...)

	ArenaLive:CheckArgs(handlerName, "string");

	if ( not self.handlers[handlerName] ) then
		ArenaLive:Message(L["Couldn't create handler object of the type \"%s\" via method ArenaLive:ConstructHandlerObject, because there is no handler with that name registered."], "error", handlerName);
		return;
	end

	object.handlerType = handlerName;
	
	if ( type(self.handlers[handlerName].ConstructObject) == "function" ) then	
		-- Transmit object to handler's construct function:
		self.handlers[handlerName]:ConstructObject(object, ...);
	else
		--ArenaLive:Message("Handler object type \"%s\" does not have a ConstructObject method. Just add name and return...", "debug", handlerName);
	end

end

--[[
*****************************************
**** BASE CLASS FUNCTIONS START HERE ****
*****************************************
]]--
--[[ Method: GetHandlerObject
	 Returns the actual object the handler will update/change etc. This is used, because sometimes we hand over
	 superordinated frames (e.g. a unit frame) to the Handler functions.
		handlerName (string): Name of the new handler.
		... (mixed): A list of further args the handler needs to set up the object.
]]
function Handler:GetHandlerObject(object)
	if ( object.handlerType == self.name ) then
		-- This frame already is the handler object, so we return it:
		return object;
	elseif ( object[self.name] ) then
		-- This is a superordinated frame, so we return the actual handler object:
		return object[self.name];
	end
end

--[[ Method: SetHandlerClass
	 This one sets something like a base class for the handler, i.e. it will have the functions and other information of that "class".
	 This is done via meta tables. For more information on how to create something like classes with metatables have a look at:
	 http://lua-users.org/wiki/LuaClassesWithMetatable.
		ARGUMENTS:
			handlerName (string): Name of the handler that will function as class for the handler that is calling this func.
]]--
function Handler:SetHandlerClass(handlerName)
	if ( not ArenaLive.handlers[handlerName] ) then
		ArenaLive:Message(L["Couldn't set handler \"%s\" as the class of handler \"%s\", because there is no handler with the name \"%s\" registered."], "error", handlerName, self.name, handlerName);
		return;
	end
	
	if ( getmetatable(self) ) then
		-- In case the handler already has a metatable (e.g. because it is a frame) we need to copy the methods instead:
		ArenaLive:CopyClassMethods(ArenaLive.handlers[handlerName], self);
	else
		local mt = { __index = ArenaLive.handlers[handlerName] };
		setmetatable(self, mt);
	end
end
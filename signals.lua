--!strict
--!native

type connection = {
	type:"connection";
	_signal:signal;
	_callback: (...any) -> ();
	Disconnect: (self:connection) -> ()
}

type signal = {
	type:"signal";
	_connections:{connection};
	
	Connect: (self:signal, callback: (...any) -> ()) -> connection;
	Fire: (self:signal, ...any) -> ();
	DisconnectAll: (self:signal) -> ();
	Once: (self:signal, callback: (...any) -> ()) -> connection;
	Wait: (self:signal) -> any;
}

local signal:signal = {
	type = "signal";
	_connections = {} :: {connection};
	
	Connect = function(self:signal, callback: (...any) -> ())
		local connection:connection = {	
			--
			type = "connection";
			_signal = self;
			_callback = callback;
			
			Disconnect = function(self:connection)
				table.remove(self._signal._connections, table.find(self._signal._connections, self))
			end;
		}
		table.insert(self._connections, connection)
		return connection
	end;
	
	Fire = function(self:signal, ...)
		for _, v in table.clone(self._connections) do
			task.spawn(v._callback, ...)
		end
	end;
	
	DisconnectAll = function(self:signal)
		for _, v in table.clone(self._connections) do
			v:Disconnect()
		end
	end;
	
	Once = function(self:signal, callback: (...any) -> ())
		local connection : connection
		
		connection = self:Connect(function(...)
			connection:Disconnect()
			callback(...)
		end)
		
		return connection
	end;
	
	Wait = function(self:signal)
		local thread = coroutine.running()
		
		local c = self:Once(function(...)
			task.spawn(thread, ...)
		end)
		
		return coroutine.yield()
	end
}



local SignalService = {}

SignalService.build = function()
	local t = table.clone(signal)
	t._connections = {}
	return t
end

return SignalService

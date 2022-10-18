-module(chat).
-compile(export_all).

% Set username and wait for incoming connection
% When incoming connection is found, run chat function
init_chat() ->
	MyUsername = io:get_line("Enter Your Name: "),
	register(receiveAsync,spawn(chat,receiveAsync,[])),
	register(chatProcess,spawn(chat,chatProcess,[MyUsername])).

% Set username and connect to existing host
% When connection is established, run chat function
init_chat2(Chat_Node) ->
	MyUsername = io:get_line("Enter Your Name: "),
	{chatProcess,Chat_Node} ! node(),
	register(receiveAsync,spawn(chat,receiveAsync,[])),
	chatProcess(MyUsername,Chat_Node).

% Accept input for message to send
% While waiting for input, print any messages received
chatProcess(MyUsername,Chat_Node) ->

	% Send message to partner
	Send = io:get_line("You: "),
	{receiveAsync,Chat_Node} ! {MyUsername,Send},
	chatProcess(MyUsername,Chat_Node).


% First chat process made by init_chat
% After first exchange, switch to other chat process
chatProcess(MyUsername) ->

	receive
		Chat_Node ->
			% Send message to partner
			Send = io:get_line("You: "),
			{receiveAsync,Chat_Node} ! {MyUsername,Send},
			chatProcess(MyUsername,Chat_Node)
	end.

% Asynchronous function to receive messages
receiveAsync() ->
	receive
		{_,"bye~n"} ->
			io:format("Your partner disconnected~n");
		{Username,Message} ->
			io:format("~p: ~p~n", [string:trim(Username), string:trim(Message)]),
			receiveAsync()
	end.

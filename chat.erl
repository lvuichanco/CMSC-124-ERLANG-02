-module(chat).
-compile(export_all).

% Set username and wait for incoming connection
% When incoming connection is found, run chat function
init_chat() ->
	MyUsername = io:get_line("Enter Your Name: "),
	receive
		Chat_Node ->
			register(chatProcess,spawn(chat,chatProcess,[MyUsername,Chat_Node]))
	end.

% Set username and connect to existing host
% When connection is established, run chat function
init_chat2(Chat_Node) ->
	MyUsername = io:get_line("Enter Your Name: "),
	spawn(chat,chatProcess,[MyUsername,Chat_Node]),
	{init_chat,Chat_Node} ! self().

% Accept input for message to send
% While waiting for input, print any messages received
chatProcess(MyUsername,Chat_Node) ->

	% Send message to partner
	Send = io:get_line("You: "),
	{chatProcess,Chat_Node} ! {MyUsername,Send},

	% Receive message from partner
	receive
		{_,bye} ->
			io:format("Your partner disconnected~n");
		{Username,Message} ->
			io:format("~s: ~s", Username, Message),
			chatProcess(MyUsername,Chat_Node)
	end.

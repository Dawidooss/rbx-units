// 	Notes:
// 	- The first return value of InvokeClient (but not InvokeServer) is bool success, which is false if the invocation timed out
// 	  or the handler errored.

import { ServerResponse } from "types";

// 	- InvokeServer will error if it times out or the handler errors

// 	- InvokeServer/InvokeClient do not return instantly on an error, but instead check for failure every 0.5 seconds. This is
// 	  because it is not possible to both instantly detect errors and have them be logged in the output with full stacktraces.

// 	For detailed API Use/Documentation, see
// 	https://devforum.roblox.com/t/easynetwork-creates-remotes-events-for-you-so-you-dont-have-to/
// ]]

interface Network {
	// **SHARED API**
	BindFunctions(functions: { [key: string]: Callback }): void;
	BindEvents(events: { [key: string]: Callback }): void;

	// **SERVER API**
	FireClient(client: Player, name: string, response: ServerResponse): void;
	FireAllClients(name: string, response: ServerResponse): void;
	FireOtherClients(ignoreClient: Player, name: string, response: ServerResponse): void;

	FireOtherClientsWithinDistance(ignoreClient: Player, distance: number, name: string, response: ServerResponse): void; // prettier-ignore
	FireAllClientsWithinDistance(position: Vector3, distance: number, name: string, response: ServerResponse): void;

	InvokeClient(client: Player, name: string, response: ServerResponse): [...args: any];
	InvokeClientWithTimeout(timeout: number, client: Player, name: string, response: ServerResponse): [...args: any];

	LogTraffic(duration: number): void;

	// **CLIENT API**
	FireServer(name: string, ...args: any): void;

	InvokeServer(name: string, ...args: any): [...args: any];
	InvokeServerWithTimeout(timeout: number, name: string, ...args: any): [...args: any];
}

declare const Network: Network;

export = Network;

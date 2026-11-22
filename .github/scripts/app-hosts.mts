// Reads app-hosts.json into two forward slots, a and b: the hosts docker
// manages, at most two, since a replacement overlaps one host with the next
import { readFileSync } from "node:fs";
import type { Args } from "./database-swap/hosts.mts";

type Host = { port: number; eip?: boolean };
type List = {
	hosts: Record<string, Host>;
	containers: string[];
	serving: string;
};

export const slots = ({ core, env }: Args) => {
	const list: List = JSON.parse(
		readFileSync(`${env.GITHUB_WORKSPACE}/app-hosts.json`, "utf8"),
	);
	const unknown = [...list.containers, list.serving].filter(
		(key) => !(key in list.hosts),
	);
	if (unknown.length > 0) {
		core.setFailed(`app-hosts.json names hosts it does not list: ${unknown}`);
		return;
	}
	if (list.containers.length < 1 || list.containers.length > 2) {
		core.setFailed(
			`app-hosts.json lists ${list.containers.length} hosts with containers; the workflows forward one or two`,
		);
		return;
	}
	["a", "b"].forEach((slot, i) => {
		const key = list.containers[i] ?? "";
		core.setOutput(`${slot}-key`, key);
		core.setOutput(`${slot}-port`, key ? list.hosts[key].port : "");
	});
	core.setOutput("serving", list.serving);
};

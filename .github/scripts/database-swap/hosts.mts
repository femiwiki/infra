// What the swap's phases share: the AWS CLI, SSM commands on the database
// hosts, and ProxySQL's admin interface.
import { execFileSync } from "node:child_process";
import type * as Core from "@actions/core";

export type Args = { core: typeof Core; env: NodeJS.ProcessEnv };

export const ASG = "database";
export const COUNTER = "/mariadb/server-id/next";

const sleep = (s: number) => new Promise((r) => setTimeout(r, s * 1000));

// aws`ec2 describe-instances --instance-ids ${id}`: words split on spaces, and
// each value stays one argument (an array, one per item)
export const aws = (words: TemplateStringsArray, ...values: unknown[]) => {
	const args = words.flatMap((w, i) => [
		...w.split(/\s+/).filter(Boolean),
		...(i < values.length ? [values[i]].flat().map(String) : []),
	]);
	const out = execFileSync(
		"aws",
		[...args, "--region", "ap-northeast-2", "--output", "json"],
		{ encoding: "utf8" },
	);
	return out.trim() ? JSON.parse(out) : {};
};

// Waits for check() to return a value, or throws after the given minutes
export const until = async <T,>(
	what: string,
	minutes: number,
	every: number,
	check: () => Promise<T | undefined> | T | undefined,
) => {
	const end = Date.now() + minutes * 60_000;
	for (;;) {
		const value = await check();
		if (value !== undefined) return value;
		if (Date.now() > end)
			throw new Error(`gave up after ${minutes} minutes waiting for ${what}`);
		await sleep(every);
	}
};

// Runs a shell script as root on a database host and returns its stdout
export const shell = async (id: string, script: string) => {
	const commands = JSON.stringify({ commands: [script] });
	const { Command } =
		aws`ssm send-command --document-name AWS-RunShellScript --instance-ids ${id} --parameters ${commands}`;
	return until(`a command on ${id}`, 10, 2, () => {
		let inv: {
			Status: string;
			StandardOutputContent: string;
			StandardErrorContent: string;
		};
		try {
			inv = aws`ssm get-command-invocation --command-id ${Command.CommandId} --instance-id ${id}`;
		} catch {
			return undefined; // not registered yet
		}
		if (["Pending", "InProgress", "Delayed"].includes(inv.Status))
			return undefined;
		if (inv.Status !== "Success")
			throw new Error(
				`${id}: ${inv.Status}: ${inv.StandardErrorContent.trim()}`,
			);
		return inv.StandardOutputContent.trim();
	});
};

export const sql = (id: string, query: string) =>
	shell(id, `mysql -uroot -NBe ${JSON.stringify(query).replace(/\$/g, "\\$")}`);

// ProxySQL's admin interface, forwarded to the runner's 127.0.0.1:6032
export const admin = (query: string) =>
	execFileSync(
		"mysql",
		["-h127.0.0.1", "-P6032", "-uadmin", "-padmin", "-NBe", query],
		{ encoding: "utf8" },
	).trim();

export const group = () =>
	aws`autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG}`
		.AutoScalingGroups[0];

export const members = (): string[] =>
	group().Instances.map((i: { InstanceId: string }) => i.InstanceId);

export const iface = () =>
	aws`ec2 describe-network-interfaces --filters ${"Name=tag:Name,Values=database primary"}`
		.NetworkInterfaces[0];

export const instance = (id: string) =>
	aws`ec2 describe-instances --instance-ids ${id}`.Reservations[0].Instances[0];

export const tag = (id: string, tags: Record<string, string>) =>
	aws`ec2 create-tags --resources ${id} --tags ${Object.entries(tags).map(([k, v]) => `Key=${k},Value=${v}`)}`;

export const slaveStatus = async (id: string) => {
	const out = await sql(id, "SHOW SLAVE STATUS\\G");
	const field = (name: string) =>
		out.match(new RegExp(`^\\s*${name}: (.*)$`, "m"))?.[1];
	return {
		io: field("Slave_IO_Running"),
		sql: field("Slave_SQL_Running"),
		behind: field("Seconds_Behind_Master"),
		error: field("Last_Error") || field("Last_IO_Error"),
	};
};

export const caughtUp = (s: Awaited<ReturnType<typeof slaveStatus>>) =>
	s.io === "Yes" && s.sql === "Yes" && s.behind === "0";

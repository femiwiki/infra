// Fails on an inbound rule open to everyone beyond HTTP and HTTPS, in any
// enabled region (femiwiki/femiwiki#524). The public log shows only counts.
import { execFileSync } from "node:child_process";
import type { Args } from "./database-swap/hosts.mts";

const ec2 = (region = "", ...args: string[]) =>
	JSON.parse(
		execFileSync(
			"aws",
			["ec2", ...args, "--region", region, "--output", "json"],
			{
				encoding: "utf8",
			},
		),
	);

export const check = ({ core, env }: Args) => {
	let found = 0;
	for (const { RegionName } of ec2(env.AWS_REGION, "describe-regions")
		.Regions) {
		const open = ec2(
			RegionName,
			"describe-security-group-rules",
		).SecurityGroupRules.filter(
			(r: Record<string, unknown>) =>
				!r.IsEgress &&
				(r.CidrIpv4 === "0.0.0.0/0" || r.CidrIpv6 === "::/0") &&
				!(
					r.IpProtocol === "tcp" &&
					r.FromPort === r.ToPort &&
					[80, 443].includes(r.FromPort as number)
				),
		).length;
		core.info(`${RegionName}: ${open} unexpected`);
		found += open;
	}
	if (found)
		core.setFailed(
			`${found} inbound rules are open to everyone beyond HTTP and HTTPS`,
		);
};

// Launches a replica of whoever holds the primary's interface and waits until
// it has followed the primary, caught up, for a while
import {
	type Args,
	ASG,
	aws,
	COUNTER,
	caughtUp,
	group,
	iface,
	instance,
	members,
	shell,
	slaveStatus,
	sql,
	tag,
	until,
} from "./hosts.mts";

export const replica = async ({ core }: Args) => {
	const primary: string = iface().Attachment.InstanceId;
	const desired: number = group().DesiredCapacity;
	const ids = members();

	// A run that stopped after launching picks its replica up again
	let id = ids
		.filter((i) => i !== primary)
		.find((i) =>
			instance(i).Tags?.some(
				(t: { Key: string; Value: string }) =>
					t.Key === "Swap" && t.Value === "replica",
			),
		);
	const serverId: string = aws`ssm get-parameter --name ${COUNTER}`.Parameter
		.Value;

	if (!id) {
		if (desired !== ids.length)
			throw new Error(
				`the ${ASG} group wants ${desired} hosts but has ${ids.length}; settle it first`,
			);
		aws`autoscaling set-desired-capacity --auto-scaling-group-name ${ASG} --desired-capacity ${desired + 1}`;
		id = await until("the group to launch a host", 10, 10, () =>
			members().find((i) => !ids.includes(i)),
		);
		tag(id, { Name: `database-${serverId}`, Swap: "replica" });
		core.info(`Launched ${id} as server_id ${serverId}`);
	}

	await until(`${id} to reach SSM`, 15, 15, () =>
		aws`ssm describe-instance-information --filters ${`Key=InstanceIds,Values=${id}`}`
			.InstanceInformationList[0]?.PingStatus === "Online"
			? true
			: undefined,
	);

	// Restoring the nightly dump takes most of the wait
	await until(`${id} to restore the dump and replicate`, 180, 60, async () => {
		const boot = await shell(id, "cloud-init status || true");
		if (boot.includes("error"))
			throw new Error(`${id}: user data failed: ${boot}`);
		if (!boot.includes("done")) return undefined;
		return (await slaveStatus(id)).io === "Yes" ? true : undefined;
	});

	// The counter moves only once the id is spent, so no host ever reuses one
	const running = await sql(id, "SELECT @@server_id");
	if (running !== serverId)
		throw new Error(`${id} runs server_id ${running}, not ${serverId}`);
	if (aws`ssm get-parameter --name ${COUNTER}`.Parameter.Value === serverId)
		aws`ssm put-parameter --name ${COUNTER} --overwrite --value ${Number(serverId) + 1}`;

	// Caught up for ten checks in a row, a minute apart
	let streak = 0;
	await until(`${id} to stay caught up`, 60, 60, async () => {
		const s = await slaveStatus(id);
		if (s.io !== "Yes" || s.sql !== "Yes")
			throw new Error(`${id} stopped replicating: ${s.error}`);
		streak = caughtUp(s) ? streak + 1 : 0;
		return streak >= 10 ? true : undefined;
	});

	core.setOutput("primary", primary);
	core.setOutput("replica", id);
	core.setOutput("replica-address", instance(id).PrivateIpAddress);
	core.setOutput("server-id", serverId);
	core.info(`${id} follows ${primary} and has caught up`);
};
